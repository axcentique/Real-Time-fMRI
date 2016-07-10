function plotv(data)

% data = MRIread(file_path);

if length(size(data)) > 3
    vol3d('cdata',data(:,:,:,1),'texture','3D');
    fprintf('Plotting the first volume only\n');
else
    vol3d('cdata',data,'texture','3D');
end
daspect([1 1 1])
axis vis3d;
view(140,15)
set(gca,'Visible','off')
zoom(1.5)
lighting none