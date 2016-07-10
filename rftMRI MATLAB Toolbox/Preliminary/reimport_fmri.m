function out = reimport_fmri(vol)

% add an option to mask the volume here

reshape_size = [size(vol,1)*size(vol,2)*size(vol,3) size(vol,4)];
matrix = reshape(vol,reshape_size);

out.matrix = matrix(any(matrix,2),:);

voxel_index = ones(size(matrix,1),1);

parfor v = 1:size(matrix,1)
    unique_value = unique(matrix(v,:));
    if (length(unique_value) == 1) && (unique_value == 0)
        voxel_index(v) = 0;
    end
    fprintf('Omitting zero voxels: %5.2f %%\n',v/size(matrix,1)*100)
end
out.voxel_index = find(voxel_index);
clc


if length(out.voxel_index) ~= size(out.matrix,1)
    error('something is terribly wrong')
end

% out.header = import;

% save([path_to_nifti '.mat'],'out')
