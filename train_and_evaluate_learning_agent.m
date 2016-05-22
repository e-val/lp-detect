global charDatasetPath;
global lpDatasetPath;
global charClasses;



% Set these to the correct locations
charDatasetPath = '~/Pictures/char_dataset_20.5-2/';
lpDatasetPath = '~/Pictures/lp_dataset/';
charClasses = 'ABCDEFGHJKLMNOPQRSTUVWXYZ0123456789';


% variable 'lp_data' is loaded with information about all images
load([lpDatasetPath '/lp_data']);

% Input height and width
height = 30;
width = 15;

%Extract validation data from the image dataset
disp(['Extracting inputs and targets from license plate data set ...']);
tic
[extractedInputs, extractedTargets, extractedLicensePlateIds] = extract_character_regions_from_all_images(lp_data, height, width);
toc

imagesc(confMats(1:35, :));


