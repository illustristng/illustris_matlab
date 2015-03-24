% Illustris Simulation: Public Data Release.

function result = loadHalo(basePath, snapNum, id, partType, fields)
  % LOADHALO  load halo length, compute offset, call loadSnapSubset
  subset = illustris.snapshot.getSnapOffsets(basePath,snapNum,id,'Group');
  
  if exist('fields','var')
    result = illustris.snapshot.loadSubset(basePath,snapNum,partType,fields,subset);
  else
    result = illustris.snapshot.loadSubset(basePath,snapNum,partType,{},subset);
  end
  
end
