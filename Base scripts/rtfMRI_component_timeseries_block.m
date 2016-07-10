%%
clear

ica_folder = 'block_design+.ica/';
% ica_folder = 'event_design+.ica/';
dmn_folder = 'Block';
% dmn_folder = 'Event';
run tut_blocks
% run tut_events

data_path = '~/Desktop/tutorial/';
path.ICA.comp = [data_path ica_folder 'filtered_func_data.ica/melodic_IC.nii.gz'];
path.DMN = ['~/Desktop/Output/CABI_data/' dmn_folder '_design/DMN/DMN_correlation_map.nii.gz'];
path.func = [data_path ica_folder 'filtered_func_data.nii.gz'];


comp = MRIread(path.ICA.comp);
mask = MRIread(path.DMN);
func = MRIread(path.func);
TR = func.tr/10^3;

%%
% for c=1:size(comp.vol,4)
%     comp = rtfMRI_volume_threshold(comp.vol(:,:,:,c),threshold.min,threshold.max,'percent','nonnegative','none');
%     figure, vol3d('cdata',comp.tresh{1}.vol,'texture','3d'); daspect(1./comp.volres); axis vis3d; zoom on; view(135,20);
%     title(sprintf('Component #%d',c));
% end
%%
close all
clc

save_path = sprintf('~/Desktop/Output/CABI_data/%s_design/ICA/',dmn_folder);

% block
component = 13;

% % event
% component = 5;

threshold.comp.max	= linspace(1,1,10);
threshold.dmn.max	= linspace(1,1,10);
threshold.comp.min	= linspace(0,1,10);
threshold.dmn.min	= linspace(0,1,10);

count = 0;

for i=1:numel(threshold.comp.max)
    for j=1:numel(threshold.dmn.max)

        comp.thresh = rtfMRI_volume_threshold(comp.vol(:,:,:,component),threshold.comp.min(i),threshold.comp.max(i),'percent','nonnegative','binarize');
        % figure, vol3d('cdata',comp.thresh{:}.vol * 20* max(func.vol(:)) + func.vol(:,:,:,1)); daspect(1./comp.volres); axis vis3d; zoom on; view(135,20);

        dmn.thresh = rtfMRI_volume_threshold(mask.vol,threshold.dmn.min(j),threshold.dmn.max(j),'-percent','nonnegative','binarize');
        % figure, vol3d('cdata',dmn.thresh{:}.vol * 20* max(func.vol(:)) + func.vol(:,:,:,1)); daspect(1./comp.volres); axis vis3d; zoom on; view(135,20);

        masked.vol = intersect_volumes(dmn.thresh{:}.vol,comp.thresh{:}.vol);
        % figure, vol3d('cdata',masked.vol * 20 * max(func.vol(:)) + (comp.thresh{:}.vol * 10 + dmn.thresh{:}.vol * 5) * max(func.vol(:)) + func.vol(:,:,:,1)); daspect(1./comp.volres); axis vis3d; zoom on; view(135,20);

        
        if numel(find(masked.vol)) <= size(func.vol,4)
            continue
        end

        vol_name = sprintf('Component_%d_%3.2f,%3.2f,_DMN_%3.2f,%3.2f',component,threshold.comp.min(i),threshold.comp.max(i),threshold.dmn.min(j),threshold.dmn.max(j));
%         save_nii(func,masked.vol,[vol_name '.nii.gz'],save_path)



        masked.func = mask_volume(func.vol,masked.vol);
%         masked.func = mask_volume(func.vol,comp.thresh{:}.vol);

        mean_ts = mean(rtfMRI_volume2matrix(masked.func));

% error('t')
        textTitle = sprintf('Mean voxel time-series in union of Independent Component %d,%3.2f_%3.2f, & correlated Default Mode Network,%3.2f,_%3.2f',component,threshold.comp.min(i),threshold.comp.max(i),threshold.dmn.min(j),threshold.dmn.max(j));
        rtfmri_plot_TS_EV(mean_ts,ev,textTitle,{'black','grey'},TR)
%         saveas(gca,[save_path textTitle '.png']);
%         close

        count  = count  + 1;
        count / (numel(threshold.comp.max) * numel(threshold.dmn.max))
    end
end


'Fin'
