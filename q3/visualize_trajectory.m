function visualize_trajectory(x_tentative, dt)

for t=1:size(x_tentative,2)
	x_tentative_draw_heli_format(:,t) = convert_to_draw_heli_format(x_tentative(:,t));
end
H = size(x_tentative,2);
tout = 0.1*(1:H);
sim_traj(tout, x_tentative_draw_heli_format', @draw_heli, .1);
