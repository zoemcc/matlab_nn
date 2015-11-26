function [statedot] = heli_dynamics(t, state, u)

%u:
%1) roll cyclic - positive left
%2) pitch cyclic - positive forward
%3) throttle - positive more gas
%4) tail collective - positive yaw left (less TR thrust)

%params
Ixx = .0007;
Iyy = .0024;
Izz = .0024;
I = diag([Ixx Iyy Izz]);    %doesn't include rotor
m = .53;                    %includes rotor
g = 9.81;
cg = [0 0 .127];

%unpack
vel = state(4:6);
quat = state(7:10);
omegabody = state(11:13);
R = quat2rmat(quat);    %takes vectors from BODY to WORLD

%compute forces and toques in BODY coordinates
%rotors
[rotorthrust, rotortorque, rotoromega] = simple_main_rotor(u);  %ignores rotor inertia
%assume tail rotor thrust exactly cancels main rotor torque
tailrotorthrust = rotortorque/.4;

%drag due to translation
frontalAreas = [.007, .026, .25]';
CDs = 1/2*1.2*frontalAreas;
bodyvel = R'*vel;
drag = -CDs.*bodyvel*norm(bodyvel);
gravity = R'*[0;0;-m*g];
netforce = gravity + drag + [0; tailrotorthrust; rotorthrust];  %in BODY coordinates
netforceworld = R*netforce;

rotationaldamping = diag([.02 .02 .005]);
rotationaldrag = -rotationaldamping*omegabody;
rolltorque = .1*u(1);
pitchtorque = .1*u(2);
yawtorque = .05*u(4);
nettorque = [rolltorque; pitchtorque; yawtorque] + rotationaldrag; %in BODY coordinates

%rigid body dynamics
statedot = zeros(size(state));
statedot(1:3) = vel;     %world velocity
statedot(4:6) = netforceworld/m;   %spits out acceleration in WORLD coords
statedot(7:10) = quatrate(quat, omegabody) + .3*quat*(1-norm(quat));   %pass quatrate omega BODY
statedot(11:13) = inv(I)*(nettorque - cross(omegabody, I*omegabody));

%ground constraint and noise
if(state(3)-cg(3)==0 && state(6) == 0 && netforceworld(3)<=0)
    statedot(6) = 0;
    maxgroundfriction = abs(netforceworld(3)*.3);
    statedot(4) = statedot(4) - sign(netforceworld(1))*min(maxgroundfriction, abs(netforceworld(1)))/m;
    statedot(5) = statedot(5) - sign(netforceworld(2))*min(maxgroundfriction, abs(netforceworld(2)))/m;
    %and don't add any noise
else
    statedot([4:6, 11:13]) = statedot([4:6, 11:13]) + 0e-6*randn(6,1);
end
