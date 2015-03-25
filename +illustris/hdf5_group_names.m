% Illustris Simulation: Public Data Release.

function names = hdf5_group_names(filePath, gName)
  % HDF5_GROUP_NAMES  Return list of names of all groups (path within HDF5 file optional).
  if ~exist('gName','var'), gName = '';, end
  
  info = h5info(filePath,['/' gName]);

  names = {};
  
  for i = 1:numel(info.Groups)
    name = info.Groups(i).Name;
    names{i} = strrep(name,'/','');
  end
  
end
