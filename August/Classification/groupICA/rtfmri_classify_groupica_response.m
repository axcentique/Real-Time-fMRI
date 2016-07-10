run ~/Desktop/scripts/rtfMRI_import_responses_round_plus1.m
%%
clear masked_voxels

clc
% data parameters
num.subjects = 10;
num.sessions = 5;    % maximum number of sessions per subjects
zmap_name = 'smn';
path.feat = '~/Desktop/6groupICA/transformed_components/';
path.save = sprintf('~/Data/rtfMRI/August/Classification/groupICA/%s',zmap_name);
path.t1 = '~/Data/rtfMRI/August/subjects/transformations/';
run_type = {'rest';'run'};
run_index = 2;
z_threshold = 2.3;

bold_shift = 4;

%%
clear accuracy results
clc
for s = 4:num.subjects
    fprintf('\nSubject %d ',s)
    for r = 1:num.sessions 
        fprintf('\n Session %d: ',r)
        if numel(unique(response(s,r).rest_button_t)) < 2
            fprintf(' - < 2 button classes')
            continue
        else
            % load 4D fMRI data
            path.func = sprintf('~/Data/rtfMRI/August/Processing/subject%d/%s%d_elliot.nii.gz',s,run_type{run_index},r);
            func = MRIread(path.func);

            % check if Z-map exists
            path.zmap = sprintf('%ssubject%d_%s%d_component_%s_mni_in_func.nii.gz',path.feat,s,run_type{run_index},r,zmap_name);
            if exist(path.zmap,'file') == 0
                fprintf(' - Z-map not found')
                accuracy(s,r) = NaN;
                continue
            else
                % load Z-map
                zmap = MRIread(path.zmap);
                vol = zeros(size(zmap.vol));
                vol(find(zmap.vol>z_threshold)) = 1;

                masked_voxels(s,r) = numel(vol);

                if numel(find(vol)) == 0
                    fprintf(' - No voxels masked')
                    accuracy(s,r) = NaN;
                    continue
                else
                    data = mask_volume(func.vol,vol);       % mask data with Z-map
                    matrix = rtfMRI_volume2matrix(data);    % transform into 2D matrix (output = voxel x volume)
    %%
                    t0 = response(s,r).rest_response + bold_shift;       % get all responce event volumes
                    tp = response(s,r).prep_onset + bold_shift;
                    tr = response(s,r).rest_onset + bold_shift;
                    
                    if numel(unique(response(s,r).rest_button_t)) > 2
                        fprintf(' - > 2 button classes')
                        accuracy(s,r) = NaN;
                        continue
                    else
                        button_press = response(s,r).rest_button_t;
                    end

                    if min(tr-tp) < 0
                       error(' ? Negative durations.\n') 
                    end
                    if numel(t0) ~= numel(tp)
                       error(' ? Mismatch between number of preps and responses.') 
                    end


                    for i = 1:numel(t0)
                        bold_windowed_train = [];
                        response_windowed_train = [];
                        bold_windowed_test = [];
                        response_windowed_test = [];
                        for j = 1:length(tp)
    %                         plot_index = tp(j):tr(j);
                            plot_index = t0(j);
                            if i ~= j
                                bold_windowed_train = [bold_windowed_train matrix(:,plot_index)];
                                response_windowed_train = [response_windowed_train char(linspace(button_press(j),button_press(j),numel(plot_index)))];
                            else
                                bold_windowed_test = [bold_windowed_test matrix(:,plot_index)];
                                response_windowed_test = [response_windowed_test char(linspace(button_press(j),button_press(j),numel(plot_index)))];                            
                            end
                        end
                        SVMStruct = svmtrain(bold_windowed_train',response_windowed_train');
                        Group = svmclassify(SVMStruct,bold_windowed_test');

                        results(s,r,i,:) = [response_windowed_test Group]; 
                    end

    %                 squeeze(results(s,r,:,:))
                    accuracy(s,r) = sum(squeeze(results(s,r,:,1)) == squeeze(results(s,r,:,2)))/numel(t0);
                    fprintf('\n   Accuracy: %3.2f',accuracy(s,r));

                end
            end
        end
    end
    fprintf('\n\nAverage subject accuracy: %3.2f\n',nanmean(accuracy(s,:)));
end

fprintf('\n\nAverage group accuracy: %3.2f\n',nanmean(accuracy(:)));

save('masked_voxels.mat','masked_voxels');



















