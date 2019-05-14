function [output_t] = transform_scenes(output, rotIds, t_opt)
% Transform the scenes
numScenes = size(output,1);
output_t = output;
for sceneId = 1 : numScenes
    theta = (rotIds(sceneId)-1)*pi/2;
    R = [cos(theta),-sin(theta);sin(theta), cos(theta)];
    t = t_opt(sceneId,:);
    out = reshape(output(sceneId, :,:), [120,11]);
    ids = find(out(:,1) == 1);
    out2 = out(ids,:);
    out2(:,2:3) = out2(:,2:3)*R' + ones(size(out2,1),1)*t;
    out2(:,8:9) = out2(:,8:9)*R';
    out(ids,:) = out2;

    %%% Offset the scene to the origin
    boxI = layout_bbox(out);
    centerI = (boxI(:,1) + boxI(:,2))/2;
    ids = find(out(:,1) == 1);
    out(ids, 2:3) = out(ids,2:3) - centerI';
    
    output_t(sceneId, :,:) = out;
end

function [box] = layout_bbox(layout)
%
ids = find(layout(:,1));
layout = layout(ids,:);
box = [min(layout(:,2:3))', max(layout(:,2:3))'];