function [extractedRegions, regionClasses, lpIds] = extract_character_regions_from_all_images(lp_data, height, width)

    numOutputClasses = 35;
    
    imagesToIgnore = [2 9 23 28 34 51 57 62 71 72 77 79 87 91 96 106 108 110 117 128 132 146 147 149 150 154 156 158 164 169 171 181 187];
    
    extractedRegions = [];
    regionClasses = [];
    lpIds = [];
    
    for imgNr = 1:188
        if sum(imagesToIgnore == imgNr) == 0
            im = load_training_image(imgNr);
            scale = get_training_scale_for_lp(lp_data(imgNr));
            [scaledIm, scaledBoundingBox] = pyramid_scale(im, lp_data(imgNr).boundingBox, scale);


            [preProcessedImage, regions] = perform_image_preprocessing(scaledIm);

            characterRegions = find_characters(regions);
                        
            trueClasses = get_region_true_classes(scaledBoundingBox, lp_data(imgNr).regNr, characterRegions);
                        
            for i = 1:size(characterRegions, 1)
                x = characterRegions(i, 1);
                y = characterRegions(i, 2);
                w = characterRegions(i, 3);
                h = characterRegions(i, 4);
                
                regionAsInput = im2double(reshape(scaleImToSize(preProcessedImage(y:y+h, x:x+w), height, width), 1, []));
                
                extractedRegions = [extractedRegions; regionAsInput];
                regionClasses = [regionClasses; createTargetVectorForClass(trueClasses(i), numOutputClasses)];
                lpIds = [lpIds; imgNr];
            end            
        end
    end

end

function target = createTargetVectorForClass(index, numClasses)
    target = zeros(1, numClasses);
    if index <= numClasses
        target(index) = 1;
    end
end