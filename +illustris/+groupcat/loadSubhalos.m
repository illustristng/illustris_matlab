function [result] = loadSubhalos(basePath,snapNum,fields)
  % LOADSUBHALOS  Load all subhalo information from the entire group catalog for one snapshot
  %               (optionally restrict to a subset given by fields).
  
  if exist('fields','var')
    result = illustris.groupcat.loadObjects(basePath,snapNum,'Subhalo','subgroups',fields);
  else
    result = illustris.groupcat.loadObjects(basePath,snapNum,'Subhalo','subgroups');
  end
end
