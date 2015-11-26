
layers = {};

% the sequence of layers executed
% inputs to affine: doutput, w_2reg, w_1reg
layers{1} = affine_layer(15, 0, 0.1); 
layers{2} = relu_layer(); % rectifier 
layers{3} = affine_layer(10, 0.1, 0);
layers{4} = relu_layer();
layers{5} = affine_layer(7, 0.1, 0);
% last layer has to be a loss to compute gradients
layers{6} = euclidean_loss_layer();

net = nn(layers, 7);

% input and bool for result = cell list of layers outputs
result = net.forward(input, false); 

loss = net.loss(input, target, false);
% gradlosses is cell list of gradient
[result, loss, gradlosses] = net.forward_backward(input, target, false); 

% sample gradient descent update:
gradient_weight = 0.1;
for l = 1:size(layers, 2)
    if size(net.params{l}, 1) > 0
        net.params{l} = net.params{l} - gradient_weight * gradlosses{l};
    end
end

