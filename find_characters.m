function characterRegions = find_characters(regions)

    characterRegions = [];
    
    for i = 1 : size(regions, 1)
        
        %the row value of top edge of boundingbox
        y = regions(i, 2);
        h = regions(i, 4);
        
        %create row candidate index array to find similar edge on image
        row_candidate_index = find(regions(:, 2) > y-3 & regions(:, 2) < y+3 ...
                                  & regions(:, 4) > h-3 & regions(:, 4) < h+3);
        
        if size(row_candidate_index, 1) == 6
            for j = 1:6
                characterRegions = [characterRegions; regions(row_candidate_index(j), :)];
            end

            break; % we found characters
        end
    end
    
end