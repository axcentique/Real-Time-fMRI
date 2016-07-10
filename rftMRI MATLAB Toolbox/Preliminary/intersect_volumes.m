function out = intersect_volumes(varargin)

parfor n = 1:numel(varargin)
    ind{n} = squeeze(find(varargin{n}));
    volSize(:,n) = size(varargin{n});
%     figure, vol3d('cdata',varargin{n});
end

parfor d = 1:size(volSize,1)
    if numel(unique(volSize(d,:))) > 1
       error('Inputs are of different sizes.')
    end
end

ind_out = intersect(ind{:});
out = zeros(volSize(:,1)');
out(ind_out) = 1;