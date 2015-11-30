%quaternion for rotation about a basis axis

function quat = qbasis(axis, ang)

a = zeros(3,1);
a(axis) = 1;
quat = [cos(ang/2); sin(ang/2)*a];
