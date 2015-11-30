%get derivative of a quaternion wrt time, given the quat, and
%angluar velocity of the body written in BODY coordinates
%omega should be a 3 dimensional vector

function qdot = quatrate(quat, omegabody)

qdot = 1/2*qmat(quat)*[0; omegabody];
