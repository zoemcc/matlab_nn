% test some basic functions of neural nets
% NOT TO BE GIVEN TO STUDENTS

% input, function, and target setup
n = 4;
xn = normrnd(zeros(3, n), 0.08 * ones(3, n));

targetn = normrnd(zeros(6, n), 0.08 * ones(6, n));

% net setup

layers = {};
layers{1} = affine_layer(6, 0);
layers{2} = rectifier_layer();
layers{3} = affine_layer(6, 0);
layers{4} = euclidean_loss_layer();

net = neural_network(layers, 3);

numlayers = size(net.layers, 2);

% computation


[loss, gradlosses] = net.forward_backward(xn, targetn, true, true);
loss

fparam = @(param_in) output_wrt_weight(net, param_in, xn, targetn);
paramvec = net.get_flat_paramvec();
loss = fparam(paramvec);
grad_param = gradient(fparam, paramvec, 1e-5);

%
gradparamError = norm(grad_param - gradlosses)

%
stepsize = 0.1;
T = 30;
losses = zeros(T + 1, 1);
for t = 1:T
    [loss, gradlosses] = net.forward_backward(x, target, false, true);
    losses(t) = loss;
    new_paramvec = net.get_flat_paramvec() - stepsize * gradlosses;
    net.set_flat_paramvec(new_paramvec);
end
losses(T + 1) = loss;
loss

figure();
plot(losses);
xlabel('Training iteration');
ylabel('Loss');



