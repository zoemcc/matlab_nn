function [h, jach] = h_trajectory_dynamics(xu_trajectory, cfg)

T = cfg.T; nX = cfg.nX; nU = cfg.nU; dt = cfg.dt;

x_traj = reshape(xu_trajectory(1:T*nX),nX, T);
u_traj = reshape(xu_trajectory(T*nX+1:end), nU, T);

nXUT = (nU + nX) * T;  
nXT = nX * T;

f = cfg.f; %dynamics model x_t_plus_1 = f(x_t, u_t, dt);

%% YOUR CODE HERE

%% NOTE: Most equality constraints depend on only a subset of the
%% variables; this makes "blind" numerical computation of the jacobian by
%% the SQP solver very inefficient -- as it'd compute a ton of entries that
%% are known to be zero (but still do all the work for it).  Hence this
%% function also provides the SQP solver with the jacobian of h.  Note that
%% in our experience it is fast enough to compute the non-zero entries in
%% jach through numerical differentation.

eps = 1e-4;

h = zeros(nX * (T - 1), 1);
jach = zeros(nX * (T - 1), nXUT);
for t = 1:T-1
    xt = x_traj(:, t);
    xtp1 = x_traj(:, t + 1);
    ut = u_traj(:, t);
    h(nX * (t - 1) + 1 : nX * t, 1) = f(xt, ut, dt) - xtp1;
    for i = 1:nX
        ei = zeros(nX, 1);
        ei(i) = eps;
        jach(nX * (t - 1) + 1 : nX * t, nX * (t - 1) + i) = (f(xt + ei, ut, dt) - f(xt - ei, ut, dt)) / (2 * eps);
    end
    jach(nX * (t - 1) + 1 : nX * t, nX * t + 1 : nX * (t + 1)) = -eye(nX);
    for i = 1:nU
        ei = zeros(nU, 1);
        ei(i) = eps;
        jach(nX * (t - 1) + 1 : nX * t, nXT + nU * (t - 1) + i) = (f(xt, ut + ei, dt) - f(xt, ut - ei, dt)) / (2 * eps);
    end
    
end



