
iters = 4;

x_init = zeros(12, 1);

x_trajs = cell(1, iters);
u_trajs = cell(1, iters);
pos_end_states = cell(1, iters);
axis_end_states = cell(1, iters);

% 5 and before had nonzero velocity targets
% 9 and before had the same orientation target as beginning
exp = 18;

rng(exp);

experiment_file = strcat('./gps_trajopt_data', int2str(exp), '.mat');

%
i = 1;
fails = 0;
while (i < iters)

    pos_error_vec = randn(3, 1);
    pos_error_vec_unit = pos_error_vec / norm(pos_error_vec + 1e-8);
    pos_error_mag = randn(1) + 2;
    pos_end_state = pos_error_vec_unit * pos_error_mag;
    
    axis_error_vec = randn(3, 1);
    axis_error_vec_unit = axis_error_vec / norm(axis_error_vec + 1e-8);
    %axis_error_vec_unit(3) = abs(axis_error_vec_unit(3));
    axis_error_mag = rand(1) + 0.01;
    axis_end_state = axis_error_vec_unit * axis_error_mag + x_init(10:12);

    
    %end_state_pos = [1; 1; 0];
    try
        [x_traj, u_traj] = trajopt_to_target(x_init, pos_end_state, axis_end_state);
        new_x_init = x_traj(:, end);
        new_x_init(4:6) = 0;

        %

        x_init = new_x_init;

        x_trajs{i} = x_traj;
        u_trajs{i} = u_traj;
        pos_end_states{i} = pos_end_state;
        axis_end_states{i} = axis_end_state;

        save(experiment_file, 'x_trajs', 'u_trajs', 'pos_end_states', 'axis_end_states');

        i = i + 1
        fails = 0;
    catch ME
        'trying again! failed optimization!'
        fails = fails + 1
        if (fails > 3)
            x_init = zeros(12, 1);
            'resetting x_init since we keep failing!'
        end
    end


    

end

