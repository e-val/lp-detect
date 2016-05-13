function plateCharacterRegions = find_plate_character_regions_in_preprocessed_image(regions)
% The goal of this function is to find the regions in the preprocessed image
% that most likely correspond to license plate characters.
% This is done by evaluating the position and size of all regions to find the 
% ones that correlate the most.
    
    heightVarianceMargin = 5;
    distanceVarianceMargin = 50;
    positionVarianceMargin = 5;
    
    for i = 1:size(regions, 1)
        currentPoints = regions(i, :);
        
        for j = (i+1):size(regions, 1)
            if abs(regions(j, 4) - currentPoints(1, 4)) < heightVarianceMargin
                currentPoints = [currentPoints; regions(j, :)];
            end
        end
    end

end