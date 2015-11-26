%convert euler angles to rotation matrix

%conventions:
%rotation matrix takes vectors from BODY TO WORLD (x = Rx')
%euler angles: defined positive when rotating from WORLD to BODY
%euler angles: [(world to once rotated)
%               (once rotated to twice rotated)
%               (twice rotated to body)]
%axis convention: 
%[worldToOnce, onceToTwice, twiceToBody]

%example: standard roll, pitch, yaw
%eulerAngles = [psi, theta, phi] = [yaw, pitch, roll]
%axisConvention = [3 2 1]
%rotates about world z by angle psi (yaw)
%then rotates by intermediate y by angle theta (pitch)
%then rotates by body x by angle phi (roll)

%example2: gyroscope with spin, nutation, precession
%eulerAngles = [psi, theta, phi] = [precession, nutation, spin]
%axisConvention = [3 1 3]
%rotates about world z by angle psi (precession)
%then rotates about intermediate x by angle theta (nutation)
%then rotates about body z by angle phi (spin)

%example3: vicon
%eulerAngles = [root<A-X>, root<A-Y>, root<A-Z>]
%axisConvention = [1 2 3]
%rotates about world x by angle root<A-X>
%then rotates about intermediate y by angle root<A-Y>
%then rotates about body z by angle root<A-Z>

function rmat = euler2rmat(eulerAngles, axisConvention)

if(~length(axisConvention)==3)
    error('euler2rmat: unrecognized axis convention');
end
if(~length(eulerAngles)==3)
    error('euler2rmat: unrecognized euler angle format');
end

rmat = Rbasis(axisConvention(1), eulerAngles(1))*...
        Rbasis(axisConvention(2), eulerAngles(2))*...
        Rbasis(axisConvention(3), eulerAngles(3));