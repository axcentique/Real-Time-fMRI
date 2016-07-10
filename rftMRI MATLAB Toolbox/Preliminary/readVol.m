function data = rtfMRI_import_volume(varargin)

if ~isempty(varargin)
%     if ischar(varargin)
        filepath = varargin
%     else
%         error('Input a file path in string data type.')
%     end
else
    filterspec = 'nii.gz';
%     while ~exist(filename,'var')
    [filename path]= uigetfile(filterspec);
    if filename == 0
        clear filename path
        error('No file was selected.')
    end
    filepath = [path filename];
end

data = MRIread(filepath);

% scanSize = size(data.vol);
% if length(scanSize)==4
%     vol = squeeze(data.vol(:,:,:,1));
% else
%     vol = data.vol;
% end
% 
% voxel = find(vol);
% [x y z] = ind2sub(scanSize,voxel);
% 
% vol3d('cdata',data.vol(min(x):max(x),min(y):max(y),min(z):max(z)),'texture','3D');
% daspect(data.volres), axis vis3d, zoom on
