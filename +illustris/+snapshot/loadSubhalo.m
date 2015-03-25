% Illustris Simulation: Public Data Release.

function [result] = loadSubhalo(basePath, snapNum, id, partType, fields)
  % LOADSUBHALO  Load all particles/cells of one type for a specific subhalo
  %              (optionally restricted to a subset fields).
  
  % load subhalo length, compute offset, call loadSnapSubset
  subset = illustris.snapshot.getSnapOffsets(basePath,snapNum,id,'Subhalo');
  
  if exist('fields','var')
    result = illustris.snapshot.loadSubset(basePath,snapNum,partType,fields,subset);
  else
    result = illustris.snapshot.loadSubset(basePath,snapNum,partType,{},subset);
  end
  
end
