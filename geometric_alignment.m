function [rot_type,t, score] = geometric_alignment(layoutI, layoutII)
layoutI = reshape(layoutI(:,:,[1,2,3,5,6,8,9]), [120,7]);
layoutII = reshape(layoutII(:,:,[1,2,3,5,6,8,9]), [120,7]);
% Change object sizes to aspect ratios
tp = min(layoutI(:,4:5)')';
tp2 = max(layoutI(:,4:5)')';
layoutI(:,4) = tp;
layoutI(:,5) = tp2;
% Change object sizes to aspect ratios
tp = min(layoutII(:,4:5)')';
tp2 = max(layoutII(:,4:5)')';
layoutII(:,4) = tp;
layoutII(:,5) = tp2;
% Change the location of each empty object to be the center of each room
% Layout I
boxI = layout_bbox(layoutI);
centerI = (boxI(:,1) + boxI(:,2))/2;
ids = find(layoutI(:,1) == 0);
layoutI(ids, 2:3) = ones(length(ids),1)*centerI';

% Layout II
boxII = layout_bbox(layoutII);
centerII = (boxII(:,1) + boxII(:,2))/2;
ids = find(layoutII(:,1) == 0);
layoutII(ids, 2:3) = ones(length(ids),1)*centerII';

rot_type = 0;
t = zeros(2,1);
score = 1e10;
for rotId = 1 : 4
    layoutI_rotated = rotate_scene(layoutI, rotId);
    [score_cur, t_cur] = alter_min(layoutI_rotated, layoutII);
    if score_cur < score
        score = score_cur;
        rot_type = rotId;
        t = t_cur;
    end
end

%
function [score, t] = alter_min(layoutI, layoutII)
%
perms = permutation(4);
t = zeros(1,2);
% You can pick an important category to increase the weight in the process
iId = -1; 

for iter = 1 : 2
    layoutI_cur = layoutI;
    layoutI_cur(:,2:3) = layoutI_cur(:,2:3) + ones(120,1)*t;
    score = 0;
    for cId = 1 : 30
        ids = (4*cId-3):(4*cId);
        [sqrNorm, blockI] = category_difference(layoutI_cur(ids,:),...
            layoutII(ids,:),...
            perms);
        layoutI_cur(ids,:) = blockI;
        if cId == iId 
            sqrNorm = sqrNorm * 4;
        end
        score = score + sqrNorm;
    end
    % Compute the displacement on the translation
    t(1) = t(1) + mean(layoutII(:,2)) - mean(layoutI_cur(:,2));
    t(2) = t(2) + mean(layoutII(:,3)) - mean(layoutI_cur(:,3));
end
%
function [sqrNorm, blockI_new] = category_difference(blockI, blockII, perms)
%
best_id = 0;
sqrNorm = 1e10;
for id = 1 : size(perms, 1)
    dif = blockI(perms(id,:),:) - blockII;
    sqrNorm_cur = sum(sum(dif.*dif));
    if sqrNorm_cur < sqrNorm
        best_id = id;
        sqrNorm = sqrNorm_cur;
    end
end
blockI_new = blockI(perms(best_id,:),:);

function [box] = layout_bbox(layout)
%
ids = find(layout(:,1));
layout = layout(ids,:);
box = [min(layout(:,2:3))', max(layout(:,2:3))'];

function [perms] = permutation(order)
if order == 1
    perms = [1];
    return;
end
buf = permutation(order-1);
dim1 = size(buf, 1);
perms = ones(order*dim1, order)*order;
for i = 1 : order
    perms(((i-1)*dim1+1):(i*dim1),1:(i-1)) = buf(:,1:(i-1));
    perms(((i-1)*dim1+1):(i*dim1),(i+1):order) = buf(:,i:(order-1));
end


function [layout_rotated] = rotate_scene(layout, type)
%
layout_rotated = layout;
if type == 1
    layout_rotated(:,1) = layout(:,1);
    layout_rotated(:,2) = -layout(:,3);
    layout_rotated(:,3) = layout(:,2);
    layout_rotated(:,6) = -layout(:,7);
    layout_rotated(:,7) = layout(:,6);
end
if type == 2
    layout_rotated(:,1) = layout(:,1);
    layout_rotated(:,2) = -layout(:,2);
    layout_rotated(:,3) = -layout(:,3);
    layout_rotated(:,6) = -layout(:,6);
    layout_rotated(:,7) = -layout(:,7);
end
if type == 3
    layout_rotated(:,1) = layout(:,1);
    layout_rotated(:,2) = layout(:,3);
    layout_rotated(:,3) = -layout(:,2);
    layout_rotated(:,6) = layout(:,7);
    layout_rotated(:,7) = -layout(:,6);
end
%
function [score, best_T] = alignment_score(source_layout, target_layout)
% We first need to do the conversion 

