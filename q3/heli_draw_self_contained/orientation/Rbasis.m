%rotation matrix for rotation about a basis axis
%matrix takes in body coords, and spits out world coords:
%x = Rx'
function R = Rbasis(axis, ang)

if(axis == 1)
    R = [
        1       0       0;
        0       cos(ang)  -sin(ang);
        0       sin(ang) cos(ang)];
elseif(axis == 2)
    R = [
        cos(ang)  0       sin(ang);
        0       1       0;
        -sin(ang)  0       cos(ang)];
elseif(axis == 3)
    R = [
        cos(ang)  -sin(ang)  0;
        sin(ang) cos(ang)  0;
        0       0       1];
else
    error('Rbasis: unrecognized axis');
end