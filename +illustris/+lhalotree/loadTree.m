% Illustris Simulation: Public Data Release.

function result = loadTree(basePath,snapNum,id,fields,onlyMPB)
  % LOADTREE  Load portion of LHaloTree tree, for a given subhalo, re-arranging into a flat format.
  import illustris.*
  
  if ~exist('onlyMPB','var'), onlyMPB = false;, end

  % config
  [TreeFile,TreeIndex,TreeNum] = lhalotree.treeOffsets(basePath, snapNum, id);
  
  gName = ['Tree' num2str(TreeNum)]; % group name containing this subhalo
  nRows = -1; % we do not know in advance the size of the tree
  
  % if fields not specified, load everything
  filePath = lhalotree.treePath(basePath,snapNum,TreeFile);
  [field_names, shapes, types] = hdf5_dset_properties(filePath, gName);
  
  if ~exist('fields','var') || ~numel(fields), fields = field_names;, end
  
  % make sure fields is not a single element
  if ~isa(fields,'cell'), fields = {fields};, end
  
  % verify existence of requested fields
  for j = 1:numel(fields)
    field = fields{j};
    if ~ismember(field,field_names), error('Requested field [%s] not in tree.', field), end
  end
  
  % load connectivity for this entire TreeX group
  connFields = {'FirstProgenitor','NextProgenitor'};
  conn = struct;
  
  for j = 1:numel(connFields)
    field = connFields{j};
    conn.(field) = h5read(filePath, ['/' gName '/' field], 1, shapes.(field));
  end
  
  % determine sub-tree size with dummy walk
  dummy = zeros( [1 shapes.('FirstProgenitor')], 'int32' );
  [nRows,dummy] = lhalotree.singleNodeFlat(conn, TreeIndex+1, dummy, dummy, 0, onlyMPB, 0);
  
  result = struct;
  result.('count') = nRows;
  
  % walk through connectivity, one data field at a time
  for j = 1:numel(fields)
    % calculate shapes for allocation and read
    field = fields{j};
    
    length = shapes.(field);
    start  = ones(1,2 - isscalar(length)); % [1] for 1d, [1 1] for 2d
    
    length(end) = nRows;
    
    % allocate the data array in the sub-tree
    alloc_length = length;
    if isscalar(length) alloc_length = [1 length];, end
    
    data = zeros(alloc_length, types.(field));
    
    % load field for entire tree? doing so is much faster than randomly accessing the disk 
    % during walk, assuming that the sub-tree is a large fraction of the full tree, and that 
    % the sub-tree is large in the absolute sense. the decision is heuristic, and can be 
    % modified (if you have the tree on a fast SSD, could disable the full load).
    if nRows < 1000
      % do not load, walk with single disk reads
      length(end) = 1;
      gdp = struct('dataset',['/' gName '/' field],'start',start,'length',length,'filePath',filePath);
      
      [count,data] = lhalotree.singleNodeFlat(conn, TreeIndex+1, 0, data, 0, onlyMPB, gdp);
    else
      % pre-load all, walk in-memory (use unmodified length)
      full_data = h5read(filePath, ['/' gName '/' field], start, shapes.(field));
      
      [count,data] = lhalotree.singleNodeFlat(conn, TreeIndex+1, full_data, data, 0, onlyMPB, 0);
    end
    
    % save field
    result.(field) = data;
  end
  
  % only a single field? then return the array instead of a single item hash
  if numel(fields) == 1, result = result.(fields{1});, end  
end
