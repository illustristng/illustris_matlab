% Illustris Simulation: Public Data Release.

function numMergers = numMergers(tree,minMassRatio,massPartType,index)
  % NUMMERGERS  Calculate the number of mergers in this sub-tree 
  %             (optionally above some mass ratio threshold).
  
  % set defaults
  if ~exist('minMassRatio','var'), minMassRatio = 1e-10;,   end
  if ~exist('massPartType','var'), massPartType = 'stars';, end
  if ~exist('index','var'),        index = 1;,              end
  
  % verify the input sub-tree has the required fields
  reqFields = {'SubhaloID','NextProgenitorID','MainLeafProgenitorID',...
               'FirstProgenitorID','SubhaloMassType'};
               
  for i=1:numel(reqFields)
    if ~sum(~cellfun('isempty',strfind(fieldnames(tree),reqFields{i})))
      error(['Input tree needs to have loaded fields: ' strjoin(reqFields,',')])
    end
  end
  
  % prepare output               
  numMergers   = 0;
  invMassRatio = 1.0 / minMassRatio;
  massPtNum    = illustris.partTypeNum(massPartType);
  
  % walk back main progenitor branch
  rootID = tree.('SubhaloID')(index);
  fpID   = tree.('FirstProgenitorID')(index);
  
  while fpID ~= -1
    fpIndex = index + (fpID - rootID);
    fpMass  = illustris.sublink.maxPastMass(tree, fpIndex, massPtNum);
    
    % explore breadth
    npID = tree.('NextProgenitorID')(fpIndex);
    
    while npID ~= -1
      npIndex = index + (npID - rootID);
      npMass  = illustris.sublink.maxPastMass(tree, npIndex, massPtNum);
      
      % count if both masses are non-zero, and ratio exceeds threshold
      if fpMass > 0.0 && npMass > 0.0
        ratio = npMass / fpMass;
        
        if ratio >= minMassRatio && ratio <= invMassRatio
          numMergers = numMergers + 1;
        end
      end
      
      npID = tree.('NextProgenitorID')(npIndex);
    end
    fpID = tree.('FirstProgenitorID')(fpIndex);
  end
  
end
