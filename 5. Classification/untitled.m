imagesc(feature_vector)
hold on

for i = 1:numel(tb)
    l = line([t0(i) t0(i)], [0 size(feature_vector,1)],'linewidth',2);
    switch tb(i)
        case 'b'
            set(l,'Color','b')
        case 'r'
            set(l,'Color','r')
    end
end
filename = sprintf('%s of subject %d, run %d',feature_name{f},s,r);
title(filename,'FontName','Monaco','FontSize',13)

surf(feature_vector,'FaceColor','interp',...
'EdgeColor','none',...
'FaceLighting','phong')
colorbar