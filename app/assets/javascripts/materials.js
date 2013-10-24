// Auto-magically referenced. Yay.

$(document).ready(function() {
  var rubyFolders = gon.folders;
  var folders = {};
  
  var currentId = gon.currentFolder.id;
  
  // Convert all the folders to objects.
  rubyFolders.forEach(function(folder) {
    folders[folder.id] = {
      id: folder.id,
      label: folder.name,
      parentId: folder.parent_folder_id,
      children: []
    };
  });
  
  
  var treeData = [];
  var rootFolder;
  
  // Generate the tree we need for jqTree.
  for (var id in folders) {
    var folder = folders[id];
    var parentId = folder.parentId;
    if (!parentId) {
      rootFolder = folder;
    } else {
      folders[parentId].children.push(folder);
    }
  }
  treeData.push(rootFolder);
  
  // Set up the tree.
  var treeElement = $('#file-tree');
  treeElement.tree({
    data: treeData,
    autoOpen: 0
  });
  
  // Select the folder we're currently in.
  var currentFolderNode = treeElement.tree('getNodeById', currentId);
  treeElement.tree('selectNode', currentFolderNode);
  
  // Set up click bindings on the tree.
  treeElement.bind('tree.click', function(event) {
    var selectedNode = treeElement.tree('getSelectedNode');
    var selectedFolderId = selectedNode.id;
    
  });
});