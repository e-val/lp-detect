function [inputs, targets] = create_training_data(height, width)
    
    global charDatasetPath;
    
    charClasses = 'ABCDEFGHJKLMNOPQRSTUVWXYZ0123456789';
    fileIndexToClassMap = 'ABCDEFGHJKLMNOPQRSTUVWXYZ01234567893469';
    
    %bgClass = length(charClasses) + 1;
    
    numOutputClasses = length(charClasses);
    numSamples = length(fileIndexToClassMap);
    numRandomDistortions = 10;
    
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
            
            distortedChar = randomlyDistortCharacter(charIm);
            imBw = im2double(imbinarize(distortedChar, 'global'));
        
            scaledCharIm = scaleImToSize(imBw, height, width);
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
    tform = projective2d([theta 0 rand()*0.005 - 0.0025;
                        0  theta2 rand()*0.002-0.001; 
                        0 0 1]);
    
    
    result = imwarp(originalChar, tform);
    
end

function result = addRandomGaussianNoise(inputChar)
    result = imnoise(inputChar,'salt & pepper',0.05);%awgn(inputChar, 15, 'measured');
end