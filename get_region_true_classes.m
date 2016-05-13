function trueClasses = get_region_true_classes(boundingBox, regNr, allRegions)
    
    charClasses = 'abcdefghjklmnopqrstuvwxyz0123456789';
    bgClass = length(charClasses) + 1;
   
    
    totalNum = size(allRegions, 1);
    trueClasses = zeros(totalNum, 1);
    trueClasses(:) = bgClass;
    %Atleast some regions were segmented
    if totalNum > 0

        overlapRatio = bboxOverlapRatio(allRegions, boundingBox, 'Min');
        
        
        regionsInBoundingBoxIndices = (overlapRatio > 0.95);
        
        charRegionIndices = getCharRegionsBasedOnSize(allRegions, regionsInBoundingBoxIndices);

        %Atleast some characters were segmented
        if size(charRegionIndices, 1) > 0

            %Sort the indices according to their region's x-coordinate
            for i = 1:size(charRegionIndices, 1)
                minEl = i;
                for j = i+1:size(charRegionIndices, 1)
                    if allRegions(charRegionIndices(j), 1) < allRegions(charRegionIndices(i), 1)
                        minEl = j;     
                    end
                end
                tmp = charRegionIndices(i);
                charRegionIndices(i) = charRegionIndices(minEl);
                charRegionIndices(minEl) = tmp;
            end
            
            avgCharWidth = max(allRegions(charRegionIndices(:), 3));
            currPos = 1;
            
            for i = 1:size(charRegionIndices, 1)
                minPos = currPos;
                maxPos = currPos + length(regNr(currPos:end)) - (size(charRegionIndices, 1)-i) -1;

                if minPos == maxPos
                    trueClasses(charRegionIndices(i)) = find(charClasses == regNr(currPos));
                    currPos = currPos + 1;
                elseif minPos < maxPos
                    if currPos == 1
                        charDistance = allRegions(charRegionIndices(i), 1) - boundingBox(1);
                        num = 1 + round(double(charDistance)/double(avgCharWidth));
                    else
                        charDistance = allRegions(charRegionIndices(i), 1) - allRegions(charRegionIndices(i-1), 1);
                        num = round(double(charDistance)/double(avgCharWidth));
                    end
                    
                    num = max(minPos, min(maxPos, num));
                    
                    trueClasses(charRegionIndices(i)) = find(charClasses == regNr(num));
                    currPos = num +1;
                end
            end
            
        end
    end
    
end

function charRegionIndices = getCharRegionsBasedOnSize(regions, regionsInBoundingBoxIndices)
    heightMargin = 4;
    charRegionIndices = [];
    
    regionsInBoundingBoxIndices = find(regionsInBoundingBoxIndices);
    
    for i = regionsInBoundingBoxIndices

            currHeight = regions(i, 4);  

            curr = find((regions(regionsInBoundingBoxIndices, 4) <= currHeight + heightMargin) ...
                   & (regions(regionsInBoundingBoxIndices, 4) >= currHeight - heightMargin));

            if size(curr, 1) > size(charRegionIndices, 1)
                charRegionIndices = regionsInBoundingBoxIndices(curr);
            end

    end
    
    
end






