global charDatasetPath;
global lpDatasetPath;

% Set these to the correct locations
charDatasetPath = '~/Pictures/char_dataset/';
lpDatasetPath = '~/Pictures/lp_dataset/';

% variable 'lp_data' is loaded with information about all images
load([lpDatasetPath '/lp_data']);

charMap = 'abcdefghjklmnopqrstuvwxyz0123456789';
allChars = [];
extractedChars = [];
wholePlates = 0;

for i = 1:188
    regNr = lp_data(i).regNr;
    
    for j = 1:length(regNr)
        pos = find(charMap == regNr(j));
        allChars = [allChars pos];
    end
    
    % Load the image and scale it to the "correct" scale for testing
    im = load_training_image(i);
    scale = get_training_scale_for_lp(lp_data(i));
    [scaledIm, scaledBoundingBox] = pyramid_scale(im, lp_data(i).boundingBox, scale);


    [preProcessedImage, regions] = perform_image_preprocessing(scaledIm);
    
    regionClasses = get_region_true_classes(scaledBoundingBox, lp_data(i).regNr, regions);
    
    num = 0;
    
    for j = 1:size(regionClasses, 1)
        if regionClasses(j) ~= 36
            extractedChars = [extractedChars regionClasses(j)];
            num = num + 1;
        end
    end
    
    if num == length(regNr)
        wholePlates = wholePlates + 1;
    end
    
end

wholePlates

%figure;histogram(allChars, length(charMap));
%figure;histogram(extractedChars, length(charMap));

