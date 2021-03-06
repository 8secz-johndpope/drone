function motion_map = extract_moving_region_v4(scene_map, flow, background_labels)
    background_map = false(size(scene_map));
    [h,w,~] = size(flow);
    for i = 1:length(background_labels)
        background_map = background_map | (scene_map == background_labels(i));
    end
    flow_x = flow(:,:,1);
    flow_y = flow(:,:,2);
    org_motion = sqrt(flow_x .^ 2 + flow_y .^ 2);
    overall_background_motion = mean(org_motion(background_map));
    part_height = 100;
    motion_map = zeros(h,w);
    for x = 1:10:h
        part_top = x;
        part_bottom = min(x+part_height-1, h);
        part_background_map = background_map(part_top:part_bottom,:);
        part_motion = org_motion(part_top:part_bottom,:);
        part_background_motion = mean(part_motion(part_background_map));
        if part_background_motion > 0
            part_motion(part_motion <= part_background_motion) = 0;
        else
            part_motion(part_motion <= overall_background_motion) = 0;
        end
        motion_map(part_top:part_bottom,:) = part_motion;
    end
    filter_size = 4;
    filter = ones(filter_size,filter_size);
    motion_map = imfilter(motion_map,filter,'replicate');
    motion_map(motion_map > 0) = 1;
    motion_map(background_map) = 0;