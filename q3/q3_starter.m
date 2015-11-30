% q3_starter.m
% You will need to fill out the TODOs in this script.
% You will design a neural network architecture and 
% hyperparameters to control a helicopter to 
% travel to nearby position and orientation goals

% load neural net library and rmsprop
addpath ../nn
addpath ../q2

% load heli sim stuff
addpath heli_draw_self_contained
addpath heli_draw_self_contained/orientation
addpath utils_rotations;

f = @sim_heli;
dt = 0.1; % we work with discrete time
u_min = -ones(4, 1);
u_max = ones(4, 1);


% set up nn supervised training

% load dataset
load('gps_trajopt_dataset_processed.mat');

% split data into validation and training sets.
% everything past a threshold will be validation and everything
% before, training

data_size = size(x_data, 2);
training_size = floor(0.9 * data_size);
validation_size = data_size - training_size;
validation_idxs = training_size + 1 : data_size;

rng(10);

% Construct neural network architecture here.

% Reasonable networks are typically have between 3 and 5 affine
% layers with rectifiers in between,
% and between 20 and 50 output dimensions per layer.
% Try experimenting with different architectures
% and weight decay rates

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: YOUR CODE HERE
% layers = {};
% layers{1} = affine_layer(30, 0.01);
% layers{2} = rectifier_layer();

% don't change the dimension of the last affine layer
% and end the neural net with a euclidean loss layer
% layers{3} = affine_layer(4, 0.01);
% layers{4} = euclidean_loss_layer();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: REMOVE BEFORE RELEASE
layers = {};
layers{1} = affine_layer(30, 0.01);
layers{2} = rectifier_layer();
layers{3} = affine_layer(40, 0.01);
layers{4} = rectifier_layer();
layers{5} = affine_layer(30, 0.01);
layers{6} = rectifier_layer();
layers{7} = affine_layer(4, 0.01);
layers{8} = euclidean_loss_layer();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the input to the neural net is 15 dimensional
net = neural_network(layers, 15);
numlayers = size(net.layers, 2);
numparams = net.num_params;

% experiment with these parameters for different 
% training schemes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: YOUR CODE HERE
T = 10000;
stepsize = 0.005; % try different orders of magnitude
minibatch = 50; % larger minibatches smooth the descent but take longer
stepsize_decay = 0.1; % multiplies the stepsize by this every 
% num_steps_decay iterations
num_steps_decay = 2500;

% rmsprop variables, you could experiment with epsilon as well 
epsilon = 0.9;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tau = 1e-10;

% training initialization
k = 1;
validation_loss = [];
training_iter = [];

meansquare = zeros(net.num_params, 1);
losses = zeros(T + 1, 1);
gradients = zeros(T, numparams);
meansquares = zeros(T, numparams);
deltas = zeros(T, numparams);

for t = 1:T
    
    % evaluate validation loss periodically
    if (mod(t - 1, 250) == 0) 
        fprintf('Evaluating validation loss before iteration: %i \n', t);
        validation_loss(k) = net.loss(x_data(:, validation_idxs), u_data(:, validation_idxs), false);
        training_iter(k) = t;
        fprintf('validation loss: %f \n', validation_loss(k));
        k = k + 1;
    end
    
    % grab a random minibatch (subset of the training dataset) 
    % and perform a descent step on that minibatch
    idxs = randperm(training_size);
    idxs = idxs(1:minibatch);
    [loss, gradient] = net.forward_backward(x_data(:, idxs), u_data(:, idxs), false, true);
    [delta, meansquare] = rmsprop_update(gradient, meansquare, epsilon, tau);

    % record result
    meansquares(t, :) = meansquare;
    gradients(t, :) = gradient;
    deltas(t, :) = delta; 
    
    % update params
    cur_paramvec = net.get_flat_paramvec();
    new_paramvec = cur_paramvec - stepsize * delta;
    net.set_flat_paramvec(new_paramvec);

    % periodically decrease the learning rate by some schedule
    if (mod(t, num_steps_decay) == 0)
        fprintf('Stepsize decay by: %f \n', stepsize_decay);
        stepsize = stepsize * stepsize_decay;
    end
end
%% Learning plots

% the validation loss should go roughly below 0.05 for good control
% performance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO:  REPORT THIS PLOT
figure();
plot(training_iter, validation_loss);
xlabel('Training iteration');
ylabel('Validation Loss'); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% these other plots are for your convenience and understanding

% plot a random subset of the parameter dimensions
rng(10);
plotidxs = randperm(numparams);
plotidxs = plotidxs(1:5);

figure();
plot(gradients(:, plotidxs));
xlabel('Training iteration');
ylabel('Gradient traces');

figure();
plot((meansquares(:, plotidxs)));
xlabel('Training iteration');
ylabel('Meansquare traces');

figure();
plot((deltas(:, plotidxs)));
xlabel('Training iteration');
ylabel('Delta traces');


%%
% Execution and evaluation phase
% The helicopter will be put in an initial state
% and then given a nearby goal.
% The neural net will be given that state and goal and 
% tries to control towards that goal

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

i = 1;
while (i <= iters)

    % generate random nearby goal
    pos_error_vec = randn(3, 1);
    pos_error_vec_unit = pos_error_vec / norm(pos_error_vec + 1e-8);
    pos_error_mag = randn(1) + 2;
    pos_end_state = pos_error_vec_unit * pos_error_mag;
    
    axis_error_vec = randn(3, 1);
    axis_error_vec_unit = axis_error_vec / norm(axis_error_vec + 1e-8);
    axis_error_mag = rand(1) + 0.01;
    axis_end_state = axis_error_vec_unit * axis_error_mag + x_init(10:12);
        
    % get trajectory time and desired trajectory
    [x_tentative, u_tentative] = basic_motion_traj(x_init, pos_end_state, axis_end_state, dt);
    T = size(x_tentative, 2);

    % neural net execution
    x_sim = zeros(12, T);
    x_sim(:,1) = x_init;
    x_sim_nn = zeros(15, T);

    u_sim = zeros(4, T - 1);
    for t=1:T-1
        % process state to make it feedable to the neural net
        x_sim_nn(:, t) = nn_input_heli_transform(x_sim(:, t), pos_end_state, axis_end_state);
        % apply net and clamp the output to the feasible region
        u_sim(:,t) = clamp_control(net.forward(x_sim_nn(:, t), false), u_min, u_max);
        % forward simulate
        x_sim(:,t+1) = f(x_sim(:,t), u_sim(:,t), dt);
    end
    x_sim_nn(:, T) = nn_input_heli_transform(x_sim(:, t), pos_end_state, axis_end_state);

    % extract errors
    pos_error_at_end = x_sim_nn(4:6, end);
    pos_error_end_states(i) = norm(pos_error_at_end);
    axis_error_at_end = x_sim(10:12, end) - axis_end_state;
    axis_error_end_states(i) = norm(axis_error_at_end);

    % recenter position
    new_x_init = x_sim(:, end);
    new_x_init(4:6) = 0;
    x_init = new_x_init;

    % record trajectories
    x_trajs{i} = x_sim;
    x_tentative_trajs{i} = x_tentative;
    u_trajs{i} = u_sim;
    pos_end_states{i} = pos_end_state;
    axis_end_states{i} = axis_end_state;

    fprintf('Flight iteration %i complete.\n', i);
    i = i + 1;
end
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO:  REPORT THESE HISTOGRAMS
% Don't change the bins of the histograms for easy grading
% Try to get the position error down below 1.5 most of the time
% and the orientation error down below  1 most of the time

figure();
histogram(pos_error_end_states, linspace(0, 10, 41));
ylabel('pos errors');

figure();
histogram(axis_error_end_states, linspace(0, 10, 41));
ylabel('orientation errors');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%  
% Run this to watch the desired trajectory (x_tentative_trajs)
% followed by the neural net execution trajectory
% for the data generated above.

for i = 1:size(x_trajs, 2)
    visualize_trajectory(x_tentative_trajs{i}, dt);
    visualize_trajectory(x_trajs{i}, dt);
end
