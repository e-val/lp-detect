function [performance, stability, confMats, performanceNice, stabilityNice] = train_and_benchmark_neural_network(trainInputs, trainTargets, extractedInputs, extractedTargets, extractedLicensePlateIds, numberOfTimesToTestNetwork, net)
    performance = zeros(1, numberOfTimesToTestNetwork);
    stability = zeros(1, numberOfTimesToTestNetwork);
    
    performanceNice = zeros(1, numberOfTimesToTestNetwork);
    stabilityNice = zeros(1, numberOfTimesToTestNetwork);
    
    global charClasses;
 
    confMats = [];
   
    for time = 1:numberOfTimesToTestNetwork
        
        disp(sprintf('Creating and training neural network ... (%d/%d)', time, numberOfTimesToTestNetwork));
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
        
        
        net = init(net);
        
        net.divideFcn = 'divideind';
        net.divideParam.trainInd = 1:size(trainInputs, 1);
        net.divideParam.valInd = size(trainInputs, 1)+1:size(trainInputs, 1)+size(validationInputs, 1);
        net.divideParam.testInd = size(trainInputs, 1)+size(validationInputs, 1)+1:size(trainInputs, 1)+size(validationInputs, 1)+size(testInputs, 1);
        
       
        

        
        % Train a neural network on the data
        trained_net = train(net, [trainInputs' validationInputs' testInputs'], [trainTargets' validationTargets' testTargets']);

        % Check network performance
        testOutputs = sim(trained_net, testInputs');
        [c confMat ind per] = confusion(testTargets', testOutputs);
        confMats = [confMats; confMat];
        %imagesc(confMat);
        if numberOfTimesToTestNetwork == 1
            for i = 1:size(testInputs, 1)
                imshow(reshape(testInputs(i, :), [30 15]));
                [v ind] = max(testOutputs(:, i));
                if ind <= length(charClasses) && v ~= 0;
                    title(charClasses(ind));
                else
                    title('fail');
                end
                waitforbuttonpress;
            end
        end

        [numRegions, numCorrectRegions, numLicensePlates, numCorrectPlates, numRegionsNice, numPlatesNice] = check_network_performance(testInputs, testOutputs', testTargets, extractedLicensePlateIds(testIndices));

        performance(time) = numCorrectRegions/numRegions;
        stability(time) = numCorrectPlates/numLicensePlates;
        
        performanceNice(time) = numRegionsNice/numRegions;
        stabilityNice(time) = numPlatesNice/numLicensePlates;
    end

end







