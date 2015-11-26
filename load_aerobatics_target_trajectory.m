function [x_init, x_target, u_target] = load_aerobatics_target_trajectory(dt)


%let's pick a reasonable target:

idx = setup_heli_idx;

nU = 4; nX = 12;


u_zeros = [0;0;0;0];

x_init = zeros(12,1); 
x_end = x_init; x_end(idx.ned(1)) = 10; %x_hover_ref; x_end(idx.ned(1)) = 10;  % 


T_hover_at_start = 20;
T_half_forward_flip_at_start = 20;
T_inverted_hover_at_start = 20;


for k=1:T_hover_at_start
	x_target(:,k) = x_init;
end

T0 = T_hover_at_start;


for k=1:T_half_forward_flip_at_start
	x_target(idx.ned,T0+k) = [0;0;0];
	x_target(idx.ned_dot,T0+k) = [0;0;0];
	x_target(idx.pqr,T0+k) = [0;0;0];
	x_target(idx.axis_angle,T0+k) = [0;0;0];

	x_target(idx.pqr(2),T0+k) = pi/(T_half_forward_flip_at_start*dt);
	x_target(idx.axis_angle(2),T0+k) = pi*k/T_half_forward_flip_at_start;
	
end
T0 = T0 + T_half_forward_flip_at_start;

x_inverted_hover_at_start(idx.ned) = [0;0;0];
x_inverted_hover_at_start(idx.ned_dot) = [0;0;0];
x_inverted_hover_at_start(idx.pqr) = [0;0;0];
x_inverted_hover_at_start(idx.axis_angle) = [0;pi;0];

for k=1:T_inverted_hover_at_start
	x_target(:,T0+k) = x_inverted_hover_at_start;
end

T0 = T0 + T_inverted_hover_at_start;

T = T0;


u_target = repmat(u_zeros, 1, T);  % note it could be a better target value to set the control inputs to the values such that if the helicopter were in hover, it would not move assuming no perturbations
