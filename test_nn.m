% test some basic functions of neural nets

% init

x = [1; -1; 0.5];
A = [1 0 1; 
     0 1 -1;
     1 0 -1];
b = [-1.0; 1; -1];

% forward

x_new = affine(x, A, b);

y = [1; -1; 0];

error = x_new - y;
sqerror = 0.5 * (error)' * error;

% backprop

error_bar = error;
x_new_bar = error;
y_bar = -error;
b_bar = x_new_bar;
A_bar = x_new_bar * x';
x_bar = A' * x_new_bar;

% grad checks

fx = @(x_in) linear_reg(x_in, A, b, y);
grad_x = gradient(fx, x, 1e-5);
gradxError = grad_x - x_bar

fA = @(A_in) linear_reg(x, A_in, b, y);
grad_A = gradient(fA, A, 1e-5);
gradAError = grad_A - A_bar

fb = @(b_in) linear_reg(x, A, b_in, y);
grad_b = gradient(fb, b, 1e-5);
gradbError = grad_b - b_bar

fy = @(y_in) linear_reg(x, A, b, y_in);
grad_y = gradient(fy, y, 1e-5);
gradyError = grad_y - y_bar