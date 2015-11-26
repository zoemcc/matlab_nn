classdef multinomial_logistic_loss_layer < layer
    % multinomial_logistic_loss_layer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function layer = multinomial_logistic_loss_layer()
            layer.Do = 1;
            layer.type = 'multinomial_logistic_loss';
            layer.initialized = false;
        end;
        
        function result = forward(e, input, target)
            result = 0.0;
            N = size(target, 2);
            for i = 1:N
                result = result - input(target(1, i), i);
            end
            result = result / N;
        end;
        
        function result = backward(e, input, target, gradoutput)
            [d, N] = size(input);
            scale = -gradoutput / N;
            gradbottom = zeros(d, N);
            for i = 1:N
                label = target(1, i);
                prob = input(label, i);
                gradbottom(label, i) = scale / prob;
            end
            result = {grabottom, []};
        end
        
        function e = change_dimensions(e, Di)
            e.Di = Di;
            e.Do = 1;
            e.initialized = true;
        end
        
        function paramvec = get_paramvec(e)
            paramvec = [];
        end
        
        function e = set_paramvec(e, paramvec)
            
        end

    end
    
end

