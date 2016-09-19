% Illustris Simulation: Public Data Release.

function [off1,off2,off3] = treeOffsets(basePath,snapNum,id,treeName,prefix,offFields)
  % TREEOFFSETS  Handle offset loading for a SubLink merger tree cutout.
  import illustris.*

  % old or new format
  if strfind(groupcat.gcPath(basePath,snapNum),'fof_subhalo')
    % use separate 'offsets_nnn.hdf5' files
    filePath = groupcat.offsetPath(basePath,snapNum);
    [field_names, shapes, types] = hdf5_dset_properties(filePath, 'FileOffsets');
    groupFileOffsets = h5read(filePath, ['/FileOffsets/Subhalo'], 1, shapes.('Subhalo'));
  else
    % load groupcat chunk offsets from header of first file
    header = groupcat.loadHeader(basePath,snapNum);
    groupFileOffsets = header.('FileOffsets_Subhalo');
  end

  % calculate target groups file chunk which contains this id
  groupFileOffsets = int64(id) - groupFileOffsets;
  fileNum = max(find( groupFileOffsets >= 0 ));
  groupOffset = double(groupFileOffsets(fileNum) + 1); % double for h5read
  
  % load the merger tree offsets of this subgroup
  if strfind(groupcat.gcPath(basePath,snapNum),'fof_subhalo')
    offsetFile = groupcat.offsetPath(basePath,snapNum);
    prefix = ['/Subhalo/' treeName '/'];
  else
    offsetFile = groupcat.gcPath(basePath,snapNum,fileNum-1);
    % prefix from input
  end

  off1 = h5read(offsetFile, strjoin([prefix offFields(1)],''), groupOffset, 1); % RowNum/File
  off2 = h5read(offsetFile, strjoin([prefix offFields(2)],''), groupOffset, 1); % LastProgID/Index
  off3 = h5read(offsetFile, strjoin([prefix offFields(3)],''), groupOffset, 1); % SubhaloID/Num
  
end
