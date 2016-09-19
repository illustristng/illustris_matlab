% Illustris Simulation: Public Data Release.

function [filePath] = treePath(basePath,treeName,chunkNum)
  % TREEPATH  Return absolute path to a SubLink HDF5 file (modify as needed).
  if ~exist('chunkNum','var')
    chunkNum = 0;
  end
  
  filePath = [basePath '/trees/' treeName '/tree_extended.' num2str(chunkNum) '.hdf5'];
  filePath = strjoin(filePath,'');

  if ~exist(strrep(filePath,'*','0'),'file')
    % new path scheme
    filePath = [basePath '/../postprocessing/trees/' treeName '/tree_extended.' num2str(chunkNum) '.hdf5'];
    filePath = strjoin(filePath,'');
  end
end
