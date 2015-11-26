
% load heli sim stuff

addpath heli_draw_self_contained
addpath heli_draw_self_contained/orientation
addpath utils_rotations;

addpath ../hw3/q2_starter/

f = @sim_heli;
dt = 0.1; % we work with discrete time

%%
% set up nn supervised training

load('gps_trajopt_dataset_processed.mat');

batch_size = size(x_data, 2);

layers = {};
layers{1} = affine_layer(30, 0.01);
layers{2} = rectifier_layer();
layers{3} = affine_layer(40, 0.01);
layers{4} = rectifier_layer();
layers{5} = affine_layer(30, 0.01);
layers{6} = rectifier_layer();
layers{7} = affine_layer(4, 0.01);
layers{8} = euclidean_loss_layer();


net = neural_network(layers, 15);

numlayers = size(net.layers, 2);

%
stepsize = 0.005;
T = 10001;
minibatch = 50;
losses = zeros(T + 1, 1);

stepsize_decay = 0.1;
num_steps_decay = 2500;

%meansquare = 1;
meansquare = ones(net.num_params, 1);
epsilon_rmsprop = 0.9;

k = 1;
for t = 1:T
    idxs = randperm(batch_size);
    idxs = idxs(1:minibatch);
    [loss, gradlosses] = net.forward_backward(x_data(:, idxs), u_data(:, idxs), false, true);

    cur_paramvec = net.get_flat_paramvec();
    meansquare = epsilon_rmsprop * meansquare + (1 - epsilon_rmsprop) * gradlosses .^ 2;
    %meansquare = epsilon_rmsprop * meansquare + (1 - epsilon_rmsprop) * norm(gradlosses, 2) ^ 2;
    delta_paramvec = stepsize * gradlosses ./ (sqrt(meansquare) + 1e-8);
    new_paramvec = cur_paramvec - delta_paramvec;
    net.set_flat_paramvec(new_paramvec);
    if (mod(t - 1, 250) == 0)
        'Evaluating full loss at iteration: '
        t
        full_loss(k) = net.loss(x_data, u_data, false);
        training_iter(k) = t;
        full_loss(k)
        k = k + 1;
    end
    if (mod(t, num_steps_decay) == 0)
        'Stepsize decay'
        stepsize = stepsize * stepsize_decay;
    end
end
%%
figure();
plot(training_iter, full_loss);
xlabel('Training iteration');
ylabel('Loss');


%


%%

% execution phase
% 

iters = 50;

x_init = zeros(12, 1);

x_trajs = cell(1, iters);
u_trajs = cell(1, iters);
pos_end_states = cell(1, iters);
axis_end_states = cell(1, iters);

% 5 and before had nonzero velocity targets
% 9 and before had the same orientation target as beginning
exp = 23;

rng(exp);

experiment_file = strcat('./gps_trajopt_nn_exp_', int2str(exp), '.mat');

%
i = 1;
fails = 0;
while (i <= iters)

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
        % baseline
        %[x_traj, u_traj] = trajopt_to_target(x_init, pos_end_state, axis_end_state);
        
        % get trajectory time
        [x_tentative, u_tentative] = basic_motion_traj(x_init, pos_end_state, axis_end_state, dt);
        visualize_trajectory(x_tentative, dt);
        % neural net execution
        T = size(x_tentative, 2);
        x_sim = zeros(12, T);
        x_sim(:,1) = x_init;
        x_sim_nn = zeros(15, T);
        

        u_sim = zeros(4, T - 1);
        for t=1:T-1
            x_sim_nn(:, t) = nn_input_heli_transform(x_sim(:, t), pos_end_state, axis_end_state);
            u_sim(:,t) = net.forward(x_sim_nn(:, t), false);
            x_sim(:,t+1) = f(x_sim(:,t), u_sim(:,t), dt);
        end
        
        
        visualize_trajectory(x_sim, dt);
        
        
        %new_x_init = x_traj(:, end);
        new_x_init = x_sim(:, end);
        new_x_init(4:6) = 0;

        %

        x_init = new_x_init;

        x_trajs{i} = x_sim;
        u_trajs{i} = u_sim;
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
% 
% 
