% Illustris Simulation: Public Data Release.

function [names,shapes,types] = hdf5_dset_properties(filePath, gName)
  % HDF5_DSET_PROPERTIES  Return names,lengths and datatypes of all group datasets.
  info = h5info(filePath,['/' gName '/']);

  names  = {};
  shapes = struct;
  types  = struct;
  
  for i = 1:numel(info.Datasets)
    name = info.Datasets(i).Name;
    type = info.Datasets(i).Datatype.Type;
    shape = info.Datasets(i).Dataspace.Size;
    
    % convert HDF5 datatypes to native MATLAB type string
    switch type
      case 'H5T_IEEE_F32LE'
        typeName = 'single';
      case 'H5T_IEEE_F64LE'
        typeName = 'double';
      case 'H5T_STD_U32LE'
        typeName = 'uint32';
      case 'H5T_STD_U64LE'
        typeName = 'uint64';
      otherwise
        error('Unknown HDF5 type [%s]', type)      
    end
    
    names{i}      = name;
    shapes.(name) = shape;
    types.(name)  = typeName;
  end
  
  
end
