classdef neural_network
    %neural_network Simple neural network class
    % for feedforward neural nets
    
    properties
        params
        layers
        Dinput
        Doutput
        num_params
    end
    
    methods
        function nn = neural_network(layers, Dinput)
            % constructor
            % layers should be a cell array of layers

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
            % evaluate the neural network on some input
            % and returns the output before the loss layer
            % fullresult is whether to return a list of all
            % intermediate computations or just the last output before 
            % the loss
            intermediates = {input};
            numlayers = size(nn.layers, 2);
            for i=1:(numlayers - 1),
                layer = nn.layers{i};
                if (~strcmp(layer.type, 'euclidean_loss'))
                    intermediates{i + 1} = layer.forward(intermediates{i});
                else
                    fprint('Loss layer encountered before the last layer.  This net is constructed wrong. \n');
                end
            end;
            if fullresult
                result = intermediates;
            else
                result = intermediates{end};
            end
        end
        
        function result = loss(nn, input, target, fullresult)
            % evaluate the neural network on some input
            % and returns the loss between the output and the target
            % fullresult is whether to return a list of all
            % intermediate computations or just the loss
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
                fprint('The last layer is not a loss layer.  This net is constructed wrong. \n');
            end
            
        end
        
        function [loss, gradlosses] = forward_backward(nn, input, target, fullresult, flat_grad)
            % evaluate the neural network on some input
            % and returns the loss between the output and the target
            % and performs backpropagation
            % in order to calculate the gradient of the loss with respect
            % to the parameters of the neural network
            % fullresult is whether to return a list of all
            % intermediate computations or just the loss
            % flat_grad is true to return the gradient as one
            % concatenated parameter vector or false to return 
            % a cell array of each layers' parameter gradients
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
            if fullresult
                loss = forwards;
            else
                loss = forwards{end};
            end
        end
        
        function paramvec = get_flat_paramvec(nn)
            % returns a parameter vector of the neural network's
            % entire parameter set
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
            % sets the neural networks entire parameter set
            % with paramvec input
            if (size(paramvec, 1) == nn.num_params)
            else
                fprint('num_params=%i and dim of input paramvec=%i are not equal. The network parameters cannot be set.', nn.num_params, size(paramvec,1));
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

