function [numRegions numCorrectRegions numLicensePlates numCorrectPlates, numCorrectRegionsNice, numCorrectPlatesNice] = check_network_performance(inputs, outputs, targets, inputLicensePlateIds)
    global charClasses;
    numLicensePlates = size(unique(inputLicensePlateIds), 1);
    numCorrectPlates = 0;

    numRegions = size(inputs, 1);
    numCorrectRegions = 0;
    
    numCorrectRegionsNice = 0;
    numCorrectPlatesNice = 0;

    for plateId = unique(inputLicensePlateIds)'
        indicesForPlate = find(inputLicensePlateIds == plateId);
        
        correctlyClassifiedAll = true;
        correctlyClassifiedAllNice = true;
        
        for i = indicesForPlate'
            
            [~, predictedClass] = max(outputs(i, :));
            [check, trueClass] = max(targets(i, :));

            if predictedClass == trueClass && check ~= 0
                numCorrectRegions = numCorrectRegions + 1;
            else
                correctlyClassifiedAll = false;
            end
            
            zeroClass = find(charClasses == '0');
            OClass = find(charClasses == 'O');
            
            confusedZeroAndO = (predictedClass == zeroClass && trueClass == OClass) || ...
                (trueClass == zeroClass && predictedClass == OClass);
            
            if (predictedClass == trueClass || confusedZeroAndO) && check ~= 0
                numCorrectRegionsNice = numCorrectRegionsNice + 1;
            else
                correctlyClassifiedAllNice = false;
            end
        end
        
        if correctlyClassifiedAll
            numCorrectPlates = numCorrectPlates + 1;
        end
        
        if correctlyClassifiedAllNice
            numCorrectPlatesNice = numCorrectPlatesNice + 1;
        end
        
    end


end