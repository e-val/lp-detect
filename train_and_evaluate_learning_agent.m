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

%view_training_data(inputs, height, width, 1);



numberOfTimesToTestNetwork = 5;
performance = zeros(1, numberOfTimesToTestNetwork);
stability = zeros(1, numberOfTimesToTestNetwork);
for time = 1:numberOfTimesToTestNetwork
    
    disp(sprintf('Creating and training neural network... (%d/%d)', time, numberOfTimesToTestNetwork));
    uniqueLicensePlates = unique(extractedLicensePlateIds);
    
    randomIndices = randperm(size(uniqueLicensePlates, 1));
        
    validationIndices = find(ismember(extractedLicensePlateIds, ...
                                      uniqueLicensePlates(randomIndices(1:floor(length(randomIndices)/2)))));
    testIndices = find(ismember(extractedLicensePlateIds, ...
                                      uniqueLicensePlates(randomIndices(floor(length(randomIndices)/2)+1:length(randomIndices)))));
    
    
    validationInputs = extractedInputs(validationIndices, :);
    validationTargets = extractedTargets(validationIndices, :);

    testInputs = extractedInputs(testIndices, :);
    testTargets = extractedTargets(testIndices, :);
        
    % Train a neural network on the data
    net = patternnet(40);
    net = init(net);
    
    net.divideFcn = 'divideind';
    net.divideParam.trainInd = 1:size(trainInputs, 1);
    net.divideParam.valInd = size(trainInputs, 1)+1:size(trainInputs, 1)+size(validationInputs, 1);
    net.divideParam.testInd = size(trainInputs, 1)+size(validationInputs, 1)+1:size(trainInputs, 1)+size(validationInputs, 1)+size(testInputs, 1);
    
    %net.trainParam.max_fail = 20;

    trained_net = train(net, [trainInputs' validationInputs' testInputs'], [trainTargets' validationTargets' testTargets']);

    % Check network performance
    testOutputs = sim(trained_net,  extractedInputs(testIndices, :)');
    %    [c confMat ind per] = confusion(extractedTargets', testOutputs);
    %    imagesc(confMat);

    [numRegions, numCorrectRegions, numLicensePlates, numCorrectPlates] = check_network_performance(testInputs, testOutputs', testTargets, extractedLicensePlateIds(testIndices));

    performance(time) = numCorrectRegions/numRegions;
    stability(time) = numCorrectPlates/numLicensePlates;
end
performance
stability
disp(sprintf('Average Performance over %d runs: %f', numberOfTimesToTestNetwork, mean(performance(:))));
disp(sprintf('Average Stability over %d runs: %f', numberOfTimesToTestNetwork, mean(stability(:))));

