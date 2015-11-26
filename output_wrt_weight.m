function [ output ] = output_wrt_weight( net,  paramvec,  input, target)
%OUTPUT_WRT_WEIGHT used for gradient checking of neural nets
%   Detailed explanation goes here

    prev_params = net.get_flat_paramvec();
    
    net.set_flat_paramvec(paramvec);
    
    output = net.loss(input, target, false);
    
    net.set_flat_paramvec(prev_params);
    
end

