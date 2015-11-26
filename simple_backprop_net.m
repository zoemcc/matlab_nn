function [ v, vp, error, sqerror, sqerror_bar, error_bar, vp_bar, v_bar, y_bar, b_bar, A_bar, x_bar ] = simple_backprop_net( x, y, A, b )
%SIMPLE_BACKPROP_NET Summary of this function goes here
%   Detailed explanation goes here

% forward

v = affine(x, A, b);
vp = (v > 0) .* v;
error = vp - y;
sqerror = 0.5 * (error)' * error;

% backprop
% variable_bar means 
%    d(sqerror) / d(variable)

sqerror_bar = 1;
error_bar = error;
y_bar = -error;
vp_bar = (v > 0) .* error_bar;
v_bar = vp_bar;
b_bar = v_bar;
A_bar = v_bar * x';
x_bar = A' * v_bar;

end

