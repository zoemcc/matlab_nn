function [ x_tentative, u_tentative ] = basic_motion_traj( x_init, pos_end_state, axis_end_state, dt)
%BASIC_MOTION_TRAJ 
% Generates a basic trajectory that would be the tentative trajectory
% for a trajectory optimization problem for the goal of 
% starting at x_init and getting to the position in 
% pos_end_state and the orientation in 
% axis_end_state.
% Using this function and feeding it to the trajectory optimization
% from hw3, the data was generated for gps_trajopt_dataset.mat

    % target state
    x_end = x_init;
    x_end(4:6) = pos_end_state;
    x_end(10:12) = axis_end_state;
    
    % interpolation vector
    error_vec = x_end(4:6) - x_init(4:6);
    error_mag = norm(error_vec);
    % constant speed in the middle of the trajectory
    speed = 2;
    % utilize speed and magnitude of position error to calculate total time
    time = error_mag / speed;
    % number of padding timesteps on either side of the 
    % interpolation (necessary for getting up to speed)
    padding = 6;
    ticks = ceil(time / dt) + 2 * padding;
    velocity = error_vec / error_mag * speed;

    x_tentative = zeros(12, ticks);
    % initial padding side is the same as the start state
    for t = 1: padding
        x_tentative(:, t) = x_init;
    end
    % middle section is a linear interpolation of constant velocity
    % between the start and goal state
    for t = 1 + padding:ticks - padding
        portion = (t - padding) / (ticks - 2 * padding);
        x_tentative(:, t) = (1 - portion) * x_init + portion * x_end;
        x_tentative(1:3, t) = velocity;
    end
    % end states have no velocity and the goal state
    for t = ticks - padding : ticks
        x_tentative(:, t) = x_end;
        x_tentative(1:3, t) = zeros(3, 1);
        x_tentative(7:9, t) = zeros(3, 1);
    end
    % initialize with 0 control effort
    u_tentative = zeros(4, ticks);

end

