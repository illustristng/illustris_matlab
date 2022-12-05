% Illustris Simulation: Public Data Release.

function [filePath] = treePath(basePath,snapNum,chunkNum)
  % TREEPATH  Return absolute path to a LHaloTree HDF5 file (modify as needed).
  if ~exist('chunkNum','var')
    chunkNum = 0;
  end
  
  filePaths = {basePath + '/trees/treedata/' + 'trees_sf1_135.' + num2str(chunkNum) + '.hdf5';
               basePath + '/../postprocessing/trees/LHaloTree/trees_sf1_099.' + num2str(chunkNum) + '.hdf5';
               basePath + '/../postprocessing/trees/LHaloTree/trees_sf1_080.' + num2str(chunkNum) + '.hdf5'
              };

  for k = 1:length(filePaths)
    if exist(strcat(filePaths{k}),'file')
        % new path scheme
        filePath = filePaths{k};
    end
  end

end
