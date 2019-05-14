function [G] = similarity_graph(Dess_all, knn)
%
[m,n,k] = size(Dess_all);
dim = n*k;
buffer = zeros(dim, m);
for i = 1 : m
    tp = Dess_all(i,:,:);
    tp = reshape(tp, [dim,1]);
    buffer(:, i) = tp;
end
rowsG = (1:m)'*ones(1, knn);
colsG = zeros(m, knn);
valsG = ones(m, knn);
for i = 1 : m
    dif = buffer(:, i)*ones(1,m) - buffer;
    dif = sum(dif.*dif);
    [s,ids] = sort(dif);
    colsG(i, :) = ids(2:(knn+1));
    if mod(i, 100) == 0
        fprintf('%d\n', i);
    end
end
G = sparse(rowsG, colsG, valsG, m, m);
G = max(G, G');