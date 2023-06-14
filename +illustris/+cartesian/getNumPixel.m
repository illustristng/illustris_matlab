function [numPixels] = getNumPixel(header)
    % Calculate number of pixels (per dimension) given a cartesian header.
    numPixels = header.NumPixels;
end
