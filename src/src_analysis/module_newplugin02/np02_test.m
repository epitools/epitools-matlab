function [status,argout] = np02_test( input_args )
%NP02_TEST Toy function demonstrating server-client functionalities
status = 0;
argout(1) = numel(input_args);
argout(2) = length(input_args)/2;
end

