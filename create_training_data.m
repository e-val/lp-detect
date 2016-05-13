function [inputs, targets] = create_training_data(height, width)
    
    global charDatasetPath;
    
    charClasses = 'ABCDEFGHJKLMNOPQRSTUVWXYZ0123456789';
    bgClass = length(charClasses) + 1;
    
    numCharClasses = length(charClasses);
    
    inputs = zeros(numCharClasses, width*height);
    targets = zeros(numCharClasses, numCharClasses);
    
    for i = 1:length(charClasses)
        charIm = im2double(imread(sprintf('%schar-%02d.png', charDatasetPath, i)));
        scaledCharIm = imresize(charIm, [height width]);
        
        inputs(i, :) = imToCol(scaledCharIm);
        targets(i, :) = createTargetVectorForClass(i, numCharClasses);
        
    end
end


function colIm = imToCol(Im)
    colIm = reshape(imbinarize(Im, 'global'), 1, []);
end

function target = createTargetVectorForClass(index, numClasses)
    target = zeros(1, numClasses);
    target(index) = 1;
end

function scaledIm = scaleImToSize(Im, height, width)
    
    scaledIm = imresize(Im, [height NaN]);
    
    currWidth = size(scaledIm, 2);
    
    if currWidth > width
        scaledIm = imresize(Im, [height width]);
    elseif currWidth < width
        padVal = (width-size(scaledIm, 2))/double(2);
        sl = ceil(padVal);
        sr = floor(padVal);
        scaledIm = padarray(scaledIm, [0 sl], 0, 'pre');
        scaledIm = padarray(scaledIm, [0 sr], 0, 'post');
    end
    
end