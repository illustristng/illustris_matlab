% Illustris Simulation: Public Data Release.

function [result] = loadObjects(basePath,snapNum,gName,nName,fields)
  % LOADOBJECTS  Load either halo or subhalo information from the group catalog.
  import illustris.*

  % load header from first chunk
  filePath = groupcat.gcPath(basePath,snapNum);
  header = hdf5_all_attrs(filePath, 'Header');

  result = struct;

  if ~ismember(header,['N' nName '_Total']) && nName == 'subgroups'
    nName = 'subhalos';
  end

  result.('count') = header.(['N' nName '_Total']);
  
  if ~result.('count')
    disp(['warning: zero groups, empty return (snap=' num2str(snapNum) ')'])
    return
  end
  
  % if fields not specified, load everything
  [field_names, shapes, types] = hdf5_dset_properties(filePath, gName);
  
  if ~exist('fields','var')
    fields = field_names;
  end
  
  % loop over all requested fields
  for i = 1:numel(fields)
    field = fields{i};
    
    % verify existence
    if ~ismember(field,field_names)
      error('Group catalog does not have requested field [%s]', field);
    end
    
    % if shape is a scalar of value N, make it a row vector equal to [1 N]
    shape = shapes.(field);
    
    if isscalar(shape)
      shape = [1 shape];
    end
    
    % replace local length with global
    shape(end) = result.('count');
    
    % allocate within return struct
    type = types.(field);
    result.(field) = zeros(shape,type);
  end
  
  % loop over chunks
  wOffset = 1;
  
  for i = 1:header.('NumFiles')
    % open chunk, load header and properties of datasets
    filePath = groupcat.gcPath(basePath,snapNum,i-1);
    
    header = hdf5_all_attrs(filePath, 'Header');
    [field_names, shapes, types] = hdf5_dset_properties(filePath, gName);
    
    if ~header.(['N' nName '_ThisFile']), continue, end % empty file chunk
    
    % loop over each requested field
    for j = 1:numel(fields)
      % read data local to the current file
      field  = fields{j};
      length = shapes.(field);
      start  = ones(1,2 - isscalar(length)); % [1] for 1d, [1 1] for 2d
      
      data = h5read(filePath, ['/' gName '/' field], start, length);
      
      % save
      if isscalar(length)
        result.(field)(wOffset:wOffset+length(end)-1) = data;
      else
        result.(field)(:,wOffset:wOffset+length(end)-1) = data;
      end
    end
    
    wOffset = wOffset + length(end);    
  end
  
  if wOffset-1 ~= result.('count'), error('Should not happen'), end
  
  % only a single field? then return the array instead of a single item hash
  if numel(fields) == 1, result = result.(fields{1});, end
end
