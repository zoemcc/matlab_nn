function [ sqerror ] = relu_reg(x_in, A_in, b_in, y_in)
%RELU_REG Simple function to calculate the squared 
% error for a relu regression function.

    v = A_in * x_in + b_in;
    vp = (v > 0) .* v;
    error = vp - y_in;
    sqerror = 0.5 * (error)' * error;

end