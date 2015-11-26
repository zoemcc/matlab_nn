classdef softmax_layer < layer
    %softmax_layer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function layer = softmax_layer()
            layer.type = 'softmax';
            layer.initialized = false;
        end;
        
        function result = forward(e, input)
            intermediate = exp(input);
            columnSums = sum(intermediate, 1);
            result = bsxfun(@rdivide, intermediate, columnSums);
        end;
        
        function result = backward(e, input, gradoutput)
            result = {gradoutput .* (input >= 0), []}; % todo
        end
        
        function e = change_dimensions(e, Di)
            e.Di = Di;
            e.Do = Di;
            e.initialized = true;
        end
        
        function paramvec = get_paramvec(e)
            paramvec = [];
        end
        
        function e = set_paramvec(e, paramvec)
            
        end
    end
    
end

