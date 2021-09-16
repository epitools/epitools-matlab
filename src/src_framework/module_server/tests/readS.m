function b = readS(iStream)
 
disp 'Reply:'
 
% Number of messages
n = iStream.available;
 
% Buffer size = 500 characters
b = zeros(1,500);
for i = 1:n
    b(i) = iStream.read();
end
 
if (b(1) ~= 0)
    disp (char(b));
end
disp ('')   