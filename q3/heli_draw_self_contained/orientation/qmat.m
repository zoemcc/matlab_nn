%quaternion matrix - used to multiply two quaternions:
%if r, p, and q are all quaternions, and r = qp
%then  r = qmat(q)*p

function Q = qmat(quat)

q0 = quat(1);
q1 = quat(2);
q2 = quat(3);
q3 = quat(4);

Q = [   q0 -q1 -q2 -q3;
        q1  q0 -q3  q2;
        q2  q3  q0 -q1;
        q3 -q2  q1  q0];