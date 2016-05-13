function performance = find_characters_performance(boundingBox, targetNrRegions, foundCharacterRegions)
    if size(foundCharacterRegions, 1) > 0
        overlapRatio = bboxOverlapRatio(foundCharacterRegions, boundingBox, 'Min');
        
        numTruePositive = sum(overlapRatio > 0.95);
        numFalsePositive = sum(overlapRatio <= 0.95);
    else
        numTruePositive = 0;
        numFalsePositive = 0;
    end
    
    targetNum = targetNrRegions;
    
    performance = [numTruePositive, numFalsePositive, targetNum];
end

