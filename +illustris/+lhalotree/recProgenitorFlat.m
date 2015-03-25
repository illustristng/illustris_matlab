% Illustris Simulation: Public Data Release.

function [count,data_out] = recProgenitorFlat(conn,start_index,data_in,data_out,count,onlyMPB,gdp)
  % RECPROGENITORFLAT  Recursive helper function: Flatten out the unordered LHaloTree, 
  %                    one data field at a time.
  import illustris.lhalotree.singleNodeFlat
  
  firstProg = conn.('FirstProgenitor')(start_index) + 1;
  
  if firstProg <= 0, return, end
  
  % depth-ordered traversal (down mpb)
  [count,data_out] = singleNodeFlat(conn,firstProg,data_in,data_out,count,onlyMPB,gdp);
  
  % explore breadth
  if ~onlyMPB
    nextProg = conn.('NextProgenitor')(firstProg) + 1;
    
    while nextProg >= 1
      [count,data_out] = singleNodeFlat(conn,nextProg,data_in,data_out,count,onlyMPB,gdp);
      nextProg = conn.('NextProgenitor')(nextProg) + 1;
    end
  end
  
  firstProg = conn.('FirstProgenitor')(firstProg) + 1;
  
end
