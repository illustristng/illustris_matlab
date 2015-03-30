% Illustris Simulation: Public Data Release.

function [result] = loadSingle(basePath,snapNum,type,id)
  % LOADSINGLE  Return complete group catalog information for one halo or subhalo.
  %             Type should be one of {'halo','group','subhalo','subgroup'}.
  import illustris.*
  
  types = {'halo','group','subhalo','subgroup'};
  
  if ~ismember(type, types)
    error('Invalid type, should be one of [%s]', strjoin(types))
  end
  
  if ismember(type, types(1:2)), gName = 'Group';, end
  if ismember(type, types(3:4)), gName = 'Subhalo';, end
  
  % load groupcat offsets, calculate target file and offset
  header = groupcat.loadHeader(basePath,snapNum);
  
  offsets = int64(id) - header.(['FileOffsets_' gName]);
  fileNum = max( find(offsets >= 0) );
  groupOffset = offsets(fileNum) + 1;
  
  % load halo/subhalo fields into a hash
  result = struct;
  
  filePath = groupcat.gcPath(basePath,snapNum,fileNum-1);
  [field_names, shapes, types] = hdf5_dset_properties(filePath, gName);
  
  for i = 1:numel(field_names)
    field = field_names{i};
    
    % parameters to read entire field of this chunk
    length = shapes.(field);
    start  = ones(1,2 - isscalar(length)); % [1] for 1d, [1 1] for 2d
    
    % modify to single element (could be multidimensional)
    start(end)  = groupOffset;
    length(end) = 1;
    
    result.(field) = h5read(filePath, ['/' gName '/' field], start, length);        
  end
  
end
