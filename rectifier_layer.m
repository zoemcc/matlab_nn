classdef rectifier_layer < layer
    %RECTIFIER_LAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function layer = rectifier_layer()
            layer.type = 'rectifier';
        end;
        
        function result = forward(e, input)
            result = max(input, 0);
        end;
        
        function result = backward(e, input, gradoutput)
            result = {gradoutput .* (input >= 0), []};
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

