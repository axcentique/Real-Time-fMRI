% run classification for all scan sessions
run ~/Desktop/scripts/rtfMRI_import_responses_round_plus1.m

path.feat = '~/Desktop/FEAT_group_analysis/transformed_contrasts_contrasts/';

rest_num = 1;
dmn_seed = 1;
dmn_corr_thresh = .33;

tr_sec = 2;

fig_area_color = [.7 .7 .7];
fig_press_color = [.7 0 0];

z_dmn = -2.3;
z_smn = 6;

ses = 0;

time_event_press = {};
time_beep1 = {};
time_beep2 = {};
fmri_matrix = {};

for s = [4 6 7 8 10]
    fprintf('\n\nSubject %d',s)
    for r = 1:5
            fprintf('\n Run %d',r)
            cd('/Users/george/Data/rtfMRI/August/subjects/preprocessed/dmn/transformed_dmn_maps/')
            path.func = sprintf('/Users/george/Data/rtfMRI/August/Processing/subject%d/run%d_elliot.nii.gz',s,r);
            path.func_hipass = sprintf('/Users/george/Data/rtfMRI/August/subjects/filtered/subject%d_run%d_hi_pass_5.nii.gz',s,r);
            path.zmap = sprintf('%ssubject%d_run%d_contrast1_exclude%d_mni_1mm_in_func.nii.gz',path.feat,s,r,s);
            path.dmn = sprintf('subject%d_rest%d_dmn%d_IN_run%d.nii.gz',s,rest_num,dmn_seed,r);

        if exist(path.zmap,'file') == 0 | exist(path.dmn,'file') == 0 | exist(path.func_hipass,'file') == 0
                fprintf(' -- Z-map not found')
                continue
            else

    %             func = MRIread(path.func);
                func_hipass = MRIread(path.func_hipass);
                zmap = MRIread(path.zmap);
                dmn_map = MRIread(path.dmn);

                cd('/Users/george/dev/rtfMRI_classifier')
                %%
                dmn_map_vol = zeros(size(dmn_map.vol));
                dmn_map_vol(find(dmn_map.vol>dmn_corr_thresh)) = 1;

                thresholded_zmap_dmn = zeros(size(zmap.vol));
                thresholded_zmap_dmn(find(zmap.vol<z_dmn)) = 1;
                thresholded_zmap_dmn = thresholded_zmap_dmn .* dmn_map_vol;

                %%
    %             thresholded_zmap_smn = zeros(size(zmap.vol));
    %             thresholded_zmap_smn(find(zmap.vol>z_smn)) = 1;

    %             thresholded_zmap_smn(size(thresholded_zmap_smn,1):-1:floor(size(thresholded_zmap_smn,1)-size(thresholded_zmap_smn,1)/2.2),:,:) = 0;
    %             thresholded_zmap_smn(1:floor(size(thresholded_zmap_smn,1)/4.5),:,:) = 0;
    %             thresholded_zmap_smn(:,1:floor(size(thresholded_zmap_smn,2)/2),:) = 0;
    %             thresholded_zmap_smn(:,:,1:floor(size(thresholded_zmap_smn,3)/2)) = 0;

        %         vol3d_mri(thresholded_zmap_smn)

                %%

    %             matrix = rtfMRI_volume2matrix(mask_volume(func.vol,thresholded_zmap_smn));
        %         matrix = rtfMRI_volume2matrix(mask_volume(func_hipass.vol,thresholded_zmap_smn));


                %%

                ses = ses+1;
                %%
                for bold_shift = [2 3]
                    switch bold_shift
                        case 2
                            time_event_press_delay2{ses} = response(s,r).rest_response + bold_shift;       % get all responce event volumes
                            time_beep1_delay2{ses} = response(s,r).prep_onset + bold_shift;
                            time_beep2_delay2{ses} = response(s,r).rest_onset + bold_shift;
                        case 3
                            time_event_press_delay3{ses} = response(s,r).rest_response + bold_shift;       % get all responce event volumes
                            time_beep1_delay3{ses} = response(s,r).prep_onset + bold_shift;
                            time_beep2_delay3{ses} = response(s,r).rest_onset + bold_shift;
                    end
                end
                fmri_matrix{ses} = rtfMRI_volume2matrix(mask_volume(func_hipass.vol,thresholded_zmap_dmn));
        end
            
        
%         end
    end
end
fprintf('\nDone.\n')















































