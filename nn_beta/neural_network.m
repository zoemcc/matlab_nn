classdef neural_network
    %NN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %variable_list
        params
        layers
        Dinput
        Doutput
        num_params
    end
    
    methods
        function nn = neural_network(layers, Dinput)

            % Set input and output dimensionality.
            nn.Dinput = Dinput;


            % Set up layers in order.
            nn.layers = layers;
            numlayers = size(layers, 2);
            prev_dim = Dinput;
            nn.num_params = 0;
            for i=1:numlayers,
                layer = nn.layers{i};
                layer.change_dimensions(prev_dim);
                prev_dim = layer.Do;
                nn.num_params = nn.num_params + size(layer.get_paramvec(), 1);
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
                'ahhh! no loss layer at the end!'
                    % TODO: error
            end
            
        end
        
        function [loss, gradlosses] = forward_backward(nn, input, target, fullresult, flat_grad)
            forwards = nn.loss(input, target, true);
            numlayers = size(nn.layers, 2);
            intermediates = cell(1, numlayers + 1);
            intermediates{end} = {[1.0], []};
            
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
            if flat_grad
                gradlosses = zeros(nn.num_params, 1);
                cur_index = 1;
                for i = 1:numlayers
                    cur_grad = intermediates{i}{2};
                    cur_num_params = size(cur_grad, 1);
                    gradlosses(cur_index : cur_index + cur_num_params - 1, 1) = cur_grad; 
                    cur_index = cur_index + cur_num_params;
                end
            else
                gradlosses = cell(1, numlayers);
                for i=1:numlayers
                    gradlosses{i} = intermediates{i}{2};
                end
            end
            loss = forwards{end};
        end
        
        function paramvec = get_flat_paramvec(nn)
            paramvec = zeros(nn.num_params, 1);
            numlayers = size(nn.layers, 2);
            cur_index = 1;
            for i = 1:numlayers
                cur_paramvec = nn.layers{i}.get_paramvec();
                cur_num_params = size(cur_paramvec, 1);
                paramvec(cur_index : cur_index + cur_num_params - 1, 1) = cur_paramvec; 
                cur_index = cur_index + cur_num_params;
            end
            
        end
        
        function nn = set_flat_paramvec(nn, paramvec)
            if (size(paramvec, 1) == nn.num_params)
            else
                'num params and dim of paramvec are not equal. error.'
%                 size(paramvec, 1)
%                 nn.num_params
            end
            numlayers = size(nn.layers, 2);
            cur_index = 1;
            for i = 1:numlayers
                cur_paramvec = nn.layers{i}.get_paramvec();
                cur_num_params = size(cur_paramvec, 1);
                cur_paramvec = paramvec(cur_index : cur_index + cur_num_params - 1, 1);
                nn.layers{i}.set_paramvec(cur_paramvec);
                cur_index = cur_index + cur_num_params;
            end
            
        end

    end
    
end

