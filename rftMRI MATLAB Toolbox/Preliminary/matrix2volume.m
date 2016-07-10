function volume = rtfMRI_volume2matrix(matrix,ref_volume)
%%
    switch numel(size(ref_volume))
        case 3
        case 4
            ref_volume = ref_volume(:,:,:,1);
        otherwise
            error('Volume size must be either 3D or 4D')
    end

    volume_size = size(ref_volume);
    time_length = size(matrix,2);

    voxel_index = find(ref_volume);

    if (size(matrix,2) == numel(voxel_index)) && (size(matrix,1) ~= numel(voxel_index))
        matrix = matrix';
        time_length = size(matrix,2);
    end
    if (size(matrix,2) ~= numel(voxel_index)) && (size(matrix,1) ~= numel(voxel_index))
        error('Number of non-empty voxels in the volume does not match any dimension in the matrix')
    end

    volume = zeros([volume_size time_length]);

    for t = 1:time_length
        vol_t = zeros(volume_size);
%         t
%         size(vol_t)
%         size(volume)
        vol_t(voxel_index) = matrix(:,t);
        volume(:,:,:,t) = vol_t;
    end

end