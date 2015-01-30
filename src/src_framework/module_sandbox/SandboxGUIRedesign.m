 function SandboxGUIRedesign( intStatus, colBackground )
%SANDOBOXGUIREDESIGN Summary of this function goes here
%   Detailed explanation goes here
fig = getappdata(0  , 'hMainGui');
if nargin < 2; colBackground = [0.7882    0.2784    0.2784]; end
setappdata(fig,'uidiag_userchoice', '');
switch intStatus
    case 0
        set(fig, 'Color', [0.5020 0.5020 0.5020]);
    case 1  
        set(fig, 'Color', colBackground);
end
end

