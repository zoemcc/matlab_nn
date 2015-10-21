function [ err ] = linear_reg(x_in, A_in, b_in, y_in)

    x_new = affine(x_in, A_in, b_in);

    error = x_new - y_in;
    err = 0.5 * (error)' * error;

end