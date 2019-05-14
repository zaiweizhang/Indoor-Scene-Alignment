function [Dess_all] = dess_batch_processing(output)
%
[numScenes, numCategories, feaDim] = size(output);
%
Dess_all = zeros(numScenes, numCategories/4, 7);
for id = 1:numScenes
    Dess_all(id, :, :) = scene_descriptor(output(id,:,:));
    if mod(id, 100) == 0
        fprintf('Finished %d\n', id);
    end
end
vars = data_analysis(Dess_all);
scales = ones(1,7);
scales(2:3) = vars(1)/vars(2);
scales(4:5) = vars(1)/vars(4);
scales(6:7) = vars(1)/vars(6);
for k = 1 : 7
    Dess_all(:,:,k) = Dess_all(:,:,k)*scales(k);
end