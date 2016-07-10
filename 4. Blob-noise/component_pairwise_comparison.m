clear
clc

RestDir = '~/Data/Blob-noise/rest.feat';
FlipDir = '~/Data/Blob-noise/rest_flipmask.feat';

CompRest = MRIread([RestDir '/filtered_func_data.ica/melodic_IC.nii.gz']);
DataRest = MRIread([RestDir '/filtered_func_data.nii.gz']);
CompFlip = MRIread([FlipDir '/filtered_func_data.ica/melodic_IC.nii.gz']);
DataFlip= MRIread([FlipDir '/filtered_func_data.nii.gz']);

fprintf('Number of Rest components: %d\n',size(CompRest.vol,4))
fprintf('Number of Flip components: %d\n',size(CompFlip.vol,4))
%%
clear masked_rest masked_flip

for r_comp = 1:size(CompRest.vol,4)
    masked_rest(:,:,:,:,r_comp) = mask_volume(DataRest.vol,CompRest.vol(:,:,:,r_comp));
    clc, fprintf('Progress: %f%%\n',r_comp/size(CompRest.vol,4)*100)
end
for f_comp = 1:size(CompFlip.vol,4)
    masked_flip(:,:,:,:,f_comp) = mask_volume(DataFlip.vol,CompFlip.vol(:,:,:,r_comp));
    clc, fprintf('Progress: %f%%\n',f_comp/size(CompFlip.vol,4)*100)
end

clear CompRest DataRest CompFlip DataFlip

%%

for r_comp = 1%:size(masked_rest,4)
    r_ts = rtfMRI_timeseries_mean(masked_rest);
%     plot(r_ts)
    for f_comp = 1%:size(masked_flip,4)
        f_ts = rtfMRI_timeseries_mean(masked_flip);
%         hold on
%         plot(f_ts)
    end
end

%%

parfor r_comp = 1:size(masked_rest,4)
    r_ts(:,r_comp) = rtfMRI_timeseries_mean(masked_rest);
end
parfor f_comp = 1:size(masked_flip,4)
    f_ts(:,f_comp) = rtfMRI_timeseries_mean(masked_flip);
end