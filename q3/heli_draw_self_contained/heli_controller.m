function u = heli_controller(t, x)

throttlecont = PDcontroller(0, 23.5, .7, 2);
positioncont = PDcontroller(0, 9.81, .7, 1);
cycliccont = PDcontroller(0, 10, .7, 5);
yawcont = PDcontroller(0, 20, .7, 3);

pos = x(1:3);
vel = x(4:6);
quat = x(7:10);
omega = x(11:13);
R = quat2rmat(quat);    %BODY to WORLD

posbody = R'*pos;
velbody = R'*vel;

rollang = asin(R(3,:)*[0 1 0]');
pitchang = -asin(R(3,:)*[1 0 0]');
forwarddir = R*[1 0 0]';
yawang = atan2(forwarddir(2), forwarddir(1));

rolldes = -positioncont(posbody(2), velbody(2));
pitchdes = positioncont(posbody(1), velbody(1));

uroll = cycliccont(rollang-rolldes, omega(1));
upitch = cycliccont(pitchang-pitchdes, omega(2));
uthrottle = .71+throttlecont(pos(3)-1, vel(3)); %shooting for 1, using world coords
uyaw = yawcont(yawang-pi/2, omega(3));

u = [uroll; upitch; uthrottle; uyaw];