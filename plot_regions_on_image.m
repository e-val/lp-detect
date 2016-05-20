function result = plot_regions_on_image(img, regions, trueClasses, boundingBox)
    result = img;
    str = 'ABCDEFGHJKLMNOPQRSTUVWXYZ0123456789';
    for i = 1:size(regions, 1)
        label = 'bg';
        if trueClasses(i) ~= 36
            label = str(trueClasses(i));
        end
        result = insertObjectAnnotation(result, 'rectangle', regions(i, :), label);
        %result = insertShape(result, 'Rectangle',  regions(i, :));
    end
    %    result = insertShape(result, 'Rectangle',  boundingBox, 'Color', 'blue');
    
end