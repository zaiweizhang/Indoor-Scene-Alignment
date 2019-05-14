function [PairStruct] = all_pairwise_alignment(Layouts, adjGraph)
%
[rows, cols, vals] = find(adjGraph);
ids = find(rows < cols);
rows = rows(ids)';
cols = cols(ids)';
numEdges = length(rows);
parfor eId = 1 : numEdges
    PairStruct{eId} = pairwise_processing(Layouts, rows(eId), cols(eId));
    if mod(eId, 10000) == 0
        fprintf('[%d,%d], %d [%f,%f], %f\n', eId, numEdges, PairStruct{eId}.rot_type, PairStruct{eId}.translation(1), PairStruct{eId}.translation(2), PairStruct{eId}.sqrDis);
    end
end

function [Pair] = pairwise_processing(Layouts, sId, tId)
%
Pair.sId = sId;
Pair.tId = tId;
[rot_type, translation, sqrDis] = geometric_alignment(...
        Layouts(sId,:,:),...
        Layouts(tId,:,:));
Pair.rot_type = rot_type;
Pair.translation = translation;
Pair.sqrDis = sqrDis;