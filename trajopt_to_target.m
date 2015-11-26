function [ x_traj, u_traj ] = trajopt_to_target( x_init, pos_end_state, axis_end_state )
%TRAJOPT_TO_TARGET Summary of this function goes here
%   Detailed explanation goes here

%%
addpath heli_draw_self_contained
addpath heli_draw_self_contained/orientation
addpath utils_rotations;

addpath ../hw3/q2_starter/

f = @sim_heli;
dt = 0.1; % we work with discrete time
%%


[x_tentative, u_tentative] = basic_motion_traj(x_init, pos_end_state, axis_end_state, dt);


%% Copyright Pieter Abbeel

%clear; clc; close all;

%%

% you could try some simpler trajectories first if you like:

%[x_init, x_tentative, u_tentative ] = load_hover_target_trajectory();
%[x_init, x_tentative, u_tentative ] = load_hover_forward_hover_target_trajectory(dt);

% REPORT on this trajectory
%[x_init, x_tentative, u_tentative ] = load_aerobatics_target_trajectory(dt);

% Go with:
%[x_init, x_tentative, u_tentative ] = load_aerobatics_target_trajectory2(dt);
%u_target = u_tentative;
%%


% and load q4_aerobatics_target2_solution.mat
% if you want to take look at my results to get a ball-park idea
% of what to expect from your own solution.
% Note that this is a tricky optimization problem, and the found trajectory
% in both Pieter 's and John's implementations is not entirely feasible,
% i.e., some dynamics violations remain, but these violations are minor
% and don't preclude finding a feedback controller to execute
% the found trajectories.
% If you are able to find some settings that bring the constraint
% violations to zero, let us know! (and we will be impressed! :)

%[x_init, x_tentative, u_tentative ] = load_aerobatics_target_trajectory(dt);

visualize_trajectory(x_tentative, dt);

%%

T = size(x_tentative,2);
nX = size(x_tentative,1);
nU = size(u_tentative,1);

% let's penalize every coordinate equally for deviation from the
% (infeasible) target:
Q = eye(nX);  
R = eye(nU);
Qfinal = Q;


% bounds on the controls (on the actual helicopter this corresponds to
% actuator limits -- actuators have been scaled such as to clip at -1, +1 in our model)
u_min = [-1; -1; -1; -1];
u_max = [ 1;  1;  1;  1];

% all right, let's see if collocation can find a trajectory near the
% (infeasible) target trajectory:

%% YOUR CODE will implement the function below:



[x_target, u_target] = find_target_trajectory_through_SCP(f, dt, x_tentative, u_tentative, x_init, u_min, u_max);

%% END YOUR CODE


%visualize_trajectory(x_target, dt);


% let's evaluate what happens if we execute the found u_traj in open loop
% (helicopter is unstable, not hoping for excellent execution to come from this,
% ... )
%%
x_sim(:,1) = x_init;

for t=1:T-1
	u_sim(:,t) = u_target(:,t);
	x_sim(:,t+1) = f(x_sim(:,t), u_sim(:,t), dt);
end
%%
% figure;
% subplot(5, 1, 1); plot(x_sim(1:3,:)'); hold on; plot(x_tentative(1:3,:)','--'); plot(x_target(1:3,:)','.'); ylabel('ndot, edot, ddot');
% subplot(5, 1, 2); plot(x_sim(4:6,:)'); hold on; plot(x_tentative(4:6,:)','--'); plot(x_target(4:6,:)','.'); ylabel('n, e, d');
% subplot(5, 1, 3); plot(x_sim(7:9,:)'); hold on; plot(x_tentative(7:9,:)','--'); plot(x_target(7:9,:)','.'); ylabel('p, q, r');
% subplot(5, 1, 4); plot(x_sim(10:12,:)'); hold on; plot(x_tentative(10:12,:)','--'); plot(x_target(10:12,:)','.'); ylabel('axis angle rotation x, y, z');
%subplot(5, 1, 5); plot(u_sim'); hold on; plot(u_tentative','--'); plot(u_target', '.'); ylabel('control inputs: roll, pitch, yaw, collective');
	
%visualize_trajectory(x_sim, dt);
%%

% ok, now let's do closed-loop control around the trajectory we found ---
% let's use x_traj and u_traj as our target trajectory for a time varying
% LQR controller

% we'll penalize equally for deviation in all coordinates:
% 
% keep in mind that the collocation method finds a near feasible
% trajectory, but it need not actually be feasible

Q_lqr = eye(nX+1, nX+1);  Q_lqr(nX+1, nX+1) = 0;
R_lqr = eye(nU, nU);
Q_lqr_final = Q_lqr;


%% YOUR CODE: implement LQR controller

% linearize dynamics about trajectory
eps = 1e-4;
As = zeros(nX, nX, T - 1);
Bs = zeros(nX, nU, T - 1);
Ps = zeros(nX, nX, T);
Ks = zeros(nU, nX, T - 1);
for t = 1:T - 1
    xt = x_target(:, t);
    ut = u_target(:, t);
    for i = 1:nX
        ei = zeros(nX, 1);
        ei(i) = eps;
        As(:, i, t) = (f(xt + ei, ut, dt) - f(xt - ei, ut, dt)) / (2 * eps);
    end
    for i = 1:nU
        ei = zeros(nU, 1);
        ei(i) = eps;
        Bs(:, i) = (f(xt, ut + ei, dt) - f(xt, ut - ei, dt)) / (2 * eps);
    end
end

for t = T - 1:-1:1
    At = As(:, :, t);
    Bt = Bs(:, :, t);
    Ptp1 = Ps(:, :, t+1);
    Ks(:, :, t) = - inv(R + Bt' * Ptp1 * Bt) * Bt' * Ptp1 * At;
    Kt = Ks(:, :, t);
    Ps(:, :, t) = Q + Kt' * R * Kt + (At + Bt * Kt)' * Ptp1 * (At + Bt * Kt);
end


% END YOUR CODE




%% YOUR CODE: implement simulation of the controller:
x_sim_cl(:,1) = x_init;


for t=1:T-1
    x_error = x_sim_cl(:, t) - x_target(:, t);
	u_sim_cl(:,t) = u_target(:,t) + Ks(:, :, t) * x_error;
	x_sim_cl(:,t+1) = f(x_sim_cl(:,t), u_sim_cl(:,t), dt);
end

%% END YOUR CODE

% x_sim_cl: x from simulation with closed-loop controller

%figure;
%subplot(5, 1, 1); plot(x_sim_cl(1:3,:)'); hold on; plot(x_tentative(1:3,:)','--'); plot(x_target(1:3,:)','.'); ylabel('ndot, edot, ddot');
%subplot(5, 1, 2); plot(x_sim_cl(4:6,:)'); hold on; plot(x_tentative(4:6,:)','--'); plot(x_target(4:6,:)','.'); ylabel('n, e, d');
%subplot(5, 1, 3); plot(x_sim_cl(7:9,:)'); hold on; plot(x_tentative(7:9,:)','--'); plot(x_target(7:9,:)','.'); ylabel('p, q, r');
%subplot(5, 1, 4); plot(x_sim_cl(10:12,:)'); hold on; plot(x_tentative(10:12,:)','--'); plot(x_target(10:12,:)','.'); ylabel('axis angle rotation x, y, z');
%subplot(5, 1, 5); plot(u_sim_cl'); hold on; plot(u_tentative','--'); plot(u_target', '.'); ylabel('control inputs: roll, pitch, yaw, collective');
	

visualize_trajectory(x_sim_cl, dt);

x_traj = x_sim_cl;
u_traj = u_sim_cl;
 
 



end

