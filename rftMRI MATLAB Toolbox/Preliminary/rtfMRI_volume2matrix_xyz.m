function out = rtfMRI_volume2matrix_xyz(volume)

volInd = find(volume);
[x y z] = ind2sub(size(volume),volInd);

switch numel(size(volume))
    case 4
        parfor t=1:length(volInd)
            matrix(t,:) = squeeze(volume(x(t),y(t),z(t),:));
        end
    otherwise
        error('Input volume must be a 3D or 4D.\n')
end

if max(size(matrix) ~= [numel(volInd) size(volume,4)])
    error('Debug: Size of resuling matrix does not match the input volume.\n')
end

out.matrix = matrix;
out.x = x;
out.y = y;
out.z = z;