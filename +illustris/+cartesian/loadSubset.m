function [result] = loadSubset(basePath, cartNum, fields, bbox, sq)
    % Load a subset of fields in the cartesian grids.
    % If bbox is specified, load only that subset of data. bbox should have the 
    % form [[start_i, start_j, start_k], [end_i, end_j, end_k]], where i,j,k are 
    % the indices for x,y,z dimensions. Notice the last index is *inclusive*.
    % If sq is true, return a numeric array instead of a struct if numel(fields)==1.
    import illustris.*

    if ~exist('sq','var'), sq = true;, end
    
    result = struct();
    
    % make sure fields is not a single element
    if ischar(fields)
        fields = {fields};
    end

    % load header from first chunk
    filePath = illustris.cartesian.cartPath(basePath, cartNum, 0);
    header = illustris.hdf5_all_attrs(filePath, 'Header');
    nPix = int64(illustris.cartesian.getNumPixel(header));
    
    % decide global read size, starting file chunk, and starting file chunk offset
    if exist('bbox', 'var')
        load_all = false;
        start_i = bbox(1, 1);
        start_j = bbox(1, 2);
        start_k = bbox(1, 3);
        end_i = bbox(2, 1);
        end_j = bbox(2, 2);
        end_k = bbox(2, 3);
        assert(start_i >= 0);
        assert(start_j >= 0);
        assert(start_k >= 0);
        assert(end_i < nPix);
        assert(end_j < nPix);
        assert(end_k < nPix);
    else
        load_all = true;
        bbox = [0, 0, 0; nPix-1, nPix-1, nPix-1];
    end
    
    numToRead = (bbox(2, 1)-bbox(1, 1)+1) * (bbox(2, 2)-bbox(1, 2)+1) * (bbox(2, 3)-bbox(1, 3)+1);

    if numToRead == 0
        return;
    end
    
    % if fields not specified, load everything
    filePath = cartesian.cartPath(basePath,cartNum,0);
    [field_names, shapes, types] = hdf5_dset_properties(filePath);
    
    if ~exist('fields','var') || ~numel(fields), fields = field_names;, end
    
    % make sure fields is not a single element
    if ~isa(fields,'cell'), fields = {fields};, end
    
    % loop over each requested field
    for i = 1:numel(fields)
        field = fields{i};
        
        if ~ismember(field,field_names)
          error('Cartesian output does not have field [%s]', field)
        end
        % replace local length with global
        shape = shapes.(field);
        if isscalar(shape), shape = [1 shape];, end
        shape(end) = numToRead;

        % allocate within return struct
        result.(field) = zeros(shape, types.(field));
    end

    % loop over chunks
    wOffset = 1;
    fileOffset = 0;
    origNumToRead = numToRead;
    fileNum = 0;

    while numToRead > 0
        data = h5read(cartesian.cartPath(basePath, cartNum, fileNum), [ '/' fields{1} ]);
        
        % set local read length for this file chunk, truncate to be within the local size
        numPixelsLocal = size(data, 1);

        if load_all
            pixToReadLocal = true(numPixelsLocal, 1);
            numToReadLocal = numPixelsLocal;
        else
            local_pixels_index = int64(fileOffset:(fileOffset + numPixelsLocal - 1));
            local_pixels_i = idivide(local_pixels_index, nPix^2, 'floor');
            local_pixels_j = idivide(local_pixels_index - local_pixels_i * nPix^2, nPix, 'floor');
            local_pixels_k = local_pixels_index - local_pixels_i * nPix^2 - local_pixels_j * nPix;

            pixToReadLocal = (local_pixels_i >= bbox(1, 1)) & (local_pixels_i <= bbox(2, 1)) & ...
                             (local_pixels_j >= bbox(1, 2)) & (local_pixels_j <= bbox(2, 2)) & ...
                             (local_pixels_k >= bbox(1, 3)) & (local_pixels_k <= bbox(2, 3));
            numToReadLocal = sum(pixToReadLocal);
        end

        % loop over each requested field for this particle type
        for i = 1:numel(fields)
            field = fields{i};
            data = h5read(cartesian.cartPath(basePath, cartNum, fileNum), [ '/' field ]);
            result.(field)(wOffset:(wOffset + numToReadLocal - 1)) = data(pixToReadLocal);
        end

        wOffset = wOffset + numToReadLocal;
        numToRead = numToRead - numToReadLocal;

        fileOffset = fileOffset + numPixelsLocal;
        fileNum = fileNum + 1;

    end
    
    % verify we read the correct number
    if origNumToRead ~= wOffset - 1
        error(['Read [' num2str(wOffset - 1) '] particles, but was expecting [' num2str(origNumToRead) ']']);
    end
    
    % only a single field? then return the array instead of a single item hash
    if sq & numel(fields) == 1, result = result.(fields{1});, end  
end
