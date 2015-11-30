function [ x_nn_input ] = nn_input_heli_transform( x_sim, pos_end_state, axis_end_state )
%NN_INPUT_HELI_TRANSFORM Summary of this function goes here
%   Detailed explanation goes here
    x_nn_input = zeros(15, 1);
    x_nn_input(1:12, 1) = x_sim;
    % relative position to goal
    x_nn_input(4:6, 1) = pos_end_state - x_sim(4:6, 1);
    % orientation goal
    x_nn_input(13:15, 1) = axis_end_state;

end

