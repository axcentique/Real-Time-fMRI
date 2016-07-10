function matrix = demean_rows(matrix)

voxel_mean = mean(matrix');

for v = 1:size(matrix,1)
    matrix(v,:) = matrix(v,:) - voxel_mean(v);
end
end