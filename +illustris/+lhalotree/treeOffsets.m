% Illustris Simulation: Public Data Release.

function [TreeFile,TreeIndex,TreeNum] = treeOffsets(basePath,snapNum,id)
  % TREEOFFSETS  Handle offset loading for a LHaloTree merger tree cutout.
  filePath = illustris.groupcat.gcPath(basePath,snapNum);
  header = illustris.hdf5_all_attrs(filePath, 'Header');
  
  groupFileOffsets = header.('FileOffsets_Subhalo');
  
  % calculate target groups file chunk which contains this id
  groupFileOffsets = int64(id) - groupFileOffsets;
  fileNum = max(find( groupFileOffsets >= 0 ));
  groupOffset = double(groupFileOffsets(fileNum) + 1); % double for h5read
  
  % load the merger tree offsets of this subgroup
  filePath = illustris.groupcat.gcPath(basePath,snapNum,fileNum-1);
  
  TreeFile  = h5read(filePath, '/Offsets/Subhalo_LHaloTreeFile', groupOffset, 1);
  TreeIndex = h5read(filePath, '/Offsets/Subhalo_LHaloTreeIndex', groupOffset, 1);
  TreeNum   = h5read(filePath, '/Offsets/Subhalo_LHaloTreeNum', groupOffset, 1);
  
end
