function result = view_training_data(inputs, height, width, pos)

    check = zeros(height*100, width*100);

    for h = 2:100
        for w = 2:100
            if pos > size(inputs, 1)
                break;
            end
            im = reshape(inputs(pos, :), [height width]);
            check((h-1)*height+1:h*height, (w-1)*width+1:w*width) = im;
            pos = pos +1;
        end
    end
    imtool(check);

end