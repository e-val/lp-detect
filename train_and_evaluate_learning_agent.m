global charDatasetPath;
global lpDatasetPath;

% Set these to the correct locations
charDatasetPath = '~/Pictures/char_dataset_18.5/';
lpDatasetPath = '~/Pictures/lp_dataset/';


% variable 'lp_data' is loaded with information about all images
load([lpDatasetPath '/lp_data']);


height = 30;
width = 15;



%Extract validation data from the image dataset
[validationInputs, validationTargets, inputLicensePlateIds] = extract_character_regions_from_all_images(lp_data, height, width);


% Construct some training data
tic
[inputs, targets] = create_training_data(height, width);
toc

%view_training_data(inputs, height, width, 1);



% Train a neural network on the data
net = patternnet(40);
net = init(net);
net.divideFcn = 'dividetrain';
%net.trainParam.max_fail = 20;

trained_net = train(net, inputs', targets');
%genFunction(trained_net, 'neural_char_recognition');



% Check network performance
validationOutputs = sim(trained_net,  validationInputs');
[c confMat ind per] = confusion(validationTargets', validationOutputs);
imagesc(confMat);

[numRegions, numCorrectRegions, numLicensePlates, numCorrectPlates] = check_network_performance(validationInputs, validationOutputs', validationTargets, inputLicensePlateIds);

disp(sprintf('Regions: %d/%d (%f)', numCorrectRegions, numRegions, numCorrectRegions/numRegions));
disp(sprintf('Plates: %d/%d (%f)', numCorrectPlates, numLicensePlates, numCorrectPlates/numLicensePlates));