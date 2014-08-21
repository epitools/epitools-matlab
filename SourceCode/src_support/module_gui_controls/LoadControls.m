function a = LoadControls(obj,settingsObj)
%LOADCONTROLS Summary of this function goes here
%   Detailed explanation goes here

% if isempty(jtree)
%    
% end

% Load JTREE Class
jtree = uitree_control(obj,settingsObj);

% Load Contextual menu on JTREE class
uitree_contextualmenu(jtree);

end

