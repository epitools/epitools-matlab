% structstruct(S) takes in a structure variable and displays its structure.
% 
% INPUTS:
% 
% Recursive function 'structstruct.m' accepts a single input of any class.
% For non-structure input, structstruct displays the class and size of the
% input and then exits.  For structure input, structstruct displays the
% fields and sub-fields of the input in an ASCII graphical printout in the
% command window.  The order of structure fields is preserved.
% 

function output = structstruct(S)

% Figure the type and class of the input
whosout = whos('S');
sizes = whosout.size;
sizestr = [int2str(sizes(1)),'x',int2str(sizes(2))];
endstr = [':  [' sizestr '] ' whosout.class];

% Print out the properties of the input variable
%disp(' ');

%disp([inputname(1) endstr]);
output = sprintf('%s\t%s',[inputname(1),endstr]);
% Check if S is a structure, then call the recursive function
if isstruct(S)
     outstr = recursor(S,0,'','');
end
output = sprintf('%s\n%s\n',output, outstr);

end

function ostr = recursor(S,level,recstr,instr)

recstr = [recstr '  |'];
fnames = fieldnames(S);

tmp = instr;
tmp2 = '';
for i = 1:length(fnames)
    %% Print out the current fieldname
    % Take out the i'th field
    tmpstruct = S.(fnames{i});

    % Figure the type and class of the current field
    whosout = whos('tmpstruct');
    sizes = whosout.size;
    sizestr = [int2str(sizes(1)),'x',int2str(sizes(2))];
    if strcmp(whosout.class,'char')
        endstr = [':  [' sizestr '] ' tmpstruct];
    else
        endstr = [':  [' sizestr '] ' whosout.class];    
    end
    
    % Create the strings
    if i == length(fnames) % Last field in the current level
        str = [recstr(1:(end-1)) '''--' fnames{i} endstr];
        recstr(end) = ' ';
    else % Not the last field in the current level
        str = [recstr '--' fnames{i} endstr];
    end

    % Print the output string to the command line
    tmp = sprintf('%s\n%s',tmp, str);

    
    %% Determine if each field is a struct
    % Check if the i'th field of S is a struct
    if isstruct(tmpstruct) % If tmpstruct is a struct, recursive function call
        tmp2 = recursor(tmpstruct,level+1,recstr, tmp); % Call self
        tmp = tmp2;
    end 
    
end
ostr = tmp;
end

