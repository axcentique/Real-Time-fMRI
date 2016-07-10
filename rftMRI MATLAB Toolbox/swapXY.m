function out = swapXY(in)

if numel(size(in))>2
    error('Only Nx3 or 3xN are acceptable')
end

if size(in,2) ~= 3
    if size(in,1) ~= 3
        error('Each coordinate must have 3 elements')
    end
    in = in';
end

out = [in(:,2) in(:,1) in(:,3)];