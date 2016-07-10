function [out index] = feature_derivative(in)
%%
[r c] = size(in);

out = zeros([r c]);

for i = 1:r
    for j = 2:c-1
        out(i,j) = .5 * (in(i,j)^2 - in(i,j-1)*in(i,j+1));
    end
end

index = 2:c-1;