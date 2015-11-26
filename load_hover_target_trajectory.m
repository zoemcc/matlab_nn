function [x_init, x_target, u_target] = load_hover_target_trajectory();


%let's pick a reasonable target:

idx = setup_heli_idx;

nU = 4; nX = 12;

T = 20;


x_init = zeros(12,1); % we actually can't be exactly in this state in a stationary way (due to the tail rotor sideways thrust, which means we have to be rolled just a little bit to stay in place), but it's a reasonable thing to target for hover

for k=1:T
	x_target(:,k) = x_init;
end


u_target = zeros(4, T);  % note it could be a better target value to set the control inputs to the values such that if the helicopter were in hover, it would not move assuming no perturbations
