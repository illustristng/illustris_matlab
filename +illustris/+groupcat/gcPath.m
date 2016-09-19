% Illustris Simulation: Public Data Release.

function [filePath] = gcPath(basePath,snapNum,chunkNum)
  % GCPATH  Return absolute path to a group catalog HDF5 file (modify as needed).
  if ~exist('chunkNum','var')
    chunkNum = 0;
  end
  
  gcPath = [basePath '/groups_' num2str(snapNum,'%03d') '/'];
  filePath = [gcPath 'groups_' num2str(snapNum,'%03d') '.' num2str(chunkNum) '.hdf5'];
  filePath = strjoin(filePath,'');

  if exist(filePath,'file')
    return
  end

  % new path scheme
  filePath = [gcPath 'fof_subhalo_tab_' num2str(snapNum,'%03d') '.' num2str(chunkNum) '.hdf5'];
  filePath = strjoin(filePath,'');
end
