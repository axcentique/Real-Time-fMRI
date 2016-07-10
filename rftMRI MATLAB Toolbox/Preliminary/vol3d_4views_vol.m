function vol3d_4views_vol(data,textName,t)

if numel(size(data)) == 4
    data = squeeze(data(:,:,:,t));
    1
end

h = figure;
set(gca,'LooseInset',get(gca,'TightInset'))
set(h,'PaperPositionMode','auto');

for i=1:4
    %%
    h(i) = subplot(2,2,i);
    vol3d('cdata',data);
    switch i
        case 1, view(180,0), title('Front')
        case 2, view(90,0), title('Side')
        case 3, view(180,90), title('Top')
        case 4, view(135,25), title('Isometric')
    end
    daspect([1 1 1]), axis vis3d, zoom on, axis off 
    %xlabel('x'), ylabel('y'), zlabel('z')
end

hTitle = suptitle(textName);
% set(hTitle,'FontName','Monaco','FontSize',9)
set(hTitle,'FontSize',12)
% set(h,'position',[300 300 1000 700]);
% colorbar;