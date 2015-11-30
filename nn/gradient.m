function [ grad_x ] = gradient( func, x, eps)
%gradient symmetric finite differences code


    dimx1 = size(x, 1);
    dimx2 = size(x, 2);
    grad_x = zeros(dimx1, dimx2);
    
    for i = 1:dimx1
        for j = 1:dimx2
            dx = zeros(dimx1, dimx2);
            dx(i, j) = eps;
            grad_x(i, j) = (func(x + dx) - func(x - dx)) / (2 * eps);
        end
    end
end


