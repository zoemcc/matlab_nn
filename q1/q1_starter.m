% q1_starter.m
% You will need to fill out the TODOs in this script and 
% those in the simple_backprop_net function.
% You will be calculating the gradient for a simple 
% fixed neural net using the backpropagation algorithm.

x = [1; -1; 0.5];
A = [1 0 1; 
     0 1 -1;
     1 0 -1];
b = [-1; 1; 1];
y = [1; -1; 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: YOUR CODE IN THIS FUNCTION
% Load the solutions found in q1_a_solution.mat
% to compare and make sure that you've calculated 
% the quantities correctly
[ v, vp, error, sqerror, sqerror_bar, error_bar, vp_bar, ...
  v_bar, y_bar, b_bar, A_bar, x_bar ] ...
    = simple_backprop_net( x, y, A, b );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% grad checks -- all the printed variables should be 
% approximately 0.0 to some tolerance
% use these printouts to debug your gradient calculations

tol = 1e-5;

fx = @(x_in) relu_reg(x_in, A, b, y);
grad_x = gradient(fx, x, tol);
gradxError = grad_x - x_bar

fA = @(A_in) relu_reg(x, A_in, b, y);
grad_A = gradient(fA, A, tol);
gradAError = grad_A - A_bar

fb = @(b_in) relu_reg(x, A, b_in, y);
grad_b = gradient(fb, b, tol);
gradbError = grad_b - b_bar

fy = @(y_in) relu_reg(x, A, b, y_in);
grad_y = gradient(fy, y, tol);
gradyError = grad_y - y_bar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: REPORT the
% error_bar_test, vp_bar_test, v_bar_test, y_bar_test,
% b_bar_test, A_bar_test, x_bar_test 
% variables from the following calculations: 

x_test = [1; -1];
A_test = [2 -1; 
          -1 1];
b_test = [-1; -1];
y_test = [1; 2];
[ v_test, vp_test, error_test, sqerror_test, sqerror_bar_test, ...
  error_bar_test, vp_bar_test, v_bar_test, y_bar_test, ...
  b_bar_test, A_bar_test, x_bar_test ] ...
    = simple_backprop_net( x_test, y_test, A_test, b_test );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
