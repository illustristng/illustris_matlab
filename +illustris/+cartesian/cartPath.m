function [filePath] = cartPath(basePath, cartNum, chunkNum)
    % Return absolute path to a cartesian HDF5 file (modify as needed).
    filePath = [basePath '/cartesian_' num2str(cartNum,'%03d') '/cartesian_' num2str(cartNum,'%03d') '.' num2str(chunkNum') '.hdf5'];
end

