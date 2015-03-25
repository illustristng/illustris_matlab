% Illustris Simulation: Public Data Release.

function [gc] = load(basePath, snapNum)
  % LOAD  Load complete group catalog all at once.
  import illustris.groupcat.*
  
  gc = struct;
  
  gc.('subhalos') = loadSubhalos(basePath,snapNum);
  gc.('halos')    = loadHalos(basePath,snapNum);
  gc.('header')   = loadHeader(basePath,snapNum);
end
