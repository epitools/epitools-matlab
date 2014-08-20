function a = LoadControls(obj,settingsObj)
%LOADCONTROLS Summary of this function goes here
%   Detailed explanation goes here
%
% import javax.swing.*;
% import javax.swing.tree.*;
%
% % Show a JTree in a JScrollpane
%
% root        = javax.swing.tree.DefaultMutableTreeNode('Analysis');
% treeModel   = javax.swing.tree.DefaultTreeModel(root);
% tree        = javax.swing.JTree(treeModel);
%
% leafIcon            = javax.swing.ImageIcon('./images/bricks.png');
% folderIconOpen      = javax.swing.ImageIcon('./images/folder-2.png');
% folderIconClosed    = javax.swing.ImageIcon('./images/folder-2.png');
%
% renderer            = javax.swing.tree.DefaultTreeCellRenderer();
% renderer.setLeafIcon(leafIcon);
% renderer.setClosedIcon(folderIconClosed);
% renderer.setOpenIcon(folderIconOpen);
%
% tree.setCellRenderer(renderer);
%
% vec1 = fieldnames(settingsObj.analysis_modules);
%
% for i=1:length(vec1)
%
%     Module_Node = javax.swing.tree.DefaultMutableTreeNode(vec1{i});
%     %fprintf('%s -', vec1{i});
%     vec2 = fieldnames(settingsObj.analysis_modules.(char(vec1{i})));
%     if (isempty(vec2) == 0)
%         for o=1:length(vec2)
%
%             SubModule_Node = javax.swing.tree.DefaultMutableTreeNode(vec2{o});
%             %fprintf('%s -', vec2{o});
%             classSubTree = class(settingsObj.analysis_modules.(char(vec1{i})).(char(vec2{o})));
%
%             switch classSubTree
%                 %case 'cell'
%
%                     %vec3 = '';
%
%                 case 'struct'
%
%                     if(isempty(fieldnames(settingsObj.analysis_modules.(char(vec1{i})).(char(vec2{o}))))==0)
%
%                         vec3 = fieldnames(settingsObj.analysis_modules.(char(vec1{i})).(char(vec2{o})));
%                         %if (isempty(vec3) == 0)
%                         for u=1:length(vec3)
%                             val = settingsObj.analysis_modules.(char(vec1{i})).(char(vec2{o})).(char(vec3{u}));
%                             classVal = class(val);
%                             switch classVal
%                                 case 'double'
%                                    val = num2str(val);
%                                 case 'logical'
%
%                                     if (val)
%                                         val = char('true');
%                                     else
%                                         val = char('false');
%                                     end
%
%                             end
%
%
%                             if(isa(val, 'cell'))
%                                 strVal = '';
%                                 for intElement=1:numel(val)
%
%                                     strVal = [strVal,sprintf('[%s] %s ;',num2str(intElement), num2str(val{intElement}))];
%
%                                 end
%
%                                 SubModule_Node.add(javax.swing.tree.DefaultMutableTreeNode(sprintf('%s = %s',vec3{u}, strVal)));
%
%                             else
%                                 SubModule_Node.add(javax.swing.tree.DefaultMutableTreeNode(sprintf('%s = %s',vec3{u}, val)));
%                             end
%
%                         end
%                         %end
%                     end
%
%             end
%
%             Module_Node.add(SubModule_Node);
%         end
%     end
%
%     %Module_Node.add(SubModule_Node);
%     root.add(Module_Node)
% end
%
%
% scrollpane=javax.swing.JScrollPane();
%
% %a = findobj(scrollpane);
% scrollpane.setViewportView(tree);
% scrollpane.setVerticalScrollBarPolicy(javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
% scrollpane.setHorizontalScrollBarPolicy(javax.swing.ScrollPaneConstants.HORIZONTAL_SCROLLBAR_ALWAYS);
% scrollpane.setBorder(javax.swing.BorderFactory.createTitledBorder(''));
% jcontrol(obj, scrollpane,'Position', [0.0 0.023 0.25 0.915]);

% =========================================================================
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

set(tree, 'Units', 'normalized', 'position', [0.0 0.023 0.25 0.915]);
set(tree, 'NodeSelectedCallback', @selected_cb );

% make root the initially selected node
tree.setSelectedNode( rootNode );

% MousePressedCallback is not supported by the uitree, but by jtree
% set(jtree, 'MousePressedCallback', @mousePressedCallback);

% some layout

drawnow;

a = true;

end

