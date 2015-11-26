% get dataset into form usable by nn

load('gps_trajopt_dataset.mat')

num_trajs = size(x_trajs, 2);

x_data = [];
u_data = [];
k = 1;

for i=1:num_trajs
    axis_end_state = axis_end_states{i};
    pos_end_state = pos_end_states{i};
    u_traj = u_trajs{i};
    x_traj = x_trajs{i};
    
    
    len_traj = size(x_traj, 2);
    len_u_traj = size(u_traj, 2);
    %if (len_traj ~= len_u_traj)
    %    'ahhhh!'
    %end
    
    for t = 1:len_traj - 1
        
        x_traj_nn(:, t) = nn_input_heli_transform(x_traj(:, t), pos_end_state, axis_end_state);
        
        x_data(:, k) = x_traj_nn(:, t);
        u_data(:, k) = u_traj(:, t);
        
        k = k + 1;
        
    end
    

    
    
end

experiment_file = './gps_trajopt_dataset_processed.mat';
save(experiment_file, 'x_data', 'u_data');

