% Illustris Simulation: Public Data Release.

function result = getSnapOffsets(basePath,snapNum,id,type)
  % GETSNAPOFFSETS  Compute offsets within snapshot for a particular group/subgroup.
  import illustris.*
  
  result = struct;
  
  % load groupcat chunk offsets from header of first file
  filePath = groupcat.gcPath(basePath,snapNum);
  header = hdf5_all_attrs(filePath, 'Header');
  
  result.('snapOffsets') = header.('FileOffsets_Snap');
  
  % calculate target groups file chunk which contains this id
  groupFileOffsets = int64(id) - header.(['FileOffsets_' type]);
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
  
  % load the offset (by type) of this group/subgroup within the snapshot
  result.('offsetType') = h5read(filePath, ['/Offsets/' type '_SnapByType'], start, length);
  
end
