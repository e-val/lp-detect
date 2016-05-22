function [inputs, targets] = create_training_data(height, width)
    
    global charDatasetPath;
    global charClasses;
    
    fileIndexToClassMap = 'ABCDEFGHJKLMNOPQRSTUVWXYZ01234567893469';
    
    %bgClass = length(charClasses) + 1;
    
    numOutputClasses = length(charClasses);
    numSamples = length(fileIndexToClassMap);
    numRandomDistortions = 40;
    
    inputs = zeros(numSamples*(numRandomDistortions+1), width*height);
    targets = zeros(numSamples*(numRandomDistortions+1), numOutputClasses);
    
    currSample = 1;
    
    for i = 1:length(fileIndexToClassMap)
        charIm = im2double(imread(sprintf('%schar-%02d.png', charDatasetPath, i)));
        
        imBw = im2double(imbinarize(charIm, 'global'));
        
        scaledCharIm = scaleImToSize(imBw, height, width);
        inputs(currSample, :) = imToCol(scaledCharIm);
        targets(currSample, :) = createTargetVectorForClass(find(charClasses == fileIndexToClassMap(i)), numOutputClasses);    
        
        currSample = currSample + 1;
        
        for j = 1:numRandomDistortions
            if mod(j, 2) == 0
                distortedChar = randomlyApplyShearToCharacter(charIm);
            else
                distortedChar = randomlyDistortCharacter(charIm);
            end
            imBw = im2double(imbinarize(distortedChar, 'global'));
        
            scaledCharIm = scaleImToSize(imBw, height, width);
            if rand() > 0.5
                scaledCharIm = thinOrThickenCharacter(scaledCharIm);
            end
            inputs(currSample, :) = imToCol(scaledCharIm);
            targets(currSample, :) = createTargetVectorForClass(find(charClasses == fileIndexToClassMap(i)), numOutputClasses);
            currSample = currSample + 1;
        end
    end
    
end


function colIm = imToCol(Im)
    colIm = reshape(Im, 1, []);
end

function target = createTargetVectorForClass(index, numClasses)
    target = zeros(1, numClasses);
    target(index) = 1;
end

function result = randomlyDistortCharacter(originalChar)
%
%
    theta = rand()*1+0.4;
    theta2 = rand()*1+0.3;
    tform = projective2d([theta 0 rand()*0.005-0.0025;
                        0  theta2 rand()*0.002-0.001; 
                        0 0 1]);
    
    result = normalizeCharSize(imwarp(originalChar, tform)); 
end

function result = normalizeCharSize(inputChar)
    bw = imbinarize(inputChar, 'global');
    stats = regionprops(bw, 'BoundingBox', 'Area');
    
    [v ind] = max([stats(:).Area]);
    bBox = stats(ind).BoundingBox;
    x = max(1, floor(bBox(1)));
    y = max(1, floor(bBox(2)));
    w = min(floor(bBox(3)), size(inputChar, 2)-x);
    h = min(floor(bBox(4)), size(inputChar, 1)-y);
    result = inputChar(y:y+h, x:x+w);
end

function result = thinOrThickenCharacter(inputChar)
    if rand() > 0.5
        result = imdilate(inputChar, strel(ones(2, 2)));
    else
        result = imerode(inputChar, strel(ones(2, 2)));
    end
end

function result = randomlyApplyShearToCharacter(inputChar)
    
    tform = affine2d([1 0 0;
                      rand() - 0.5 1 0;
                      0 0 1]);
    result = normalizeCharSize(imwarp(inputChar, tform));
end

function result = addRandomGaussianNoise(inputChar)
    result = imnoise(inputChar,'salt & pepper',0.05);%awgn(inputChar, 15, 'measured');
end