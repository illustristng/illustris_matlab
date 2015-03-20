function [result] = loadHalos(basePath,snapNum,fields)
  % LOADHALOS  Load all halo information from the entire group catalog for one snapshot
  %            (optionally restrict to a subset given by fields).
  
  if exist('fields','var')
    result = illustris.groupcat.loadObjects(basePath,snapNum,'Group','groups',fields);
  else
    result = illustris.groupcat.loadObjects(basePath,snapNum,'Group','groups');
  end
end
