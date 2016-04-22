function [result, regions] = perform_image_preprocessing(img)

    sharpened = img + 4*(img - imfilter(img, fspecial('gaussian', 50, 3), 'symmetric'));

    img = sharpened;
    
    bot = imbothat(rgb2gray(img), strel(ones(60, 60)));
    top = imtophat(rgb2gray(img), strel(ones(60, 60)));

    topBin = imbinarize(top, 'global');
    botBin = imbinarize(bot, 'global');
    
    result = botBin - topBin;
    result(result == -1) = 0;
    
    %Show result before pruning of image regions
    %figure;imshow(result);
    
    
    CC = bwconncomp(result, 8);
    DT = bwdist(1-result,  'cityblock');
    
    stats = regionprops(CC, 'Eccentricity', 'EulerNumber', 'PixelIdxList', ...
                        'Extent', 'BoundingBox', 'MajorAxisLength', 'MinorAxisLength');
   
    
    for i = 1:length(stats)
        if stats(i).Eccentricity > 0.995 || ...
                stats(i).EulerNumber < -4 || ...
                stats(i).BoundingBox(3) > 60 || stats(i).BoundingBox(4) > 60 || ...
                stats(i).MajorAxisLength/stats(i).MinorAxisLength > 7 || ...
                stats(i).Extent < 0.15 || stats(i).Extent > 0.8 || ...
                max(DT(stats(i).PixelIdxList)) > 10
            
            
            result(stats(i).PixelIdxList) = 0;
        end
    end

    CC = bwconncomp(result, 8);
    stats = regionprops(CC, 'BoundingBox'); 
    
    
    bboxes = zeros(numel(stats), 4);
    for i = 1:numel(stats)
        bboxes(i, :) = stats(i).BoundingBox;
    end

    bboxes = merge_bounding_boxes(result, bboxes);

    newBBoxes = [];
    for i = 1:size(bboxes, 1)
        x = max(1, floor(bboxes(i, 1)));
        y = max(1, floor(bboxes(i, 2)));
        w = min(size(result, 2)-x, ceil(bboxes(i, 3)));
        h = min(size(result, 1)-y, ceil(bboxes(i, 4)));
        
        localCC = bwconncomp(result(y:y+h, x:x+w), 8);
        localStats = regionprops(localCC, 'Area');
        
        if h < 20 || w < 5 || h > 60 || numel(localStats) > 5
            result(y:y+h, x:x+w) = 0;
        else
            newBBoxes = [newBBoxes; bboxes(i, :)];
        end
    end
    
    regions = newBBoxes;
end


function regions = merge_bounding_boxes(img, bboxes)

    % Convert from the [x y width height] bounding box format to the [xmin ymin
    % xmax ymax] format for convenience.
    lastNumBoundingBoxes = 0;
    currNumBoundingBoxes = size(bboxes, 1);
    
    while(lastNumBoundingBoxes ~= currNumBoundingBoxes)
        
        
        xmin = bboxes(:,1);
        ymin = bboxes(:,2);
        xmax = xmin + bboxes(:,3) - 1;
        ymax = ymin + bboxes(:,4) - 1;

        
        % Expand the bounding boxes by a small amount.
        xExp = 0;
        yExp = 0;
        xmin = xmin - xExp;
        ymin = ymin - yExp;
        xmax = xmax + xExp;
        ymax = ymax + yExp;
        
        % Clip the bounding boxes to be within the image bounds
        xmin = max(xmin, 1);
        ymin = max(ymin, 1);
        xmax = min(xmax, size(img,2)-1);
        ymax = min(ymax, size(img,1)-1);
        
        % Show the expanded bounding boxes
        expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
        
        % Compute the overlap ratio
        overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);

        % Set the overlap ratio between a bounding box and itself to zero to
        % simplify the graph representation.
        n = size(overlapRatio,1);
        overlapRatio(1:n+1:n^2) = 0;

        % Create the graph
        g = graph(overlapRatio);

        % Find the connected text regions within the graph
        componentIndices = conncomp(g);
        
        % Merge the boxes based on the minimum and maximum dimensions.
        xmin = accumarray(componentIndices', xmin, [], @min);
        ymin = accumarray(componentIndices', ymin, [], @min);
        xmax = accumarray(componentIndices', xmax, [], @max);
        ymax = accumarray(componentIndices', ymax, [], @max);

        % Compose the merged bounding boxes using the [x y width height] format.
        bboxes = round([xmin ymin xmax-xmin+1 ymax-ymin+1]);
        
        lastNumBoundingBoxes = currNumBoundingBoxes;
        currNumBoundingBoxes = size(bboxes, 1);
        
    end
    
    regions = bboxes;
end
