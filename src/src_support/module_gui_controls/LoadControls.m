function LoadControls(obj,objSettings)
%LOADCONTROLS Summary of this function goes here
%   Detailed explanation goes here
hMainGui = getappdata(0, 'hMainGui');

uihandles_deletecontrols('uitree');

%uihandles_deletecontrols('uipanel_serverqueue');
% Create panel 
uihandles_deletecontrols('uisidebarpanel');
uisidebarpanel = uipanel('Parent', hMainGui,...
        'Position',[0.0 0.00 0.17 1],...
        'Units', 'normalized');
uihandles_savecontrols( 'uisidebarpanel', uisidebarpanel);

% Load JTREE Class
jtree = uitree_control(uisidebarpanel,objSettings);

% Load Contextual menu on JTREE class
uitree_contextualmenu(jtree);

if ~uihandles_exists('uipanel_serverqueue')
    uipanel_serverqueue = uipanel('Parent', uisidebarpanel,...
                                  'Position',[0.0 0.02 0.17 0.20],...
                                  'Units', 'normalized');
    uihandles_savecontrols( 'uipanel_serverqueue', uipanel_serverqueue );
end

if ~uihandles_exists('uipanel_serverpool')
    uipanel_serverpool = uipanel('Parent', uisidebarpanel,...
                                  'Position',[0.0 0.22 0.17 0.10],...
                                  'Units', 'normalized');
    uihandles_savecontrols('uipanel_serverpool', uipanel_serverpool );
end

uihandles_savecontrols('uitree', jtree );

end

