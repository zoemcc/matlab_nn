function [ x_tentative, u_tentative ] = basic_motion_traj( x_init, pos_end_state, axis_end_state, dt)
%BASIC_MOTION_TRAJ Summary of this function goes here
%   Detailed explanation goes here

    x_end = x_init;
    x_end(4:6) = pos_end_state;
    x_end(10:12) = axis_end_state;
    error_vec = x_end(4:6) - x_init(4:6);
    error_mag = norm(error_vec);
    speed = 2;
    time = error_mag / speed;
    padding = 6;
    ticks = ceil(time / dt) + 2 * padding;
    velocity = error_vec / error_mag * speed;

    x_tentative = zeros(12, ticks);
    for t = 1: padding
        x_tentative(:, t) = x_init;
    end
    for t = 1 + padding:ticks - padding
        portion = (t - padding) / (ticks - 2 * padding);
        x_tentative(:, t) = (1 - portion) * x_init + portion * x_end;
        x_tentative(1:3, t) = velocity;
    end
    for t = ticks - padding : ticks
        x_tentative(:, t) = x_end;
        x_tentative(1:3, t) = zeros(3, 1);
        x_tentative(7:9, t) = zeros(3, 1);
    end
    u_tentative = zeros(4, ticks);

end

