function [thrust, torque, omega] = simple_main_rotor(u)

R = .280;
A = pi*R^2;
throttle = u(3,:);
CT = collective(throttle)/5*.01;
CQ = abs(collective(throttle))/5*7e-4 + 7e-4;
rho = 1.2;

torque = .2*throttle/.7;
omega = sqrt(torque./(.5*rho*CQ*A*R))/R;
thrust = .5*rho*CT*A.*(R*omega).^2;

    function c = collective(throttle)
        range = [-2 8]; %in deg
        c = diff(range)*throttle + range(1);
    end

end