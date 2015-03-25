% Illustris Simulation: Public Data Release.

function [filePath] = treePath(basePath,snapNum,chunkNum)
  % TREEPATH  Return absolute path to a SubLink HDF5 file (modify as needed).
  if ~exist('chunkNum','var')
    chunkNum = 0;
  end
  
  filePath = [basePath '/trees/SubLink/' 'tree_extended.' num2str(chunkNum) '.hdf5'];
end
