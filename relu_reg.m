function [ err ] = relu_reg(x_in, A_in, b_in, y_in)

    v = affine(x_in, A_in, b_in);
    vp = (v > 0) .* v;

    error = vp - y_in;
    err = 0.5 * (error)' * error;

end