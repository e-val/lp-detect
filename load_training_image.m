function img = load_training_image(index)
    global lpDatasetPath;

    img = uint8(imread(sprintf('%s/lp-%d.png', lpDatasetPath, index)));
end