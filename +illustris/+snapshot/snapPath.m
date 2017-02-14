% Illustris Simulation: Public Data Release.

function [filePath] = snapPath(basePath,snapNum,chunkNum)
  % SNAPPATH  Return absolute path to a snapshot HDF5 file (modify as needed).
  if ~exist('chunkNum','var')
    chunkNum = 0;
  end
  
  snapPath = [basePath '/snapdir_' num2str(snapNum,'%03d') '/'];
  filePath = [snapPath 'snap_' num2str(snapNum,'%03d') '.' num2str(chunkNum) '.hdf5'];
end
