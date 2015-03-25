% Illustris Simulation: Public Data Release.

function [header] = loadHeader(basePath, snapNum, chunkNum)
  % LOADHEADER  Load the snapshot header.
  if ~exist('chunkNum','var')
    chunkNum = 0;
  end
  
  filePath = illustris.snapshot.snapPath(basePath,snapNum,chunkNum);
  header = illustris.hdf5_all_attrs(filePath, 'Header');
end
