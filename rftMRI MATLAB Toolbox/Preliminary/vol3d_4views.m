function vol3d_4views(data,textName,t)

if numel(size(data.vol)) == 4
    data.vol = squeeze(data.vol(:,:,:,t));
    1
end

figure

for i=1:4
    %%
    h(i) = subplot(2,2,i);
    vol3d('cdata',data.vol);
    switch i
        case 1, view(180,0), title('Front')
        case 2, view(90,0), title('Side')
        case 3, view(90,90), title('Top')
        case 4, view(135,25), title('Isometric')
    end
    daspect(1./data.volres), axis vis3d, zoom on 
    %xlabel('x'), ylabel('y'), zlabel('z')
end

hTitle = suptitle(textName);
set(hTitle,'FontName','Monaco','FontSize',13)
