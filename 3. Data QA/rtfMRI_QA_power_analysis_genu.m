clear
clc

% cd('/media/temp/george/rtfMRI/groupICA/_elliot_preproc/fftc_b0mf')
savepath = '/media/temp/george/rtfMRI/groupICA/_elliot_preproc/fftc_b0mf/';

r_type_string = {'rest';'run'};
r_name_string = {'rest';'task'};

for s = 1:10
    for r_type = 1:2
        for r = 1:5
            filename = sprintf('subject%d_%s%d.hdr',s,r_type_string{r_type},r);
            if exist(filename,'file') == 0
                continue
            else
                data = MRIread(filename);
                %%
                max_value = max(data.vol(:));
                min_value = min(data.vol(:));
                for t=1:size(data.vol,4)
                    close all
                    for v = 1:4
                        subplot(2,2,v)
                        vol3d_mri(data.vol(:,:,:,t))
                        caxis([min_value max_value])
                        set(gca,'Visible','off')
                        whitebg
                        axis vis3d
                        switch v
                            case 1
                                view(0,90)
                                colorbar
                            case 2
                                view(180,0)
                            case 3
                                view(90,0)
                            case 4
                                view(140,20)
                        end

                    end
                    plotname = sprintf('Voxel power, subject #%d, %s session #%d, band #%d',s,r_name_string{r_type},r,t);
                    suptitle(plotname)
                    
                    save_dir_name = sprintf('subject %d, %s %d',s,r_name_string{r_type},r);
                    mkdir([savepath save_dir_name])
                    saveas(gca,[savepath save_dir_name '/' plotname '.png'])
                end
            end
        end
    end
end
