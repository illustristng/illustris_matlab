% Illustris Simulation: Public Data Release.

function [filePath] = offsetPath(basePath,snapNum)
  % OFFSETPATH  Return absolute path to a separate offset file (modify as needed).
  filePath = [basePath '../postprocessing/offsets/offsets_' num2str(snapNum,'%03d') '.hdf5'];
  filePath = strjoin(filePath,'');
end
