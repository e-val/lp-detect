function [scaledIm, scaledBoundingBox] = pyramid_scale(img, boundingBox, scale)

    scaledIm = img;
    for s = 1:scale
        scaledIm = impyramid(scaledIm, 'reduce');
    end
    scaledBoundingBox = round(boundingBox .* 1/double(2^scale));

end