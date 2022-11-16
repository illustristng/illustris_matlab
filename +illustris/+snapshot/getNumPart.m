% Illustris Simulation: Public Data Release.

function [nPart] = getNumPart(header)
  % GETNUMPART  Calculate number of particles of all types given a snapshot header.
  if ~ismember(header, 'NumPart_Total_HighWord')
    nPart = header.('NumPart_Total');
    return
  end

  nTypes = 6;
  nPart  = zeros([1 nTypes], 'uint64');
  
  for i = 1:nTypes
    low_word  = cast(header.('NumPart_Total')(i), 'uint64');
    high_word = cast(header.('NumPart_Total_HighWord')(i), 'uint64');
    
    nPart(i) = bitor( bitshift(high_word, 32), low_word );
  end

end
