% Illustris Simulation: Public Data Release.

function [s] = hdf5_all_attrs(filePath, gName)
  % HDF5_ALL_ATTRS  Return struct of all group attributes.
  info = h5info(filePath,['/' gName '/']);

  s = struct;
  
  for i = 1:numel(info.Attributes)
    name = info.Attributes(i).Name;
    value = info.Attributes(i).Value;
    s.(name) = value;
  end
  
end