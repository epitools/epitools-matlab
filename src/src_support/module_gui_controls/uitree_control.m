function jtree = uitree_control(obj,settingsObj)
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

iconNode_Module = fullfile('./images/icons/brick.png');
iconLeaf_SubModule = fullfile('./images/icons/folder.png');
iconLeaf_Variable = fullfile('./images/icons/page_white_gear.png');

% create top node
rootNode = uitreenode('v0','root', 'Analysis workflow', [], 0);

% set treeModel
treeModel = DefaultTreeModel( rootNode );

% create children nodes according stgObj loaded modules
children_FL_Names = fieldnames(settingsObj.analysis_modules);

for i=1:numel(children_FL_Names)
    
    children_SL_Names = fieldnames(settingsObj.analysis_modules.(char(children_FL_Names(i))));
    
    % Go deeper in node structure
    if(~isempty(children_SL_Names))
        
        cNode = uitreenode('v0','selected', char(children_FL_Names(i)), iconNode_Module, 0);
        rootNode.add(cNode);
        
        % For each subnode in module structure add a new leaf in the tree
        for o=1:numel(children_SL_Names)
            
            ccNode = uitreenode('v0','unselected', char(children_SL_Names(o)), iconLeaf_SubModule, 0);
            treeModel.insertNodeInto(ccNode,cNode,cNode.getChildCount());
            
            classSubTree = class(settingsObj.analysis_modules.(char(children_FL_Names{i})).(char(children_SL_Names{o})));
            
            % If this level is a new nested struct level then add more
            % nodes
            if (strcmp(classSubTree,'struct'))
                if(~isempty(fields(settingsObj.analysis_modules.(char(children_FL_Names{i})).(char(children_SL_Names{o})))))
                    
                    % Extract children node names
                    children_TL_Names = fields(settingsObj.analysis_modules.(char(children_FL_Names{i})).(char(children_SL_Names{o})));
                    
                    for u=1:numel(children_TL_Names)
                        
                        % Parsing values associated in node variables
                        varValue = settingsObj.analysis_modules.(char(children_FL_Names{i})).(char(children_SL_Names{o})).(char(children_TL_Names{u}));
                        classVal = class(varValue);
                        
                        switch classVal
                            case 'double'
                                varValue = num2str(varValue);
                            case 'logical'
                                if (varValue)
                                    varValue = char('true');
                                else
                                    varValue = char('false');
                                end
                            case 'cell'
                                strVal = '';
                                % Concatenating mutiple elements in a single string
                                for intElement=1:numel(varValue)
                                    strVal = [strVal,sprintf('[%s] %s ;',num2str(intElement), num2str(varValue{intElement}))];
                                end
                                varValue = strVal;
                            case 'struct'
                                strVal = '';
                                structfields = fieldnames(varValue);
                                for intElement = 1:numel(structfields)
                                    if isa(varValue.(char(structfields(intElement))),'cell')
                                        strVal = [strVal,sprintf('[%s] %s ;',structfields{intElement}, num2str(varValue.(char(structfields(intElement))){:}))];
                                    else
                                        strVal = [strVal,sprintf('[%s] %s ;',structfields{intElement}, num2str(varValue.(char(structfields(intElement)))))];
                                    end
                                end
                                varValue = strVal;
                        end
                        
                        % Add subnode
                        cccNode = uitreenode('v0','unselected', sprintf('%s = %s',children_TL_Names{u}, varValue), iconLeaf_Variable, 1);
                        treeModel.insertNodeInto(cccNode,ccNode,ccNode.getChildCount());

                    end
                end
            end
            
            
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
jtree.expandPath(jtree.getPathForRow(0));

set(tree, 'Units', 'normalized', 'position', [0.0 0.325 0.17 0.695]);
%set(tree, 'NodeSelectedCallback', @selected_cb );

% make root the initially selected node
tree.setSelectedNode( rootNode );

% some layout
drawnow;

% savehandle
uihandles_savecontrols( 'uitree', tree );


end

