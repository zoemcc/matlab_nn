function [x_target, u_target] = find_target_trajectory_through_SCP(f, dt, x_tentative, u_tentative, x_init, u_min, u_max)

nX = length(x_init);
nU = length(u_min);
T = size(x_tentative,2);
nXUT = (nX+nU)*T;


user_cfg = struct();
user_cfg.min_approx_improve = 1e-1;
user_cfg.min_trust_box_size = 1e-4;
user_cfg.full_hessian = false;
user_cfg.cnt_tolerance = 1e-3;
user_cfg.h_use_numerical = false; %%for speed, you'll want to be provide an implementation of the gradient computation for h 
user_cfg.initial_trust_box_size = .1;
user_cfg.max_merit_coeff_increases = 3;
user_cfg.initial_penalty_coeff = 1000;

traj_dynamics_cfg = struct();
traj_dynamics_cfg.nX = nX;
traj_dynamics_cfg.nU = nU;
traj_dynamics_cfg.T = T;
traj_dynamics_cfg.f = f;
traj_dynamics_cfg.dt = dt;

%% YOUR CODE HERE

nUT = nU * T;
nXT = nX * T;

x0 = [reshape(x_tentative, nXT, 1); reshape(u_tentative, nUT, 1)]; % YOUR CODE
q = -x0'; % YOUR CODE 
Q = eye(nXUT); % YOUR CODE




f0 = @(x) 0;
A_ineq = zeros(2 * nUT, nXUT); % YOUR CODE
b_ineq = zeros(2 * nUT, 1); % YOUR CODE
for t = 1:T
    for i = 1:nU
        A_ineq(2 * (t - 1) * nU + 2 * (i - 1) + 1, nXT + (t - 1) * nU + i) = 1; % max
        A_ineq(2 * (t - 1) * nU + 2 * (i - 1) + 2, nXT + (t - 1) * nU + i) = -1; % min
        b_ineq(2 * (t - 1) * nU + 2 * (i - 1) + 1, 1) = u_max(i); % max
        b_ineq(2 * (t - 1) * nU + 2 * (i - 1) + 2, 1) = -u_min(i); % min
    end
end

A_eq = [eye(12), zeros(12, nXUT - 12)]; % YOUR CODE
b_eq = x_init; % YOUR CODE
g = @(x) -1e5;

h = @(x) h_trajectory_dynamics(x, traj_dynamics_cfg); %YOURS TO IMPLEMENT


[xu_trajectory, success] = penalty_sqp(x0, Q, q, f0, A_ineq, b_ineq, A_eq, b_eq, g, h, user_cfg);

% assuming your xu_trajectory has first all states and then all control
% inputs, code below will get back out x_target and u_target in desired
% format
x_target = reshape(xu_trajectory(1:T*nX),nX, T);
u_target = reshape(xu_trajectory(T*nX+1:end), nU, T);
