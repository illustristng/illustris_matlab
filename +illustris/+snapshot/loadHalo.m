% Illustris Simulation: Public Data Release.

function [result] = loadHalo(basePath, snapNum, id, partType, fields)
  % LOADHALO  Load all particles/cells of one type for a specific halo
  %           (optionally restricted to a subset fields).
  
  % load halo length, compute offset, call loadSnapSubset
  subset = illustris.snapshot.getSnapOffsets(basePath,snapNum,id,'Group');
  
  if exist('fields','var')
    result = illustris.snapshot.loadSubset(basePath,snapNum,partType,fields,subset);
  else
    result = illustris.snapshot.loadSubset(basePath,snapNum,partType,{},subset);
  end
  
end
