global charDatasetPath;
global lpDatasetPath;

% Set these to the correct locations
charDatasetPath = '~/Pictures/char_dataset/';
lpDatasetPath = '~/Pictures/lp_dataset/';


% variable 'lp_data' is loaded with information about all images
load([lpDatasetPath '/lp_data']);


height = 30;
width = 15;
% Uncomment to construct some training data
tic
[inputs, targets] = create_training_data(height, width);
toc



view_training_data(inputs, height, width, 1);


% Uncomment to train a neural network on the data
net = patternnet(40);
net = init(net);
%net.trainParam.max_fail = 20;

trained_net = train(net, inputs', targets');
genFunction(trained_net, 'neural_char_recognition');


% Check network performance
%outputs = sim(trained_net,  inputs');
%[c confMat ind per] = confusion(targets', outputs);
%imagesc(confMat);

data = struct('regions', {}, 'predictedClasses', {}, 'trueClasses', {});

totalNum = 0;
numCorrect = 0;

for imgNr = 1:1
    
    im = load_training_image(imgNr);
    scale = get_training_scale_for_lp(lp_data(imgNr));
    [scaledIm, scaledBoundingBox] = pyramid_scale(im, lp_data(imgNr).boundingBox, scale);


    [preProcessedImage, regions] = perform_image_preprocessing(scaledIm);

    characterRegions = find_characters(regions);
    
    data(imgNr).regions = characterRegions;
    data(imgNr).trueClasses = get_region_true_classes(scaledBoundingBox, lp_data(imgNr).regNr, characterRegions);
    data(imgNr).predictedClasses = [];

    for i = 1:size(characterRegions, 1)
        x = regions(i, 1);
        y = regions(i, 2);
        w = regions(i, 3);
        h = regions(i, 4);
        
        regionAsInput = im2double(reshape(imresize(scaledIm(y:y+h, x:x+w), [height width]), [], 1));
        output = neural_char_recognition(regionAsInput);
        [m ind] = max(output);
        data(imgNr).predictedClasses(i) = ind;
        totalNum = totalNum + 1;
        
        if ind == data(imgNr).trueClasses(i)
            numCorrect = numCorrect + 1;
        end
    end
end

