global charDatasetPath;
global lpDatasetPath;

% Set these to the correct locations
charDatasetPath = '~/Pictures/char_dataset/';
lpDatasetPath = '~/Pictures/lp_dataset/';


% variable 'lp_data' is loaded with information about all images
load([lpDatasetPath '/lp_data']);


%
% function load_training_image(index) loads an image with the corresponding index.
%
% function get_training_scale_for_lp(lp) takes an object from the lp_data array and returns the 
% correct scale that should be used when detecting the licence plate. (Used for testing)
%
% function pyramid_scale(image, boundingBox, scale) scales the corresponding image and boundingbox.
% 
% Ask me if there is something you dont understand!
imagesToIgnore = [2 9 23 28 34 51 57 62 71 72 77 79 87 91 96 106 108 110 117 128 132 146 147 149 150 154 156 158 164 169 171 181 187];

for imgNr = 98
    imgNr
    % Load the image and scale it to the "correct" scale for testing
    im = load_training_image(imgNr);
    scale = get_training_scale_for_lp(lp_data(imgNr));
    [scaledIm, scaledBoundingBox] = pyramid_scale(im, lp_data(imgNr).boundingBox, scale);


    [preProcessedImage, regions] = perform_image_preprocessing(scaledIm);

    characterRegions = find_characters(regions);

    trueClasses = get_region_true_classes(scaledBoundingBox, lp_data(imgNr).regNr, regions);


    % View the result
    imshow(plot_regions_on_image(im2double(preProcessedImage), regions, trueClasses, scaledBoundingBox));
    waitforbuttonpress
end

% View the original scaled image
%imtool(preProcessedImage);
