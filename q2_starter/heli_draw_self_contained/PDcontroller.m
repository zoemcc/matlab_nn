function controller = PDcontroller(alpha, beta, damping_ratio, wn)

kp = wn^2/beta;
kd = (2*damping_ratio*wn - alpha)/beta;

controller = @(x, xdot)(-kp*x - kd*xdot);