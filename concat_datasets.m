datasets_to_concat = [14, 15, 17, 18];

num_datasets = size(datasets_to_concat, 2);

total_x_trajs = {};
total_u_trajs = {};
total_pos_end_states = {};
total_axis_end_states = {};

n = 1;
for i = 1:num_datasets
    cur_dataset = datasets_to_concat(i);
    load(strcat(['gps_trajopt_data', int2str(cur_dataset), '.mat']))
    num_x_trajs = size(x_trajs, 2);
    for k = 1:num_x_trajs
        if (size(x_trajs{k}, 1) > 0)
            total_x_trajs{n} = x_trajs{k};
            total_u_trajs{n} = u_trajs{k};
            total_pos_end_states{n} = pos_end_states{k};
            total_axis_end_states{n} = axis_end_states{k};
            n = n + 1;
        end
    end
end

x_trajs = total_x_trajs;
u_trajs = total_u_trajs;
pos_end_states = total_pos_end_states;
axis_end_states = total_axis_end_states;

experiment_file = './gps_trajopt_dataset.mat';
save(experiment_file, 'x_trajs', 'u_trajs', 'pos_end_states', 'axis_end_states');