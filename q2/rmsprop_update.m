function [ delta, meansquares_new ] = rmsprop_update( gradient, meansquares, epsilon, tau )
%RMSPROP_UPDATE Calculate the update vector and new meansquares vector
%using the RMSProp update rule. See the problem set pdf for more
%instructions.
%   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TODO: YOUR CODE HERE
%     meansquares_new =   % TODO: YOUR CODE HERE
%     delta           =   % TODO: YOUR CODE HERE
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TODO: REMOVE BEFORE RELEASE
    meansquares_new = epsilon * meansquares + (1 - epsilon) * gradient .^ 2;
    delta = gradient ./ (sqrt(meansquares_new) + tau);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

