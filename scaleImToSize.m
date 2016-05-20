function scaledIm = scaleImToSize(Im, height, width)
    
    scaledIm = imresize(Im, [height NaN]);
    
    currWidth = size(scaledIm, 2);
    
    if currWidth > width
        scaledIm = imresize(Im, [height width]);
    elseif currWidth < width
        padVal = double(width-size(scaledIm, 2))/double(2);
        sl = ceil(padVal);
        sr = floor(padVal);
        scaledIm = padarray(scaledIm, [0 sl], 0, 'pre');
        scaledIm = padarray(scaledIm, [0 sr], 0, 'post');
    end
    
end