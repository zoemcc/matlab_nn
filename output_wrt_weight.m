function [ output ] = output_wrt_weight( net,  paramvec, layerid, input, target)
%OUTPUT_WRT_WEIGHT used for gradient checking of neural nets
%   Detailed explanation goes here
    layer = net.layers{layerid};
    
    
    if (strcmp(layer.type, 'affine'))
        layer.set_paramvec(paramvec);
    else
        'error, layer is not affine in output_wrt_weight'
    end
    output = net.loss(input, target, false);
    
end

