%convert quaternion to rotation matrix
%quaternion q takes a body vector to world vector by:
%q_world = qconjmat(q)'*qmat(q)*q_body
%rmat takes vectors from body to world

function rmat = quat2rmat(quat)

Q = qconjmat(quat)'*qmat(quat);
rmat = Q(2:end, 2:end);