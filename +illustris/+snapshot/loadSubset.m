% Illustris Simulation: Public Data Release.

function [result] = loadSubset(basePath,snapNum,partType,fields,subset)
  % LOADSUBET    Load a subset of fields for all particles/cells of a given partType.
  %              If offset and length specified, load only that subset of the partType.
  import illustris.*
  
  ptNum = partTypeNum(partType);
  gName = ['PartType' num2str(ptNum)];
  
  result = struct;
  
  header = snapshot.loadHeader(basePath,snapNum);
  nPart = snapshot.getNumPart(header);
  
  % decide global read size, starting file chunk, and starting file chunk offset
  if exist('subset','var')
    offsetsThisType = subset.('offsetType')(ptNum+1) - subset.('snapOffsets')(:,ptNum+1);
    
    fileNum = max(find( offsetsThisType >= 0 ));
    fileOff = offsetsThisType(fileNum) + 1;
    numToRead = subset.('lenType')(ptNum+1);
  else
    fileNum = 1;
    fileOff = 1;
    numToRead = nPart(ptNum+1);
  end
  
  fileOff   = uint64(fileOff);
  numToRead = uint64(numToRead);
  
  result.('count') = numToRead;
  if ~numToRead
    disp('warning: no particles of requested type, empty return.')
    return
  end
  
  % find a chunk with this particle type
  field_names = {};  
  i = 0;
  
  while ~ismember(gName,field_names)
    field_names = hdf5_group_names(snapshot.snapPath(basePath,snapNum,i));
    
    i = i + 1;
  end
  
  % if fields not specified, load everything
  filePath = snapshot.snapPath(basePath,snapNum,i);
  [field_names, shapes, types] = hdf5_dset_properties(filePath, gName);
  
  if ~exist('fields','var') || ~numel(fields), fields = field_names;, end
  
  % make sure fields is not a single element
  if ~isa(fields,'cell'), fields = {fields};, end
  
  % loop over all requested fields
  for j = 1:numel(fields)
    % verify existence
    field = fields{j};
    
    if ~ismember(field,field_names)
      error('Particle type [%s] does not have field [%s]', partType, field)
    end
    
    % replace local length with global
    shape = shapes.(field);
    
    if isscalar(shape)
      shape = [1 shape];
    end
    
    shape(end) = numToRead;
    
    % allocate within return struct
    result.(field) = zeros(shape, types.(field));    
  end
  
  % loop over chunks
  wOffset = 1;
  origNumToRead = numToRead;
  
  while numToRead    
    filePath = snapshot.snapPath(basePath,snapNum,fileNum-1);
    
    % no particles of requested type in this file chunk?
    if ~ismember(gName,hdf5_group_names(filePath))
      if exist('subset','var')
        error('Read error: subset read should be contiguous.')
      end
      
      fileNum = fileNum + 1
      continue
    end
    
    % load header and properties of datasets
    header = hdf5_all_attrs(filePath, 'Header');
    [field_names, shapes, types] = hdf5_dset_properties(filePath, gName);
    
    % set local read length for this file chunk, truncate to be within the local size
    numTypeLocal   = uint64( header.('NumPart_ThisFile')(ptNum+1) );
    numToReadLocal = numToRead;
    
    if fileOff + numToReadLocal > numTypeLocal + 1
      numToReadLocal = numTypeLocal - fileOff + 1;
    end
    
    disp(['[' num2str(fileNum) '] off=' num2str(fileOff) ' read [' num2str(numToReadLocal) ...
          '] of [' num2str(numTypeLocal) '] remaining = ' num2str(numToRead-numToReadLocal)])
    
    % loop over each requested field for this particle type
    for j = 1:numel(fields)
      % read data local to the current file
      field = fields{j};
      length = shapes.(field);
      start  = ones(1,2 - isscalar(length)); % [1] for 1d, [1 1] for 2d
      
      start(end)  = fileOff;
      length(end) = numToReadLocal;
      
      data = h5read(filePath, ['/' gName '/' field], start, length);
      
      % save
      if isscalar(length)
        result.(field)(wOffset:wOffset+length(end)-1) = data;
      else
        result.(field)(:,wOffset:wOffset+length(end)-1) = data;
      end      
    end
    
    wOffset   = wOffset + numToReadLocal;
    numToRead = numToRead - numToReadLocal;
    fileNum   = fileNum + 1;
    fileOff   = 1; % start at beginning of all file chunks other than the first
  end
  
  if origNumToRead ~= wOffset-1
    error(['Read [' num2str(wOffset) '] particles, but was expecting [' num2str(origNumToRead) ']'])
  end
  
  % only a single field? then return the array instead of a single item hash
  if numel(fields) == 1, result = result.(fields{1});, end  
end
