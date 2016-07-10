% run classification for all scan sessions
run ~/Desktop/scripts/rtfMRI_import_responses_round_plus1.m

path.feat = '~/Desktop/FEAT_group_analysis/transformed_contrasts_contrasts/';
path.save = '~/Desktop/rtfMRI Reports/13:4:11-motor-maps';

rest_num = 1;
dmn_seed = 1;
dmn_corr_thresh = .33;


number_thresholds = 30;
tr_sec = 2;

fig_area_color = [.7 .7 .7];
fig_press_color = [.7 0 0];

z_dmn = -2.3;
z_smn = 3;
%%
for s = [4 6 7 8 10]
    fprintf('\n\nSubject %d',s)
    for r = 1:5
        fprintf('\n Run %d',r)
        cd('/Users/george/Data/rtfMRI/August/subjects/preprocessed/dmn/transformed_dmn_maps/')

        path.func = sprintf('/Users/george/Data/rtfMRI/August/Processing/subject%d/run%d_elliot.nii.gz',s,r);
        path.func_hipass = sprintf('/Users/george/Data/rtfMRI/August/subjects/filtered/subject%d_run%d_hi_pass_5.nii.gz',s,r);
%         path.zmap = sprintf('%ssubject%d_run%d_contrast1_exclude%d_mni_1mm_in_func.nii.gz',path.feat,s,r,s);
        path.zmap = sprintf('/Users/george/Data/rtfMRI/August/subjects/feat+ica/subject%d_run%d.feat/stats/zstat1.nii.gz',s,r);
        path.dmn = sprintf('subject%d_rest%d_dmn%d_IN_run%d.nii.gz',s,rest_num,dmn_seed,r);

        func = MRIread(path.func);
        func_hipass = MRIread(path.func_hipass);
        zmap = MRIread(path.zmap);
        dmn_map = MRIread(path.dmn);

        cd('/Users/george/dev/rtfMRI_classifier')
%         %%
        dmn_map_vol = zeros(size(dmn_map.vol));
        dmn_map_vol(find(dmn_map.vol>dmn_corr_thresh)) = 1;

        thresholded_zmap_dmn = zeros(size(zmap.vol));
        thresholded_zmap_dmn(find(zmap.vol<z_dmn)) = 1;
        thresholded_zmap_dmn = thresholded_zmap_dmn .* dmn_map_vol;

        %%
        thresholded_zmap_smn = zeros(size(zmap.vol));
        thresholded_zmap_smn(find(zmap.vol>z_smn)) = 1;
        
        if ~isempty(numel(find(thresholded_zmap_smn)))
            continue
        end

        thresholded_zmap_smn(size(thresholded_zmap_smn,1):-1:floor(size(thresholded_zmap_smn,1)-size(thresholded_zmap_smn,1)/2.2),:,:) = 0;
        thresholded_zmap_smn(1:floor(size(thresholded_zmap_smn,1)/4.5),:,:) = 0;
        thresholded_zmap_smn(:,1:floor(size(thresholded_zmap_smn,2)/2),:) = 0;
        thresholded_zmap_smn(:,:,1:floor(size(thresholded_zmap_smn,3)/2)) = 0;
%%
        vol3d_mri(thresholded_zmap_smn*10*max(max(max(func.vol(:,:,:,1))))+func.vol(:,:,:,1))
%         vol3d_mri(thresholded_zmap_dmn*10*max(max(max(func.vol(:,:,:,1))))+func.vol(:,:,:,1))

        %%

        voxel_freq_vol_4d = mask_volume(func_hipass.vol,thresholded_zmap_smn);
%         matrix = rtfMRI_volume2matrix(mask_volume(func.vol,thresholded_zmap_smn));
%         matrix = rtfMRI_volume2matrix(mask_volume(func_hipass.vol,thresholded_zmap_smn));
        matrix_hi = rtfMRI_volume2matrix(mask_volume(func_hipass.vol,thresholded_zmap_smn));
        matrix_dmn = rtfMRI_volume2matrix(mask_volume(func_hipass.vol,thresholded_zmap_dmn));

%         mean_smn = matrix;
        ts_dmn = matrix_dmn;
        ts_smn = matrix_hi;
        
        mean_dmn = mean(matrix_dmn) - mean(matrix_dmn(:));
        mean_smn = mean(matrix_hi) - mean(matrix_hi(:));
        %%
%         avg_bold(response,s,r,[mean_dmn; mean_smn],'gr','Mean DMN & SMN BOLD of subject-level button press contrast')

        %%
        clear feature feature_index feature_name

        feature{1} = ts_smn;
        feature_index{1} = 1:size(feature{1},2);
        feature_name{1} = 'Mean SMN BOLD (Hi-pass)';
        
        [feature{2} feature_index{2}] = feature_derivative(ts_smn);
        feature_name{2} = 'Mean SMN BOLD Derivative (Hi-pass)';

%         [feature{5} feature_index{5}] = feature_anticorr(mean_dmn,mean_smn);
%         feature_name{5} = 'DMN & SMN BOLD derivative substraction';
%         
%         [feature{6} feature_index{6}] = feature_anticorr_multi(mean_dmn,mean_smn);
%         feature_name{6} = 'DMN & SMN BOLD derivative multiplication';

        %%
        clc
        
        for f = 1:numel(feature)
            %%
            feature_vector = feature{f};
            index_vector = feature_index{f};
            feature_title = feature_name{f};
            %%
            for bold_shift = 3%[2 3]
                for prep_initial_shift = -1%[-1 0]

                    t0 = response(s,r).rest_response + bold_shift;       % get all responce event volumes
                    tp = response(s,r).prep_onset + bold_shift;
                    tr = [1; response(s,r).rest_response(1:numel(response(s,r).rest_response)-1)+1] + bold_shift;
                    tb = response(s,r).rest_button;

                    %%
                    detection_table_r = zeros([size(feature_vector,1) number_thresholds numel(t0)*2]);
                    detection_table_b = zeros([size(feature_vector,1) number_thresholds numel(t0)*2]);
                    %%
                    for t = 1:numel(t0) %0:numel(t0)
                        rest_index_r = [];
                        prep_index_r = [];
                        rest_index_b = [];
                        prep_index_b = [];
                        for j = 1:length(tp)
                            if j==t
                                switch tb(j)
                                    case 'r'
                                        rest_index_r_t = tr(j):tp(j)-1+prep_initial_shift;
                                        prep_index_r_t = tp(j)+prep_initial_shift:t0(j);
                                    case 'b'
                                        rest_index_b_t = tr(j):tp(j)-1+prep_initial_shift;
                                        prep_index_b_t = tp(j)+prep_initial_shift:t0(j);
                                end
                            else
                                switch tb(j)
                                    case 'r'
                                        rest_index_r = [rest_index_r tr(j):tp(j)-1+prep_initial_shift];
                                        prep_index_r = [prep_index_r tp(j)+prep_initial_shift:t0(j)];
                                    case 'b'
                                        rest_index_b = [rest_index_b tr(j):tp(j)-1+prep_initial_shift];
                                        prep_index_b = [prep_index_b tp(j)+prep_initial_shift:t0(j)];
                                end
                            end
                        end

                        if ~isempty(intersect(rest_index_r,prep_index_r))
                            intersect(rest_index_r,prep_index_r)
                            error('Indexes of resting and preping vactors intersect.')
                        end
                        if ~isempty(intersect(rest_index_b,prep_index_b))
                            intersect(rest_index_b,prep_index_b)
                            error('Indexes of resting and preping vactors intersect.')
                        end
                        
                        %%
                        rest_index_r = intersect(index_vector,rest_index_r);
                        prep_index_r = intersect(index_vector,prep_index_r);
                        
                        rest_index_b = intersect(index_vector,rest_index_b);
                        prep_index_b = intersect(index_vector,prep_index_b);
%%
                        if t == 0
%                             if numel(rest_index) > numel(prep_index)
%                                 plot_feature_matrix = [ feature_vector(rest_index)' [feature_vector(prep_index) linspace(NaN,NaN,numel(rest_index) - numel(prep_index))]' ];
%                             end
%                             if numel(rest_index) < numel(prep_index)
%                                 plot_feature_matrix = [ [feature_vector(rest_index) linspace(NaN,NaN,numel(prep_index) - numel(rest_index))]' feature_vector(prep_index)'];
%                             end
%                             if numel(rest_index) == numel(prep_index)
%                                 plot_feature_matrix = [feature_vector(rest_index)' feature_vector(prep_index)'];
%                             end
% 
%                             close all
%                             boxplot(plot_feature_matrix);
%                             boxplot_title = sprintf('Box plot of feature values (%s) \nLevels: Rest ? 1, Prep ? 2',feature_title);
%                             title(boxplot_title)
%                             saveas(gca,sprintf('%s/boxplots/%s s%d r%d shift%d prepadd%d.png',path.save,feature_title,s,r,bold_shift,prep_initial_shift))
% 
%                             close all
%                             hold on
%                             hist(plot_feature_matrix);
%                             legend({'Rest';'Prep'})
%                             hist_title = sprintf('Histogram of feature values (%s), Subject %d, Run %d (BOLD shift %ds, Prep Add %ds)',feature_title,s,r,bold_shift*tr_sec,prep_initial_shift*tr_sec);
%                             title(hist_title)
%                             saveas(gca,sprintf('%s/histograms/%s s%d r%d shift%d prepadd%d.png',path.save,feature_title,s,r,bold_shift,prep_initial_shift))
                        else
                            %%

                            switch tb(t)
                                case 'r'
                                    rest_feature_vector = feature_vector(:,rest_index_r_t);
                                    prep_feature_vector = feature_vector(:,prep_index_r_t);

                                    clear threshold
                                    for j = 1:size(feature_vector,1)
                                        threshold(j,:) = linspace(max([feature_vector(j,prep_index_r) feature_vector(j,rest_index_r)]),min([feature_vector(j,prep_index_r) feature_vector(j,rest_index_r)]),number_thresholds);
                                    end

                                    for thresh = 1:number_thresholds
                                        for j = 1:size(feature_vector,1)
                                            detection_table_b(j,thresh,2*t-1) = 9;
                                            if max(rest_feature_vector(j,:) < threshold(j,thresh))
                                                if detection_table_r(j,thresh,2*t-1) ~= 0
                                                    error('Detection value already exists')
                                                end
                                                detection_table_r(j,thresh,2*t-1) = 1;
                                            end
                                            if max(prep_feature_vector(j,:) < threshold(j,thresh))
                                                if detection_table_r(j,thresh,2*t) ~= 0
                                                    error('Detection value already exists')
                                                end
                                                detection_table_r(j,thresh,2*t) = 2;
                                            end
                                        end
                                    end

                                case 'b'
                                    rest_feature_vector = feature_vector(:,rest_index_b_t);
                                    prep_feature_vector = feature_vector(:,prep_index_b_t);

                                    clear threshold
                                    for j = 1:size(feature_vector,1)
                                        threshold(j,:) = linspace(max([feature_vector(j,prep_index_b) feature_vector(j,rest_index_b)]),min([feature_vector(j,prep_index_b) feature_vector(j,rest_index_b)]),number_thresholds);
                                    end

                                    for thresh = 1:number_thresholds
                                        for j = 1:size(feature_vector,1)
                                            detection_table_r(j,thresh,2*t-1) = 9;
                                            if max(rest_feature_vector(j,:) < threshold(j,thresh))
                                                if detection_table_b(j,thresh,2*t-1) ~= 0
                                                    error('Detection value already exists')
                                                end
                                                detection_table_b(j,thresh,2*t-1) = 1;
                                            end
                                            if max(prep_feature_vector(j,:) < threshold(j,thresh))
                                                if detection_table_b(j,thresh,2*t) ~= 0
                                                    error('Detection value already exists')
                                                end
                                                detection_table_b(j,thresh,2*t) = 2;
                                            end
                                        end
                                    end
                            end
                            
                        end
                    end
                    %%
                    clear class_result
                    
                    detection_table = detection_table_b;
                    button_label = 'b';
                    
                    class_result.wrong(1:size(detection_table,1),1:size(detection_table,2)) = NaN;
                    class_result.right(1:size(detection_table,1),1:size(detection_table,2)) = NaN;
                    class_result.overall(1:size(detection_table,1),1:size(detection_table,2)) = NaN;
                    for j=1:size(detection_table,1)
                        temp.wrong = [];
                        temp.right = [];
                        temp.overall = [];
                        for l=1:size(detection_table,2)
                            temp.wrong = [temp.wrong numel(find(squeeze(detection_table(j,l,:)) == 1))/numel(t0)];
                            temp.right = [temp.right numel(find(squeeze(detection_table(j,l,:)) == 2))/numel(t0)];
                        end
                        temp.overall(j,:) = mean([1-temp.wrong' temp.right' ]');
                        
                        class_result.wrong(j,:) = temp.wrong;
                        class_result.right(j,:) = temp.right;
                    end

                    class_result.overall = [1-class_result.wrong' + class_result.right']./2;
                    %%
                    close all
                    h = figure('position',[1 500 1900 300]);
                    imagesc(class_result.overall)
                    voxel_level_title = sprintf('Button %s. Feature - %s, subject %d run %d (BOLD delay %ds, prep starts at %d)',button_label,feature_title,s,r,bold_shift,prep_initial_shift);
                    title(voxel_level_title)
                    xlabel('Voxels in SMN')
                    ylabel('Thresholds')
                    colorbar
                    set(gca, 'CLim', [0 1]);
                    saveas(gca,sprintf('%s/%s.png',path.save,voxel_level_title))
                    %%
                    voxel_freq_value = max(class_result.overall);
                    voxel_freq_vol = voxel_freq_vol_4d(:,:,:,1);
                    voxel_freq_vol_index = find(voxel_freq_vol);

                    if numel(voxel_freq_value) ~= numel(voxel_freq_vol_index)
                        error('Number of mean accuracy values and number of voxels is different')
                    end

                    for v = 1:numel(voxel_freq_value)
                        voxel_freq_vol(voxel_freq_vol_index(v)) = voxel_freq_value(v);
                    end
                    close all
                    vol3d_mri(voxel_freq_vol)
                    voxel_level_title = sprintf('Volume Map. Button %s. Feature - %s, subject %d run %d (BOLD delay %ds, prep starts at %d)',button_label,feature_title,s,r,bold_shift,prep_initial_shift);
                    title(voxel_level_title)
                    colorbar
                    set(gca, 'CLim', [0 1]);
                    saveas(gca,sprintf('%s/%s.png',path.save,voxel_level_title))
                    
                    
                    %%
                    clear class_result
                    
                    detection_table = detection_table_r;
                    button_label = 'r';
                    
                    class_result.wrong(1:size(detection_table,1),1:size(detection_table,2)) = NaN;
                    class_result.right(1:size(detection_table,1),1:size(detection_table,2)) = NaN;
                    class_result.overall(1:size(detection_table,1),1:size(detection_table,2)) = NaN;
                    for j=1:size(detection_table,1)
                        temp.wrong = [];
                        temp.right = [];
                        temp.overall = [];
                        for l=1:size(detection_table,2)
                            temp.wrong = [temp.wrong numel(find(squeeze(detection_table(j,l,:)) == 1))/numel(t0)];
                            temp.right = [temp.right numel(find(squeeze(detection_table(j,l,:)) == 2))/numel(t0)];
                        end
                        temp.overall(j,:) = mean([1-temp.wrong' temp.right' ]');
                        
                        class_result.wrong(j,:) = temp.wrong;
                        class_result.right(j,:) = temp.right;
                    end

                    class_result.overall = [1-class_result.wrong' + class_result.right']./2;
                    %%
                    close all
                    h = figure('position',[1 500 1900 300]);
                    imagesc(class_result.overall)
                    voxel_level_title = sprintf('Button %s. Feature - %s, subject %d run %d (BOLD delay %ds, prep starts at %d)',button_label,feature_title,s,r,bold_shift,prep_initial_shift);
                    title(voxel_level_title)
                    xlabel('Voxels in SMN')
                    ylabel('Thresholds')
                    colorbar
                    set(gca, 'CLim', [0 1]);
                    saveas(gca,sprintf('%s/%s.png',path.save,voxel_level_title))
                    
                    %%
                    voxel_freq_value = max(class_result.overall);
                    voxel_freq_vol = voxel_freq_vol_4d(:,:,:,1);
                    voxel_freq_vol_index = find(voxel_freq_vol);

                    if numel(voxel_freq_value) ~= numel(voxel_freq_vol_index)
                        error('Number of mean accuracy values and number of voxels is different')
                    end

                    for v = 1:numel(voxel_freq_value)
                        voxel_freq_vol(voxel_freq_vol_index(v)) = voxel_freq_value(v);
                    end
                    close all
                    vol3d_mri(voxel_freq_vol)
                    voxel_level_title = sprintf('Volume Map. Button %s. Feature - %s, subject %d run %d (BOLD delay %ds, prep starts at %d)',button_label,feature_title,s,r,bold_shift,prep_initial_shift);
                    title(voxel_level_title)
                    colorbar
                    set(gca, 'CLim', [0 1]);
                    saveas(gca,sprintf('%s/%s.png',path.save,voxel_level_title))
                    
                    %%
%                     
%                     close all
%                     hold on
%                     plot(class_result.wrong,class_result.right,'b','linewidth',2)
%                     plot(0:1,0:1,'k','linewidth',1)
%                     xlabel('False positive rate'),ylabel('True positive rate'),daspect([1 1 1])
%                     roc_title = sprintf('ROC of feature values (%s), Subject %d, Run %d (BOLD shift %ds, Prep Add %ds)',feature_title,s,r,bold_shift*tr_sec,prep_initial_shift*tr_sec);
%                     title(roc_title)
%                     saveas(gca,sprintf('%s/roc/%s s%d r%d shift%d prepadd%d.png',path.save,feature_title,s,r,bold_shift,prep_initial_shift))
% 
% 
%                     export_table = [threshold' detection_table class_result.wrong' class_result.right' class_result.overall'];
%                     xlswrite(sprintf('%s/csv/%s s%d r%d shift%d preppadd%d.csv',path.save,feature_title,s,r,bold_shift,prep_initial_shift),export_table)
% 
%                     %%
% 
%                     prep_duration = response(s,r).rest_response - response(s,r).prep_onset;
% 
%                     plot_line = feature_vector;
%         %             plot_line = feature_dmn{2};
%                     plot_line = [zeros([1 size(matrix,2)-size(plot_line,2)]) plot_line];
%                     fig_line_color = 'b';
% 
%                     time_index = (0:tr_sec:tr_sec*(size(matrix,2)-1))-bold_shift*tr_sec;
% 
%                     close all
%                     h = figure('position',[1 500 1900 300]);
%                     hold on
%                     for p = 1:length(prep_duration)
%                         area(tr_sec*[tp(p) tp(p)+prep_duration(p)],[max(plot_line) max(plot_line)],'facecolor',fig_area_color,'edgecolor',fig_area_color);
%                         area(tr_sec*[tp(p) tp(p)+prep_duration(p)],[min(plot_line) min(plot_line)],'facecolor',fig_area_color,'edgecolor',fig_area_color);
%                     end
%                     for p = 1:length(t0)
%                         area(tr_sec*[t0(p) t0(p)+.1],[max(plot_line(:)) max(plot_line(:))],'facecolor',fig_press_color,'edgecolor',fig_press_color);
%                         area(tr_sec*[t0(p) t0(p)+.1],[min(plot_line(:)) min(plot_line(:))],'facecolor',fig_press_color,'edgecolor',fig_press_color);
%                     end
% 
%                     plot(time_index,mean_smn-mean(mean_smn(:)),'color',[1 .7 .7],'linewidth',1)
%                     plot(time_index,mean_dmn-mean(mean_dmn(:)),'color',[.7 1 .7],'linewidth',1)
% 
%         %             plot(time_index,plot_line,'color',fig_line_color,'linewidth',2)
%                     scatter(time_index,plot_line,7)
% 
%                     textTitle = sprintf('Mean feature plot (%s) Subject %d, Run %d (BOLD shift %ds, Prep Add %ds)',feature_title,s,r,bold_shift*tr_sec,prep_initial_shift*tr_sec);
%                     title(textTitle,'FontName','Monaco','FontSize',13)
%                     set(gca,'LooseInset',get(gca,'TightInset'))
%                     set(h,'PaperPositionMode','auto');
%                     box off
% 
%                     ylim([min(plot_line(:)) max(plot_line(:))])
%                     xlim([min(time_index) max(time_index)])
% 
%                     title(roc_title)
%                     saveas(gca,sprintf('%s/feature_plots/%s s%d r%d shift%d prepadd%d.png',path.save,feature_title,s,r,bold_shift,prep_initial_shift))
                end
            end
        end
    end
end
fprintf('\nDone.\n')















































