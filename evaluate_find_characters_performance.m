global charDatasetPath;
global lpDatasetPath;

% Set these to the correct locations
charDatasetPath = '~/Pictures/char_dataset/';
lpDatasetPath = '~/Pictures/lp_dataset/';


% variable 'lp_data' is loaded with information about all images
load([lpDatasetPath '/lp_data']);



performance = [];

for imgNr = 1:188
    
    % Load the image and scale it to the "correct" scale for testing
    im = load_training_image(imgNr);
    scale = get_training_scale_for_lp(lp_data(imgNr));
    [scaledIm, scaledBoundingBox] = pyramid_scale(im, lp_data(imgNr).boundingBox, scale);


    [preProcessedImage, regions] = perform_image_preprocessing(scaledIm);

    characterRegions = find_characters(regions);

    performance = [performance; find_characters_performance(scaledBoundingBox, length(lp_data(imgNr).regNr), characterRegions)];
    
end

disp(sprintf('Successfully segmented %d out of %d license plate character', sum(performance(:, 1)), sum(performance(:, 3))));
disp(sprintf('%d out of %d license plates were fully segmented', sum(performance(:, 1) == performance(:, 3)), size(performance, 1)));
disp(sprintf('%d regions were falsly segmented as characters', sum(performance(:, 2))));