function [vars] = data_analysis(Dess_all)
%
[m,n,k] = size(Dess_all);
buffer = zeros(n, m);
for k = 1 : 7
    for i = 1 : m
        buffer(:,i) = Dess_all(i,:, k)';
    end
    % Compute the variance of buffer
    center = mean(buffer')';
    buffer = buffer - center*ones(1,m);
    M = buffer*buffer';
    var = max(eig(M))/m;
    vars(k) = var;
end