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
                layer.change_dimensions(prev_dim);
            end;

        end
        
        function result = forward(nn, input, fullresult)
            intermediates = {input};
            numlayers = size(nn.layers, 2);
            for i=1:(numlayers - 1),
                layer = nn.layers{i};
                if (~strcmp(layer.type, 'euclidean_loss'))
                    intermediates{i + 1} = layer.forward(intermediates{i});
                else
                    % TODO: error
                end
            end;
            if fullresult
                result = intermediates;
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
                    intermediate{numlayers + 1} = layer.forward(intermediate{end}, target);
                    result = intermediate;
                else
                    result = layer.forward(intermediate, target);
                end
            else
                    % TODO: error
            end
            
        end
        
        function [loss, gradlosses] = forward_backward(nn, input, target, fullresult)
            forwards = nn.loss(input, target, true);
            numlayers = size(nn.layers, 2);
            intermediates = cell(1, numlayers + 1);
            intermediates{end} = {[1], []};
            
            for i=numlayers:-1:1,
                layer = nn.layers{i}; 
                
                if (strcmp(layer.type, 'euclidean_loss'))
                    intermediates{i} = layer.backward(forwards{i}, target, intermediates{i + 1}{1});
                else
                    intermediates{i} = layer.backward(forwards{i}, intermediates{i + 1}{1});
                end
                
            end;
%             if fullresult
%                 result = intermediates(2:end);
%             else
%                 result = intermediates{end};
%             end
            gradlosses = cell(1, numlayers);
            for i=1:numlayers
                gradlosses{i} = intermediates{i}{2};
                %result{i} = intermediates{i};
            end
            loss = forwards{end};
        end

    end
    
end

