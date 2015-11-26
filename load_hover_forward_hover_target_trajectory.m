function [x_init, x_target, u_target] = load_hover_forward_hover_target_trajectory(dt);


%let's pick a reasonable target:

idx = setup_heli_idx;

nU = 4; nX = 12;


x_init = zeros(12,1); 
x_end = x_init; x_end(idx.ned(1)) = 2; 


T_hover_at_start = 10;  
T_forward_flight = 10;
T_hover_at_destination = 10;

for k=1:T_hover_at_start
	x_target(:,k) = x_init;
end

for k=1:T_forward_flight
	x_target(idx.ned,T_hover_at_start+k) = k/T_forward_flight * x_end(idx.ned,1);
	x_target(idx.ned_dot(1),T_hover_at_start+k) = x_end(idx.ned(1),1) / (T_forward_flight*dt);
end

for k=1:T_hover_at_destination
	x_target(:,T_hover_at_start+T_forward_flight+k) = x_end;
end

T = T_hover_at_start + T_forward_flight + T_hover_at_destination;


u_target = zeros(nU, T);