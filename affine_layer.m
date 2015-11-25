classdef affine_layer < layer
    %AFFINE_LAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        W
        b
        weight_decay
    end
    
    methods
        function layer = affine_layer(Do, weight_decay)
            if nargin < 2
                weight_decay = 0.0;
            end
            layer.Do = Do;
            zeros_out = zeros(Do * Do, 1);
            tallw = normrnd(zeros_out, 0.08 * ones(Do * Do, 1));
            layer.W = reshape(tallw, Do, Do);
            layer.b = normrnd(zeros(Do, 1), 0.08 * ones(Do, 1));
            layer.type = 'affine';
            layer.initialized = false;
            layer.weight_decay = weight_decay;
        end;
        
        function result = forward(e, input)
            intermediate = e.W * input;
            for j = 1:size(input, 2)
                result(:, j) = intermediate(:, j) + e.b;
            end
        end;
        
        function result = backward(e, input, gradoutput)
            input_bar = e.W' * gradoutput;
            W_bar = gradoutput * input' + e.W * e.weight_decay;
            [Do, Di] = size(e.W);
            b_bar = sum(gradoutput, 2); % TODO: fix if N > 1
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

