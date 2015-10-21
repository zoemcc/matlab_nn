classdef affine_layer < layer
    %AFFINE_LAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        W
        b
    end
    
    methods
        function layer = affine_layer(Do)
            layer.Do = Do;
            zeros_out = zeros(Do * Do, 1);
            tallw = normrnd(zeros_out, 0.08 * ones(Do * Do, 1));
            layer.W = reshape(tallw, Do, Do);
            layer.b = normrnd(zeros(Do, 1), 0.08 * ones(Do, 1));
            layer.type = 'affine';
        end;
        
        function result = forward(e, input)
            result = e.W * input + e.b;
        end;
        
        function result = backward(e, input, gradoutput)
            input_bar = e.W' * gradoutput;
            W_bar = gradoutput * input';
            [Do, Di] = size(e.W);
            b_bar = gradoutput; % TODO: fix if N > 1
            paramvec_bar = [reshape(W_bar, Do * Di, 1); b_bar];
            result = {input_bar, paramvec_bar};
        end
        
        function e = change_dimensions(e, Di)
            e.Di = Di;
            Do = e.Do;
            zeros_out = zeros(Do * Di, 1);
            tallw = normrnd(zeros_out, 0.08 * ones(Do * Di, 1));
            e.W = reshape(tallw, Do, Di);
            e.b = normrnd(zeros(Do, 1), 0.08 * ones(Do, 1));
            e.initialized = true;
        end
        
        function paramvec = get_paramvec(e)
            paramvec = [reshape(e.W, e.Di * e.Do, 1); e.b];
        end
        
        function e = set_paramvec(e, paramvec)
            e.W = reshape(paramvec(1 : e.Di * e.Do), e.Do, e.Di);
            e.b = paramvec(e.Di * e.Do + 1 : end);
        end

    end
    
end

