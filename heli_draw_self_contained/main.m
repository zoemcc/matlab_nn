figure(25); clf(25);
addpath('orientation');
%addpath([rootpath 'orientation']);

%initial conditions
cg = [0; 0; .127];
ICx = cg+[0;0;0];  %note cg offset
ICv = [0 0 0]';
th = 0;
ICq = [cos(th/2) sin(th/2)*[1 0 0]]';
ICw = [0 0 0]';
IC = [ICx; ICv; ICq; ICw];

[tout, xout] = ode45(@(t,x)heli_dynamics(t,x,heli_controller(t,x)), [0 10], IC);
uout = zeros(length(tout), 4);
for i = 1:length(tout)
    uout(i,:) = heli_controller(0, xout(i,:)')';
end
sim_traj(tout, xout, @draw_heli, .1);

%close all;