function [Dess] = scene_descriptor(matrix)
% Compute the descriptor for a scene
matrix = reshape(matrix, [120,11]);
matrix = reshape(matrix(:,[1,2,3,5,6,8,9]), [120,7]);
% Statistics of the object counts
counts = sum(reshape(matrix(:,1), [30,4])')';
% Compute geometry features
geo_dess = geometry_dess(matrix);
Dess = [counts, geo_dess];

function [Dess] = geometry_dess(matrix)
%
ids = find(matrix(:,1) > 0);
block = matrix(ids,:);
ur = max(block(:,2:3))';
ll = min(block(:,2:3))';
center = (ur + ll)/2;
size = norm(ur - ll);
Dess = zeros(30, 6);
for classId = 1 : 30
    left = (classId-1)*4 + 1;
    right = classId*4;
    bb = matrix(left:right,:);
    if sum(bb(:,1)) > 0
        bb = bb(find(bb(:,1)),:);
        % Compute aspect ratio signature
        object_sizes = sqrt(bb(:,4).*bb(:,4) + bb(:,5).*bb(:,5))/size;
        object_ratios = min(bb(:,4), bb(:,5))./max(bb(:,4), bb(:,5));
        Dess(classId, 1) = mean(object_sizes);
        Dess(classId, 2) = var(object_sizes);
        Dess(classId, 3) = mean(object_ratios);
        Dess(classId, 4) = var(object_ratios);
        % Compute the distance 
        Dev_1 = bb(:,2) - center(1);
        Dev_2 = bb(:,3) - center(2);
        distance = sqrt(Dev_1.*Dev_1 + Dev_2.*Dev_2)/size;
        Dess(classId, 5) = mean(distance);
        Dess(classId, 6) = var(distance);
    end
end