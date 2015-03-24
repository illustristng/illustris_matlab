% Illustris Simulation: Public Data Release.

function mass = maxPastMass(tree,index,ptNum)
  % MAXPASTMASS  Get maximum past mass (of the given partType number) along the main branch 
  %              of a subhalo specified by index within this tree.
  
  branchSize = tree.('MainLeafProgenitorID')(index) - tree.('SubhaloID')(index) + 1;
  masses = tree.('SubhaloMassType')(ptNum+1, index:index+branchSize-1);
  
  mass = max(masses);
end
