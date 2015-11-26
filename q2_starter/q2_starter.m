% load neural net library
addpath ../nn

% load heli sim stuff

addpath heli_draw_self_contained
addpath heli_draw_self_contained/orientation
addpath utils_rotations;


% addpath ../hw3/q2_starter/

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

% meansquare = 1;
meansquare = ones(net.num_params, 1);
epsilon_rmsprop = 0.9;

k = 1;
full_loss = [];
training_iter = [];
meansquaresnorms = zeros(T, 1);
gradnorms = zeros(T, 1);

for t = 1:T
    idxs = randperm(batch_size);
    idxs = idxs(1:minibatch);
    [loss, gradlosses] = net.forward_backward(x_data(:, idxs), u_data(:, idxs), false, true);

%     gradlosses = gradlosses * 50;
    cur_paramvec = net.get_flat_paramvec();
    meansquare = epsilon_rmsprop * meansquare + (1 - epsilon_rmsprop) * (gradlosses) .^ 2;
%     meansquare = epsilon_rmsprop * meansquare + (1 - epsilon_rmsprop) * norm(gradlosses, 2) ^ 2;
%     delta_paramvec = stepsize * gradlosses;
    delta_paramvec = stepsize * (gradlosses) ./ (sqrt(meansquare) + 1e-8);
    meansquaresnorms(t) = norm(meansquare);
    gradnorms(t) = norm(gradlosses);
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
%
figure();
plot(training_iter, full_loss);
xlabel('Training iteration');
ylabel('Loss'); 

figure();
plot(meansquaresnorms);
xlabel('Training iteration');
ylabel('meansquare norms');

figure();
plot(gradnorms);
xlabel('Training iteration');
ylabel('gradient norms');


%


%%

% Execution and evaluation phase
% The helicopter will be put in an initial state
% and the 

iters = 100;

x_init = zeros(12, 1);

x_trajs = cell(1, iters);
x_tentative_trajs = cell(1, iters);
u_trajs = cell(1, iters);
pos_end_states = cell(1, iters);
axis_end_states = cell(1, iters);
pos_error_end_states = zeros(1, iters);
axis_error_end_states = zeros(1, iters);

exp = 26;

rng(exp);


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
    axis_error_mag = rand(1) + 0.01;
    axis_end_state = axis_error_vec_unit * axis_error_mag + x_init(10:12);


        
        % get trajectory time
        [x_tentative, u_tentative] = basic_motion_traj(x_init, pos_end_state, axis_end_state, dt);
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
        x_sim_nn(:, T) = nn_input_heli_transform(x_sim(:, t), pos_end_state, axis_end_state);
        
        pos_error_at_end = x_sim_nn(4:6, end);
        pos_error_end_states(i) = norm(pos_error_at_end);
        axis_error_at_end = x_sim(10:12, end) - axis_end_state;
        axis_error_end_states(i) = norm(axis_error_at_end);
        
        new_x_init = x_sim(:, end);
        new_x_init(4:6) = 0;

        x_init = new_x_init;

        x_trajs{i} = x_sim;
        x_tentative_trajs{i} = x_tentative;
        u_trajs{i} = u_sim;
        pos_end_states{i} = pos_end_state;
        axis_end_states{i} = axis_end_state;


        i = i + 1
        fails = 0;
%     catch ME
%         'trying again! failed optimization!'
%         fails = fails + 1
%         if (fails > 3)
%             x_init = zeros(12, 1);
%             'resetting x_init since we keep failing!'
%         end
%     end


    

end
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO:  REPORT THESE HISTOGRAMS

figure();
histogram(pos_error_end_states, linspace(0, max(max(pos_error_end_states, 2)), 21));
ylabel('pos errors');

figure();
histogram(axis_error_end_states, 10);
ylabel('axis errors');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%  
% Run this to watch the desired trajectory (x_tentative_trajs)
% followed by the neural net execution trajectory
% for the data generated above.

for i = 1:size(x_trajs, 2)
    visualize_trajectory(x_tentative_trajs{i}, dt);
    visualize_trajectory(x_trajs{i}, dt);
end
