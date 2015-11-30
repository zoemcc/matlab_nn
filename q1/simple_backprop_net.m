function [ v, vp, error, sqerror, sqerror_bar, error_bar, vp_bar, v_bar, y_bar, b_bar, A_bar, x_bar ] = simple_backprop_net( x, y, A, b )
%SIMPLE_BACKPROP_NET 
% You should calculate the derivative of each variable with respect
% to the output variable, sqerror.
% Utilize dynamic programming to compute each derivative recursively
% using the chain rule and the derivatives already computed, starting
% from d(sqerror) / d(sqerror) = 1 and working backwards through the
% computations.

% forward propagation
% The function that we are computing is an affine function 
% followed by a rectifier 
% (this is typically called a ReLU for Rectified Linear Unit)
% and then followed by the half squared error to some target value, y.
% This could be used for a nonlinear regression.

v = A * x + b;                     % affine
vp = (v > 0) .* v;                 % rectifier -- elementwise positive
error = vp - y;
sqerror = 0.5 * (error)' * error;

% backpropagation
% variable_bar means 
%    d(sqerror) / d(variable)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: TAKEOUT THIS CODE BEFORE RELEASE
sqerror_bar = 1;
error_bar   = error;
y_bar       = -error;
vp_bar      = (v > 0) .* error_bar;
v_bar       = vp_bar;
b_bar       = v_bar;
A_bar       = v_bar * x';
x_bar       = A' * v_bar;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: YOUR CODE HERE
% sqerror_bar = 1;
% error_bar   =     % TODO: YOUR CODE HERE
% y_bar       =     % TODO: YOUR CODE HERE
% vp_bar      =     % TODO: YOUR CODE HERE
% v_bar       =     % TODO: YOUR CODE HERE
% b_bar       =     % TODO: YOUR CODE HERE
% A_bar       =     % TODO: YOUR CODE HERE
% x_bar       =     % TODO: YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

