function LoadControls(obj)
%LOADCONTROLS Summary of this function goes here
%   Detailed explanation goes here

import javax.*

% Show a JTree in a JScrollpane

root        = javax.swing.tree.DefaultMutableTreeNode('Analysis');
treeModel   = javax.swing.tree.DefaultTreeModel(root);
tree        = javax.swing.JTree(treeModel);
leafIcon    = javax.swing.ImageIcon('application-go.png');
leafIcon2    = javax.swing.ImageIcon('archive-remove.png');

renderer    = javax.swing.tree.DefaultTreeCellRenderer();
renderer.setLeafIcon(leafIcon);
tree.setCellRenderer(renderer);


vec = {'Registration', 'Projection', 'Segmentation', 'Tracking', 'CLAHE'};

%for i=fieldnames(stgObj.analysis_modules)
 for i=1:5  
    A_Node = javax.swing.tree.DefaultMutableTreeNode(vec(i));
    root.add(A_Node)
    
end
% A_Node = javax.swing.tree.DefaultMutableTreeNode('Registration');
% B_Node = javax.swing.tree.DefaultMutableTreeNode('Projection');
% C_Node = javax.swing.tree.DefaultMutableTreeNode('Segmentation');
%javax.swing.tree.setIcon(leafIcon2)
% root.add(A_Node)
% root.add(B_Node)
% root.add(C_Node)

% treeView = javax.swing.JScrollPane(tree);
% % Create the HTML viewing pane.
% htmlPane =  javax.swing.JEditorPane();
% htmlPane.setEditable(false);
% %initHelp();
% htmlView = javax.swing.JScrollPane(htmlPane);
% splitPane = javax.swing.JSplitPane(javax.swing.JSplitPane.VERTICAL_SPLIT);
% 
% splitPane.setTopComponent(treeView);
% splitPane.setBottomComponent(htmlView);

% for k=1:20
%     root.insert(javax.swing.tree.DefaultMutableTreeNode(sprintf('Item %d',k)), k-1);
% end

scrollpane=javax.swing.JScrollPane();
scrollpane.setViewportView(tree);
scrollpane.setVerticalScrollBarPolicy(javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
scrollpane.setHorizontalScrollBarPolicy(javax.swing.ScrollPaneConstants.HORIZONTAL_SCROLLBAR_ALWAYS);
scrollpane.setBorder(javax.swing.BorderFactory.createTitledBorder(''));
jcontrol(obj, scrollpane,'Position', [0.0 0.023 0.20 0.85]);



end

