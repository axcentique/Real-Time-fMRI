function out_matrix = rtfMRI_volume2matrix(volume)

volSize = size(volume);

switch numel(volSize)
    case 3
        volInd = find(volume);
    case 4
        vol = volume(:,:,:,1);
        parfor d=2:size(volume,4)
            vol = vol+volume(:,:,:,d);
        end
        volInd = find(vol);
end

[x y z] = ind2sub(volSize(1:3),volInd);

out_matrix=[];
switch numel(size(volume))
    case 4
        parfor j=1:length(volInd)
%             numel(squeeze(volume(x(j),y(j),z(j),:)));
            out_matrix(j,:) = squeeze(volume(x(j),y(j),z(j),:));
        end
    otherwise
        error('Input volume must be in 3D.')
end

if max(size(out_matrix) ~= [numel(volInd) size(volume,4)])
    error('Debug: Size of resuling matrix does not match the input volume.')
end