function [numRegions numCorrectRegions numLicensePlates numCorrectPlates] = check_network_performance(inputs, outputs, targets, inputLicensePlateIds)

    numLicensePlates = size(unique(inputLicensePlateIds), 1);
    numCorrectPlates = 0;

    numRegions = size(inputs, 1);
    numCorrectRegions = 0;

    for plateId = unique(inputLicensePlateIds)'
        indicesForPlate = find(inputLicensePlateIds == plateId);
        
        correctlyClassifiedAll = true;
        
        for i = indicesForPlate'
            
            [~, predictedClass] = max(outputs(i, :));
            [check, trueClass] = max(targets(i, :));

            if predictedClass == trueClass && check ~= 0
                numCorrectRegions = numCorrectRegions + 1;
            else
                correctlyClassifiedAll = false;
            end
        end
        
        if correctlyClassifiedAll
            numCorrectPlates = numCorrectPlates + 1;
        end
    end


end