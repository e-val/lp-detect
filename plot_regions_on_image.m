function result = plot_regions_on_image(img, regions)
    result = img;
    for i = 1:size(regions, 1)

        result = insertShape(result, 'Rectangle',  regions(i, :));
    end
end