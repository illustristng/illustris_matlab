% Illustris Simulation: Public Data Release.

function [result] = loadTree(basePath,snapNum,id,fields,onlyMPB)
  % LOADTREE  Load portion of Sublink tree, for a given subhalo, in its existing flat format.
  %           (optionally restricted to a subset fields).
  import illustris.*
  
  if ~exist('onlyMPB','var'), onlyMPB = false;, end

  % the tree is all subhalos between SubhaloID and LastProgenitorID
  [RowNum,LastProgID,SubhaloID] = sublink.treeOffsets(basePath, snapNum, id);
  
  rowStart = RowNum + 1;
  rowEnd   = rowStart + (LastProgID - SubhaloID);
  nRows    = rowEnd - rowStart + 1;
  
  % find the tree file chunk containing this row
  header   = hdf5_all_attrs(groupcat.gcPath(basePath,snapNum), 'Header');
  
  rowOffsets = rowStart - header.('FileOffsets_SubLink')(:);
  fileNum    = max(find( rowOffsets >= 0 ));
  fileOff    = rowOffsets(fileNum);
  
  % load only main progenitor branch? in this case, get MainLeafProgenitorID now
  filePath = sublink.treePath(basePath,snapNum,fileNum-1);
  
  if onlyMPB
    MainLeafProgenitorID = h5read(filePath, '/MainLeafProgenitorID', double(fileOff), 1);
    
    % re-calculate nRows
    rowEnd = rowStart + (MainLeafProgenitorID - SubhaloID);
    nRows  = rowEnd - rowStart + 1;
  end
  
  % read
  result = struct;
  result.('count') = nRows;
  
  % if fields not specified, load everything
  [field_names, shapes, types] = hdf5_dset_properties(filePath);
  
  if ~exist('fields','var') || ~numel(fields), fields = field_names;, end
  
  % make sure fields is not a single element
  if ~isa(fields,'cell'), fields = {fields};, end
  
  if fileOff + nRows > shapes.('SubfindID')
    error('Should not occur. Each tree is contained within a single file.')
  end
  
  % loop over each requested field
  for j = 1:numel(fields)
    % verify existence
    field = fields{j};
    
    if ~ismember(field,field_names), error('SubLink tree does not have field [%s]', field), end    
    
    % read
    length = shapes.(field);
    start  = ones(1,2 - isscalar(length)); % [1] for 1d, [1 1] for 2d
    
    start(end)  = fileOff;
    length(end) = nRows;
    
    data = h5read(filePath, ['/' field '/'], start, length);
    
    % save
    result.(field) = data;
  end
  
  % only a single field? then return the array instead of a single item hash
  if numel(fields) == 1, result = result.(fields{1});, end  
end
