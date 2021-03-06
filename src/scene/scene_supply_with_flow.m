function scene_supply_with_flow(pspnet_root, flow_root, interval, video_name)
if nargin==3
    pspnet_scene_videos = dir(fullfile(pspnet_root,'gray','*'));
    for i = 3:length(pspnet_scene_videos)
        pspnet_scene_video = pspnet_scene_videos(i);
        video_pspnet_gray_path = fullfile(pspnet_root, 'gray', pspnet_scene_video.name);
        video_pspnet_color_path = fullfile(pspnet_root, 'color', pspnet_scene_videos.name);
        video_flow_path = fullfile(flow_root, pspnet_scene_video.name);
        proccess_video(video_pspnet_gray_path, video_flow_path, interval, 'png');
        proccess_video(video_pspnet_color_path, video_flow_path, interval, 'png');
    end
end
if nargin==4
    video_pspnet_gray_path = fullfile(pspnet_root, 'gray', video_name);
    video_pspnet_color_path = fullfile(pspnet_root, 'color', video_name);
    video_flow_path = fullfile(flow_root, video_name);
    proccess_video(video_pspnet_gray_path, video_flow_path, interval, 'png');
    proccess_video(video_pspnet_color_path, video_flow_path, interval, 'png');
end


function proccess_video(video_pspnet_root, video_flow_root, interval, ext)
flows = dir(fullfile(video_flow_root, '*.flo'));
frame_sum = length(flows);
for i = 1:interval:frame_sum
    frame_id = num2str(i, '%07d');
    scene_path = fullfile(video_pspnet_root, [frame_id, '.', ext]);
    scene = imread(scene_path);
    for j = i:min((i+interval)-2, frame_sum)
        frame_id = num2str(j, '%07d');
        flow_path = fullfile(video_flow_root, [frame_id, '.flo']);
        next_frame_id = num2str(j+1, '%07d');
        estimated_scene_path = fullfile(video_pspnet_root, [next_frame_id, '.', ext]);
        if ~exist(estimated_scene_path, 'file')
            flow = readFlowFile(flow_path);
            scene = estimate_with_flow(scene, flow);
        end
        imwrite(uint8(scene), estimated_scene_path);
    end
end

function result = estimate_with_flow(org_mat, flow)
[h,w,~] = size(flow);
result = zeros(size(org_mat));
for r = 1:h
    for c = 1:w
        delta_x = flow(r, c, 1);
        delta_y = flow(r, c, 2);
        des_r = r + delta_y;
        des_r = min(des_r, h);
        des_r = round(max(des_r, 1));
        des_c = c + delta_x;
        des_c = min(des_c, w);
        des_c = round(max(des_c, 1));
        result(des_r, des_c, :) = org_mat(r, c, :); 
    end
end
