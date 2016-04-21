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
% correct scale that should be used when detecting the licence plate.
%
% function pyramid_scale(image, boundingBox, scale) scales the corresponding image and boundingbox.
% 
% Ask me if there is something you dont understand!


imgNr = 1;

% Load the image and scale it to the "correct" scale for testing
im = load_training_image(imgNr);
scale = get_training_scale_for_lp(lp_data(imgNr));
[scaledIm, scaledBoundingBox] = pyramid_scale(im, lp_data(imgNr).boundingBox, scale);

% This is where the magic happens..
[preProcessedImage, regions] = perform_image_preprocessing(scaledIm);

% View the result
figure;imshow(plot_regions_on_image(im2double(preProcessedImage), regions));

% View the original scaled image
%imtool(scaledIm);

