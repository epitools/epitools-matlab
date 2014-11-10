function [ output_args ] = serverd_ExecuteCommand(command)
%SERVER_EXECUTECOMMAND Summary of this function goes here
%   Detailed explanation goes here
	
% Send the command line to the auxiliary execution of matlab if allowed in
% the setting properties of epitools. In case an auxiliary execution is not
% running, then if allowed, run it. In case the user did not set it, then
% execute it locally, suspending all other processes. 


try
	   
	   eval(command);

	catch exception

		try 
			system(command);
		catch exception
			disp('I believe this was a joke! I am laugthing! ')
		end

	end
end

