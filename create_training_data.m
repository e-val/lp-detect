function [inputs, targets] = create_training_data(height, width)
    
    global charDatasetPath;
    
    charClasses = 'ABCDEFGHJKLMNOPQRSTUVWXYZ0123456789';
    fileIndexToClassMap = 'ABCDEFGHJKLMNOPQRSTUVWXYZ01234567893469';
    
    %bgClass = length(charClasses) + 1;
    
    numOutputClasses = length(charClasses);
    numSamples = length(fileIndexToClassMap);
    
    inputs = zeros(numSamples, width*height);
    targets = zeros(numSamples, numOutputClasses);
    
    for i = 1:length(fileIndexToClassMap)
        charIm = im2double(imread(sprintf('%schar-%02d.png', charDatasetPath, i)));
        imBw = im2double(imbinarize(charIm, 'global'));
        
        scaledCharIm = scaleImToSize(imBw, height, width);
        
        inputs(i, :) = imToCol(scaledCharIm);
        targets(i, :) = createTargetVectorForClass(find(charClasses == fileIndexToClassMap(i)), numOutputClasses);    
    end
    
end


function colIm = imToCol(Im)
    colIm = reshape(Im, 1, []);
end

function target = createTargetVectorForClass(index, numClasses)
    target = zeros(1, numClasses);
    target(index) = 1;
end
