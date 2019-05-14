function [rotIds] = rotation_sync(numScenes, PairStruct)
%
dim = 4*numScenes;
numEdges = length(PairStruct);
rowsG = zeros(4, numEdges);
colsG = zeros(4, numEdges);
valsG = ones(4, numEdges);
scores = zeros(1, numEdges);
for eId = 1 : numEdges
    pair = PairStruct{eId};
    for i = 1 : 4
        colsG(i, eId) = 4*(pair.sId-1) + mod(pair.rot_type+i-1,4) + 1;
        rowsG(i, eId) = 4*(pair.tId-1) + i;
    end
    scores(eId) = pair.sqrDis;
end
sigma = median(scores);
%
valsG = ones(4,1)*exp(-scores/sigma);
G = sparse(rowsG, colsG, valsG, dim, dim);
G = (G+G')/2;
%
d = sum(full(G));
d = sum(reshape(d, [4, numScenes]));
[s, rootId] = max(d);
ids = [1:(4*rootId-4), (4*rootId+1):(4*numScenes)];
A = G(ids, ids);
b = full(G(ids, 4*rootId-3));
x_sol = mrf_infer(A, b, 4, numScenes-1);
x = [1,0,0,0]'*ones(1, numScenes);
x(:,[1:(rootId-1),(rootId+1):numScenes]) = reshape(x_sol, [4, numScenes-1]);
[s,rotIds] = max(x);


function [x_sol] = mrf_infer(A, b, m, n)
%
x_sol = ones(m, n)/m;
x_sol = reshape(x_sol, [n*m,1]);
%
for iter = 1 : 20
    x_sol = A*x_sol + b;
    x_sol = normalize_L2(x_sol, m, n);
end
%
beta_min = 1e-2;
beta_max = 1;
for iter = 1 : 21
    t = (iter-1)/20;
    beta = exp(log(beta_min)*(1-t) + log(beta_max)*t);
    x_sol = A*x_sol + b;
    x_sol = exp(x_sol*beta).*x_sol;
    x_sol = normalize_L1(x_sol, m, n);
end
x_sol = reshape(x_sol, [m, n]);
%
for i = 1: n
    col = x_sol(:, i);
    [s,off] = max(col);
    col = zeros(m,1);
    col(off) = 1;
    x_sol(:,i) = col;
end
x_sol = reshape(x_sol, [n*m,1]);
%

function [x_nor] = normalize_L1(x_in, m, n)
%
x_in = reshape(x_in, [m,n]);
s_in = sum(x_in);
%
x_in = x_in./(ones(4,1)*s_in);
%
x_nor = reshape(x_in, [n*m,1]);

function [x_nor] = normalize_L2(x_in, m, n)
%
x_in = reshape(x_in, [m,n]);
s_in = sqrt(sum(x_in.*x_in));
%
x_in = x_in./(ones(4,1)*s_in);
%
x_nor = reshape(x_in, [n*m,1]);
