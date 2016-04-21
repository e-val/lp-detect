function scale = get_training_scale_for_lp(lp)
    height = lp.boundingBox(4);
    scale = max(0, ceil(log2(height)-6));
end


