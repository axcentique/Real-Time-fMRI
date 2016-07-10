% run classification for all scan sessions
run ~/Desktop/scripts/rtfMRI_import_responses_round_plus1.m

cd('/Users/george/dev/rtfMRI_classifier')
path.feat = '~/Desktop/FEAT_group_analysis/transformed_contrasts_contrasts/';

rest_num = 1;
dmn_seed = 1;
dmn_corr_thresh = .33;
bold_shift = 2; % TRs

z_dmn = -2.3;
z_smn = 3;
for s = 4%[4 6 7 8 10]
    fprintf('\n\nSubject %d',s)
    for r = 1%:5
        fprintf('\n Run %d',r)

        path.func = sprintf('/Users/george/Data/rtfMRI/August/Processing/subject%d/run%d_elliot.nii.gz',s,r);
        path.func_hipass = sprintf('/Users/george/Data/rtfMRI/August/subjects/filtered/subject%d_run%d_hi_pass_5.nii.gz',s,r);
        path.zmap = sprintf('%ssubject%d_run%d_contrast1_exclude%d_mni_1mm_in_func.nii.gz',path.feat,s,r,s);
        path.dmn = sprintf('subject%d_rest%d_dmn%d_IN_run%d.nii.gz',s,rest_num,dmn_seed,r);
        
        func = MRIread(path.func);
        func_hipass = MRIread(path.func_hipass);
        zmap = MRIread(path.zmap);
        dmn_map = MRIread(path.dmn);
        %%
        dmn_map_vol = zeros(size(dmn_map.vol));
        dmn_map_vol(find(dmn_map.vol>dmn_corr_thresh)) = 1;
        
        thresholded_zmap_dmn = zeros(size(zmap.vol));
        thresholded_zmap_dmn(find(zmap.vol<z_dmn)) = 1;
        thresholded_zmap_dmn = thresholded_zmap_dmn .* dmn_map_vol;
        
        %%
        thresholded_zmap_smn = zeros(size(zmap.vol));
        thresholded_zmap_smn(find(zmap.vol>z_smn)) = 1;
        
        thresholded_zmap_smn(size(thresholded_zmap_smn,1):-1:floor(size(thresholded_zmap_smn,1)-size(thresholded_zmap_smn,1)/2.2),:,:) = 0;
        thresholded_zmap_smn(1:floor(size(thresholded_zmap_smn,1)/4.5),:,:) = 0;
        thresholded_zmap_smn(:,1:floor(size(thresholded_zmap_smn,2)/2),:) = 0;
        thresholded_zmap_smn(:,:,1:floor(size(thresholded_zmap_smn,3)/2)) = 0;
        
%         vol3d_mri(thresholded_zmap_smn)
        
        %%
        
        matrix = rtfMRI_volume2matrix(mask_volume(func.vol,thresholded_zmap_smn));
        matrix_hi = rtfMRI_volume2matrix(mask_volume(func_hipass.vol,thresholded_zmap_dmn));
        
        mean_smn = mean(matrix);
        mean_dmn = mean(matrix_hi);
        %%
        
        feature_dmn{1} = mean_dmn;
        
        
        %%
        t0 = response(s,r).rest_response + bold_shift;       % get all responce event volumes
        tp = response(s,r).prep_onset + bold_shift;
        tr = [1; response(s,r).rest_onset(1:numel(response(s,r).rest_onset)-1)] + bold_shift;
        
        

        
        
        
        
    end
end
fprintf('\nDone.\n')