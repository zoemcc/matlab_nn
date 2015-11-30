% q2_starter.m
% You will need to fill out the TODOs in this script and 
% those in the rmsprop_update function in rmsprop_update.m

addpath ../nn

% arbitrary input and target setup
rng(6);

in_dim = 2;
out_dim = 2;

x = [-1, 2; 2, 1];
target = [0, 2; -1 0];

% net setup
% a neural net in this library is made up of a collection of layers,
% where one is fed directly into the next.

% the layers are fed in sequence as a cell array
layers = {};

% affine_layer takes as input the output dimension of the layer and 
% the rate of weight decay -- this is equivalent to a l2 
% regularization on the weights but won't appear in the output loss
layers{1} = affine_layer(2, 0);

% rectifier layer has no parameters and simply takes the max of the 
% previous layer and the 0 vector of the same dimension
layers{2} = rectifier_layer();
layers{3} = affine_layer(out_dim, 0);

% euclidean loss layer will expect a target vector and 
% the loss is the average squared difference between the 
% output of the previous layer and the target
layers{4} = euclidean_loss_layer();

% construct the neural net with the given layers cell array
% and the input vector's dimension.
net = neural_network(layers, in_dim);

numlayers = size(net.layers, 2);
numparams = net.num_params;

% to get the output of the network before the loss layer,
% call net.forward on the desired inputs
% multiple inputs can be fed in at the same time by 
% feeding in a matrix where each column vector is an input
% and you will get a matrix output where each column vector 
% is the corresponding output 
%
% the boolean value here and in loss and forward_backward
% is whether to output the last layer desired or a list
% of the output of each layer
outputs = net.forward(x, false);

% to get just the value of the loss, call net.loss on the input and target
loss = net.loss(x, target, false);

% to get the loss and the full gradient of the loss,
% call net.forward_backward on the input and target
% if the second boolean value is true, the gradients of all the
% parameters are concatenated into one vector and returned
% if it is false, then a cell array of each layer's parameter gradient
% is returned
[loss, gradlosses] = net.forward_backward(x, target, false, true);

% rmsprop parameters
epsilon = 0.9;
tau = 1e-10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: Implement the rmsprop_update function
% use the delta and meansquare found in q2_solution.mat 
% in order to debug your code

theta_0 = linspace(0, 0.5, 12)';
net.set_flat_paramvec(theta_0);

meansquare = zeros(numparams, 1);
[loss, gradient] = net.forward_backward(x, target, false, true);

% TODO: YOUR CODE IN THIS FUNCTION
[delta, meansquare] = rmsprop_update(gradient, meansquare, epsilon, tau);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% the following code shows how to use the neural net library to 
% perform rmsprop descent based optimization

stepsize = 0.003;
T = 600;
losses = zeros(T, 1);

meansquare = zeros(numparams, 1);
gradients = zeros(T, numparams);
meansquares = zeros(T, numparams);
deltas = zeros(T, numparams);

for t = 1:T
    [loss, gradient] = net.forward_backward(x, target, false, true);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TODO: YOUR CODE IN THIS FUNCTION
    [delta, meansquare] = rmsprop_update(gradient, meansquare, epsilon, tau);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    losses(t) = loss;
    gradients(t, :) = gradient;
    meansquares(t, :) = meansquare;
    deltas(t, :) = delta;
    
    % perform update rule using old parameters and rmsprop update
    new_paramvec = net.get_flat_paramvec() - stepsize * delta;
    
    % set new parameters
    net.set_flat_paramvec(new_paramvec);
end

% plots to see the parameters converge

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO:  REPORT THIS PLOT
figure();
plot(losses);
xlabel('Training iteration');
ylabel('Loss');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% you don't need to report these plots but they
% are beautiful and hopefully lend intuition

figure();
for id = 1:numparams
    plot(gradients(:, id)); 
    hold on;
end;
xlabel('Training iteration');
ylabel('gradients');

figure();
for id = 1:numparams
    plot(meansquares(:, id));
    hold on;
end;
xlabel('Training iteration');
ylabel('meansquares');

figure();
for id = 1:numparams
    plot(deltas(:, id));
    hold on;
end;
xlabel('Training iteration');
ylabel('deltas');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: REPORT the delta2_test variable
x_test = reshape(linspace(-1, 1, 4), 2, 2);
target_test = -reshape(linspace(-2, 0, 4), 2, 2);

theta_test = linspace(0, 0.5, 12)';
net.set_flat_paramvec(theta_test);

meansquare_test = zeros(numparams, 1);
[loss, gradient_test] = net.forward_backward(x_test, target_test, false, true);
[delta1_test, meansquare_test] = rmsprop_update(gradient_test, meansquare_test, epsilon, tau);
new_paramvec = net.get_flat_paramvec() - stepsize * delta1_test;
net.set_flat_paramvec(new_paramvec);
[loss, gradient_test] = net.forward_backward(x_test, target_test, false, true);
[delta2_test, meansquare_test] = rmsprop_update(gradient_test, meansquare_test, epsilon, tau);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
