function vol3d_mri(data)

% data = MRIread(file_path);
figure
switch length(size(data))
    case 3
        vol3d('cdata',data,'texture','3D');
    case 4
        vol3d('cdata',data(:,:,:,1),'texture','3D');
        fprintf('\nExtra dimention ignored\n')
end
daspect([1 1 1])
% axis vis3d;