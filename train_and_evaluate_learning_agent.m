global charDatasetPath;
global lpDatasetPath;

% Set these to the correct locations
charDatasetPath = '~/Pictures/char_dataset_20.5/';
lpDatasetPath = '~/Pictures/lp_dataset/';


% variable 'lp_data' is loaded with information about all images
load([lpDatasetPath '/lp_data']);

% Input height and width
height = 30;
width = 15;

%Extract validation data from the image dataset
disp(['Extracting inputs and targets from license plate data set...']);
tic
[extractedInputs, extractedTargets, extractedLicensePlateIds] = extract_character_regions_from_all_images(lp_data, height, width);
toc

% Construct some training data
disp(['Creating training data...']);
tic
[trainInputs, trainTargets] = create_training_data(height, width);
toc
size(trainInputs)
view_training_data(trainInputs, height, width, 1);


net = patternnet(40);

numberOfTimesToTestNetwork = 10;

[performance, stability] = train_and_benchmark_neural_network(trainInputs, trainTargets, extractedInputs, extractedTargets, extractedLicensePlateIds, numberOfTimesToTestNetwork, net);
%performance
%stability
disp(sprintf('Average Performance over %d runs: %f', numberOfTimesToTestNetwork, mean(performance(:))));
disp(sprintf('Average Stability over %d runs: %f', numberOfTimesToTestNetwork, mean(stability(:))));

