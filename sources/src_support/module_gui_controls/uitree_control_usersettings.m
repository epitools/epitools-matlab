function jtree = uitree_control_usersettings(obj,usersettings)
%UITREE_CONTROL Summary of this function goes here
% function based on treeExperiment6 by John Anderson
% see http://www.mathworks.com/matlabcentral/newsreader/view_thread/104957#269485
%
% The mousePressedCallback part is inspired by Yair Altman
%
% derived from Brad Phelan's tree demo
% create a tree model based on UITreeNodes and insert into uitree.
% add and remove nodes from the treeModel and update the display

import javax.swing.*
import javax.swing.tree.*;

% define graphic variables

iconNode_Module = fullfile('./images/icons/folder_wrench.png');
iconLeaf_SubModule = fullfile('./images/icons/cog_go.png');
iconLeaf_Variable = fullfile('./images/icons/page_white_gear.png');

% create top node
rootNode = uitreenode('v0','root', 'Settings Framework', [], 0);

% set treeModel
treeModel = DefaultTreeModel( rootNode );

% create children nodes according stgObj loaded modules
children_FL_Names = fieldnames(usersettings);


for i=1:numel(children_FL_Names)

    children_SL_Names = fieldnames(usersettings.(char(children_FL_Names(i))));
    % Go deeper in node structure
    if(~isempty(children_SL_Names))
        
        cNode = uitreenode('v0','selected', char(children_FL_Names(i)), iconNode_Module, 0);
        rootNode.add(cNode);
        
        % For each subnode in module structure add a new leaf in the tree
        for o=1:numel(children_SL_Names)
            
            ccNode = uitreenode('v0','unselected', char(children_SL_Names(o)), iconLeaf_SubModule, 0);
            treeModel.insertNodeInto(ccNode,cNode,cNode.getChildCount());
             
        end
        
    else
         
         cNode = uitreenode('v0','unselected', char(children_FL_Names(i)), iconLeaf_Variable, 1);
         rootNode.add(cNode);

    end
    
end

% create the tree
tree = uitree('v0',obj);
tree.setModel( treeModel );
% we often rely on the underlying java tree
jtree = handle(tree.getTree,'CallbackProperties');

set(tree, 'Units', 'normalized', 'position', [0.0 0.10 0.25 0.90]);
%set(tree, 'NodeSelectedCallback', @selected_cb );

% make root the initially selected node
tree.setSelectedNode( rootNode );

% some layout
drawnow;

% savehandle
%uihandles_savecontrols( 'uitree_usersettings', tree );

end

