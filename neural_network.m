classdef neural_network
    %NN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %variable_list
        params
        layers
        Dinput
        Doutput
    end
    
    methods
        function nn = neural_network(layers, Dinput)

            % Set input and output dimensionality.
            nn.Dinput = Dinput;


            % Set up layers in order.
            nn.layers = layers;
            numlayers = size(layers, 2);
            prev_dim = Dinput;
            for i=1:numlayers,
                layer = nn.layers{i};
                if (strcmp(layer.type, 'affine'))
                    outdim = layer.Do
                    layer.change_dimensions(prev_dim, outdim);
                    prev_dim = outdim;
                elseif (strcmp(layer.type, 'euclidean_loss'))
                    layer.change_dimensions(prev_dim, 1);
                    prev_dim = 1;
                end
            end;

        end
        
        function result = forward(nn, input, fullresult)
            intermediates = {input};
            numlayers = size(nn.layers, 2);
            for i=1:(numlayers - 1),
                layer = nn.layers{i};
                if (strcmp(layer.type, 'affine'))
                    intermediates{i + 1} = layer.forward(intermediates{i});
                elseif (strcmp(layer.type, 'euclidean_loss'))
                    % TODO: error
                end
            end;
            if fullresult
                result = intermediates(2:end);
            else
                result = intermediates{end};
            end
        end
        
        function result = loss(nn, input, target, fullresult)
            intermediate = nn.forward(input, fullresult);
            layer = nn.layers{end};
            numlayers = size(nn.layers, 2);
            if (strcmp(layer.type, 'euclidean_loss'))
                if fullresult
                    intermediate{numlayers} = layer.forward(intermediate{end}, target);
                    result = intermediate;
                else
                    result = layer.forward(intermediate, target);
                end
            else
                    % TODO: error
            end
            
        end
        
        function result = forward_backward(nn, input, target, fullresult)
            forwards = nn.loss(input, target, true);
            numlayers = size(nn.layers, 2);
            intermediates = cell(1, numlayers + 1);
            intermediates{end} = 1;
            
            for i=numlayers:-1:1,
                layer = nn.layers{i}; 
                if (strcmp(layer.type, 'affine'))
                    intermediates{i} = layer.backward(forwards{i}, intermediates{i + 1});
                elseif (strcmp(layer.type, 'euclidean_loss'))
                    intermediates{i} = layer.backward(forwards{i-1}, target, intermediates{i + 1});
                end
                
            end;
%             if fullresult
%                 result = intermediates(2:end);
%             else
%                 result = intermediates{end};
%             end
            result = gradlosses;
        end

    end
    
end

