function draw_state = convert_to_draw_heli_format(state)

idx = setup_heli_idx;

% draw_heli format: 
%
% body coordinate frame:
% x: forward
% y: left
% z: up
% 
% for rotation th about axis, quat is:
% Q = [cos(th/2) axis*sin(th/2)]
% 
% heli state:
% 1) x pos
% 2) y pos
% 3) z pos
% 4) x vel  (in WORLD coordinates)
% 5) y vel
% 6) z vel
% 7) q0
% 8) q1
% 9) q2
% 10) q3
% 11) omega_x (in BODY coordinates)
% 12) omega_y
% 13) omega_z

draw_state(1) = state(idx.ned(1));
draw_state(2) = -state(idx.ned(2));
draw_state(3) = -state(idx.ned(3));

draw_state(4) = state(idx.ned_dot(1));
draw_state(5) = -state(idx.ned_dot(2));
draw_state(6) = -state(idx.ned_dot(3));

draw_state(11) = state(idx.pqr(1));
draw_state(12) = -state(idx.pqr(2));
draw_state(13) = -state(idx.pqr(3));


th = norm(state(idx.axis_angle));
if(th~=0)
	axis = state(idx.axis_angle) / th;
else
	axis = [0;0;0];
end

q = [cos(th/2) ; axis*sin(th/2)];

draw_state(7:10) = q;

