% Illustris Simulation: Public Data Release.

function [filePath] = treePath(basePath,snapNum,chunkNum)
  % TREEPATH  Return absolute path to a LHaloTree HDF5 file (modify as needed).
  if ~exist('chunkNum','var')
    chunkNum = 0;
  end
  
  filePath = [basePath '/trees/treedata/' 'trees_sf1_135.' num2str(chunkNum) '.hdf5']; % TODO
end
