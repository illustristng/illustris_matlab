% Illustris Simulation: Public Data Release.

function [count,data_out] = singleNodeFlat(conn,index,data_in,data_out,count,onlyMPB,gdp)
  % SINGLENODEFLAT  Recursive helper function: Add a single tree node.
  
  ndims = size(data_out);
  
  if numel(data_in) > 1
  
    % in-memory walk (data_in is the already read data array)
    if ndims(1) == 1
      data_out(count+1) = data_in(index);
    else
      data_out(:,count+1) = data_in(:,index);
    end
    
  else
  
    % on disk walk, read element we need (data_in is a hdf5 file_obj)
    start = gdp.('start');
    start(end) = index;
    
    single_read = h5read(gdp.('filePath'), gdp.('dataset'), start, gdp.('length'));
    
    if ndims(1) == 1
      data_out(count+1) = single_read;
    else
      data_out(:,count+1) = single_read;
    end
    
  end
  
  count = count + 1;
  
  [count,data_out] = illustris.lhalotree.recProgenitorFlat(conn,index,data_in,data_out,count,onlyMPB,gdp);  
end
