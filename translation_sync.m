function [t_opt] = translation_sync(PairStruct)
%
numEdges = length(PairStruct);
%
%
rowsJ = kron(ones(2,1), 1:numEdges);
colsJ = zeros(2, numEdges);
valsJ = [1,-1]'*ones(1, numEdges);
vecg = zeros(numEdges, 2);
%
sqrDis = zeros(1, numEdges);
for eId = 1 : numEdges
    pair = PairStruct{eId};
    colsJ(1, eId) = pair.sId;
    colsJ(2, eId) = pair.tId;
    vecg(eId,:) = pair.translation;
    sqrDis(eId) = PairStruct{eId}.sqrDis;
end
sigma = median(sqrDis);
weights = exp(-sqrDis/sigma);
weights_cur = weights;
J = sparse(rowsJ, colsJ, valsJ);
for iter = 1:4
    W = sparse(1:length(weights), 1:length(weights), weights_cur);
    A = J'*W*J;
    b = J'*W*vecg;
    %
    dim = size(A,1);
    A_aug = [A, ones(dim,1);ones(1,dim), 0];
    b_aug = [b; [0,0]];
    x_sol = A_aug\b_aug;
    t_opt = x_sol(1:dim,:);
    dif = J*t_opt - vecg;
    dif = sum(dif'.*dif');
    sigma2 = median(dif);
    weights_cur = weights.*(sigma2./(sigma2 + dif));
end