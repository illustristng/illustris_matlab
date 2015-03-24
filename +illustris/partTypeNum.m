% Illustris Simulation: Public Data Release.

function [s] = partTypeNum(pt)
  % PARTTYPENUM  Mapping between common names and numeric particle types.
  
  % check if input is already numeric
  if isnumeric(pt)
    s = int32(pt);
    return
  end
  
  partType = lower(pt);
  
  if sum(strcmp(partType, {'gas','cells'}))
    s = int32(0);
    return
  elseif sum(strcmp(partType, {'dm','darkmatter'}))
    s = int32(1);
    return
  elseif sum(strcmp(partType, {'tracer','tracers','tracermc','trmc'}))
    s = int32(3);
    return
  elseif sum(strcmp(partType, {'star','stars','stellar'}))
    s = int32(4); % only those with GFM_StellarFormationTime>0
    return
  elseif sum(strcmp(partType, {'wind'}))
    s = int32(4); % only those with GFM_StellarFormationTime<0
    return
  elseif sum(strcmp(partType, {'bh','bhs','blackhole','blackholes'}))
    s = int32(5);
    return
  end
  
  if isnumeric(str2num(pt))
    s = int32(str2num(pt));
    return
  end
  
  error('Unknown type [%s]', partType)  
end
