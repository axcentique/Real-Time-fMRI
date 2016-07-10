function out = mask_volume(vol,mask)

if numel(size(mask)) ~= 3
    error('The mask is not in 3D')
end

out = zeros(size(vol));

switch numel(size(vol))
    case 3
        ind = find(mask);
        out(ind) = vol(ind);
    case 4
        ind = find(mask);
        [x y z] = ind2sub(size(mask),ind);
        for t = 1:length(ind)
            out(x(t),y(t),z(t),:) = squeeze(vol(x(t),y(t),z(t),:));
        end
    otherwise
        error('Input volume should be in 3D or 4D')
end