% test some basic functions of neural nets

% init

x = [1; -1; 0.5];
A = [1 0 1; 
     0 1 -1;
     1 0 -1];
b = [-1.0; 1; -1];

% forward

layers = {};
layer1 = affine_layer(5);
layers{1} = layer1;
layers{2} = affine_layer(6);
layers{3} = euclidean_loss_layer();


net = neural_network(layers, 3);

% changing params experiment

W = layer1.W;
b = layer1.b;

W2 = W + 1;
net.layers{1}.W = W2;
W3 = net.layers{1}.W;

results = net.forward(x, false);

target = normrnd(zeros(6, 1), 0.08 * ones(6, 1));

loss = net.loss(x, target, false);

gradlosses = net.forward_backward(x, target, false)
