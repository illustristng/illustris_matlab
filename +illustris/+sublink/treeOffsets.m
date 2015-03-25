% Illustris Simulation: Public Data Release.

function [RowNum,LastProgID,SubhaloID] = treeOffsets(basePath,snapNum,id)
  % TREEOFFSETS  Handle offset loading for a SubLink merger tree cutout.
  filePath = illustris.groupcat.gcPath(basePath,snapNum);
  header = illustris.hdf5_all_attrs(filePath, 'Header');
  
  groupFileOffsets = header.('FileOffsets_Subhalo');
  
  % calculate target groups file chunk which contains this id
  groupFileOffsets = int64(id) - groupFileOffsets;
  fileNum = max(find( groupFileOffsets >= 0 ));
  groupOffset = double(groupFileOffsets(fileNum) + 1); % double for h5read
  
  % load the merger tree offsets of this subgroup
  filePath = illustris.groupcat.gcPath(basePath,snapNum,fileNum-1);
  
  RowNum     = h5read(filePath, '/Offsets/Subhalo_SublinkRowNum', groupOffset, 1);
  LastProgID = h5read(filePath, '/Offsets/Subhalo_SublinkLastProgenitorID', groupOffset, 1);
  SubhaloID  = h5read(filePath, '/Offsets/Subhalo_SublinkSubhaloID', groupOffset, 1);
  
end
