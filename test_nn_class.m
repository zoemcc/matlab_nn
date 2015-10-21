% test some basic functions of neural nets

% init

x = [1; -1; 0.5];
A = [1 0 1; 
     0 1 -1;
     1 0 -1];
b = [-1.0; 1; -1];

% forward

layers = {};
layer1 = affine_layer(3);
layers{1} = layer1;
layers{2} = rectifier_layer();
layers{3} = affine_layer(6);
layers{4} = euclidean_loss_layer();


net = neural_network(layers, 3);

numlayers = size(net.layers, 2);

% changing params experiment
Abparamvec = [reshape(A, 9, 1); b];
layer1.set_paramvec(Abparamvec);



%
%W = layer1.W;
%b = layer1.b;

%W2 = W + 1;
%net.layers{1}.W = W2;
%W3 = net.layers{1}.W;

results = net.forward(x, false);

target = normrnd(zeros(6, 1), 0.08 * ones(6, 1));
%target = [1; -1; 0];
%

%loss = net.loss(x, target, false);

[loss, gradlosses] = net.forward_backward(x, target, false);

layerid = 1;
fparam = @(param_in) output_wrt_weight(net, param_in, layerid, x, target);
paramvec = net.layers{layerid}.get_paramvec();
loss = fparam(paramvec);
grad_param = gradient(fparam, paramvec, 1e-5);
gradparamError = norm(grad_param - gradlosses{layerid})

%
stepsize = 0.1;
T = 30;
losses = zeros(T + 1, 1);
for t = 1:T
    [loss, gradlosses] = net.forward_backward(x, target, false);
    losses(t) = loss;
    for i = 1:numlayers
        layer = net.layers{i};
        if (strcmp(layer.type, 'affine'))
            new_paramvec = layer.get_paramvec() - stepsize * gradlosses{i};
            layer.set_paramvec(new_paramvec);
        end
    end
end
losses(T + 1) = loss;

figure();
plot(losses);
xlabel('Training iteration');
ylabel('Loss');



