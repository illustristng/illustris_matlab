% Illustris Simulation: Public Data Release.

function result = getSnapOffsets(basePath,snapNum,id,type)
  % GETSNAPOFFSETS  Compute offsets within snapshot for a particular group/subgroup.
  import illustris.*
  
  result = struct;
  
  % load groupcat chunk offsets from header of first file (old or new format)
  if strfind(groupcat.gcPath(basePath,snapNum),'fof_subhalo')
    % use separate 'offsets_nnn.hdf5' files
    filePath = groupcat.offsetPath(basePath,snapNum);
    [field_names, shapes, types] = hdf5_dset_properties(filePath, 'FileOffsets');
    groupFileOffsets = h5read(filePath, ['/FileOffsets/' type], 1, shapes.(type));

    snapOffsets = h5read(filePath, ['/FileOffsets/SnapByType'], [1 1], shapes.('SnapByType'));
    result.('snapOffsets') = transpose(snapOffsets); % consistency
  else
    % use header of group catalog
    header = groupcat.loadHeader(basePath,snapNum);
    groupFileOffsets = header.(['FileOffsets_' type]);
    
    result.('snapOffsets') = header.('FileOffsets_Snap');
  end
  
  % calculate target groups file chunk which contains this id
  groupFileOffsets = int64(id) - groupFileOffsets;
  fileNum = max(find( groupFileOffsets >= 0 ));
  groupOffset = groupFileOffsets(fileNum) + 1;
  
  % load the length (by type) of this group/subgroup from the group catalog
  filePath = groupcat.gcPath(basePath,snapNum,fileNum-1);
  
  [field_names, shapes, types] = hdf5_dset_properties(filePath, type);
  
  length = shapes.([type 'LenType']);
  start  = ones(1,2 - isscalar(length)); % [1] for 1d, [1 1] for 2d
  
  % modify to single element (is multidimensional, [6,1])
  start(end)  = groupOffset;
  length(end) = 1;
  
  result.('lenType') = h5read(filePath, ['/' type '/' type 'LenType'], start, length);
  
  % old or new format: load the offset (by type) of this group/subgroup within the snapshot
  if strfind(groupcat.gcPath(basePath,snapNum),'fof_subhalo')
    filePath = groupcat.offsetPath(basePath,snapNum);
    result.('offsetType') = h5read(filePath, ['/' type '/SnapByType'], start, length);
  else
    result.('offsetType') = h5read(filePath, ['/Offsets/' type '_SnapByType'], start, length);
  end
end
