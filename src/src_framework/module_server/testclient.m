%% Java TCP Client
% Example implementation of a java tcp client

import java.net.*;
import java.io.*;

%% Create Socket and Connect to server
% Note that I am connecting to localhost, but you may change that to the corresponding machine IP that is running the server.
port = input('Enter port number: ');
disp('Connecting to server...')
clientSocket = Socket('localhost', port);

iStream = clientSocket.getInputStream;
oStream = clientSocket.getOutputStream;

% Greets the server on connection is accepted
oStream.sendS('Hi Server!')


% Waiting for messages from Server
while ~(iStream.available)
end
msg = readS(iStream);

while isempty(strfind(msg,'!q'))
%% Communication
 if strfind(msg,'#')
     msg = strrep(msg,'#',' ');
     disp(['evaluating message:',msg])  
     system(char(msg));
 end
% Waits for replies from server
while ~(iStream.available)
end
msg = readS(iStream);
end
clientSocket.close
disp (['Connection ended: ' datestr(now)]);