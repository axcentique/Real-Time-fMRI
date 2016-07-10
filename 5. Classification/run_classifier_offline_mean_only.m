% run classification for all scan sessions
run ~/Desktop/scripts/rtfMRI_import_responses_round_plus1.m

path.feat = '~/Desktop/FEAT_group_analysis/transformed_contrasts_contrasts/';
path.save = '~/Desktop/rtfMRI Reports/13:3:21';

rest_num = 1;
dmn_seed = 1;
dmn_corr_thresh = .33;

prep_initial_shift = -1;
tr_sec = 2;

fig_area_color = [.7 .7 .7];
fig_press_color = [.7 0 0];

z_dmn = -2.3;
z_smn = 6;
bold_shift = 2;

for s = 4%[4 6 7 8 10]
    fprintf('\n\nSubject %d',s)
    for r = 1%:5
        fprintf('\n Run %d',r)
        cd('/Users/george/Data/rtfMRI/August/subjects/preprocessed/dmn/transformed_dmn_maps/')

        path.func = sprintf('/Users/george/Data/rtfMRI/August/Processing/subject%d/run%d_elliot.nii.gz',s,r);
        path.func_hipass = sprintf('/Users/george/Data/rtfMRI/August/subjects/filtered/subject%d_run%d_hi_pass_5.nii.gz',s,r);
        path.zmap = sprintf('%ssubject%d_run%d_contrast1_exclude%d_mni_1mm_in_func.nii.gz',path.feat,s,r,s);
        path.dmn = sprintf('subject%d_rest%d_dmn%d_IN_run%d.nii.gz',s,rest_num,dmn_seed,r);

        func = MRIread(path.func);
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
        thresholded_zmap_smn = zeros(size(zmap.vol));
        thresholded_zmap_smn(find(zmap.vol>z_smn)) = 1;

        thresholded_zmap_smn(size(thresholded_zmap_smn,1):-1:floor(size(thresholded_zmap_smn,1)-size(thresholded_zmap_smn,1)/2.2),:,:) = 0;
        thresholded_zmap_smn(1:floor(size(thresholded_zmap_smn,1)/4.5),:,:) = 0;
        thresholded_zmap_smn(:,1:floor(size(thresholded_zmap_smn,2)/2),:) = 0;
        thresholded_zmap_smn(:,:,1:floor(size(thresholded_zmap_smn,3)/2)) = 0;

%         vol3d_mri(thresholded_zmap_smn)

        %%

        matrix = rtfMRI_volume2matrix(mask_volume(func.vol,thresholded_zmap_smn));
%         matrix = rtfMRI_volume2matrix(mask_volume(func_hipass.vol,thresholded_zmap_smn));
        matrix_hi = rtfMRI_volume2matrix(mask_volume(func_hipass.vol,thresholded_zmap_dmn));

        mean_smn = mean(matrix);
        mean_dmn = mean(matrix_hi);
        %%

        feature_dmn{1} = mean_dmn;
        feature_dmn_index{1} = 1:size(feature_dmn{1},2);
        [feature_dmn{2} feature_dmn_index{2}] = feature_derivative(mean_dmn);

        [feature_both{1} feature_both_index{1}] = feature_anticorr(mean_dmn,mean_smn);


        %%

        for bold_shift = 2%[2 3]           
            %%
            feature_vector = feature_both{1};
            index_vector = feature_both_index{1};
            
            for t = 0%:numel(t0)
                prep_index	 = [];
                prep_index_t = [];
                if t~=1
                    rest_index   = (1:response(s,r).prep_onset(j)-1) +prep_initial_shift;
                else
                    rest_index = [];
                end
                
                for j=1:numel(response(s,r).rest_response)-1
                    if j==t
                        if t~=1
                            rest_index_t = (response(s,r).rest_response(j)+1):(response(s,r).prep_onset(j+1)-1 +prep_initial_shift);
                        else
                            rest_index_t = 1:response(s,r).prep_onset(j)-1 +prep_initial_shift;
                        end
                    else
                        rest_index = [rest_index response(s,r).rest_response(j)+1:response(s,r).prep_onset(j+1)-1+prep_initial_shift];
                    end
                end

                
                for j=1:numel(response(s,r).prep_onset)
                    if j==t
                        prep_index_t = response(s,r).prep_onset(j)+prep_initial_shift:response(s,r).rest_response(j);
                    else
                        prep_index = [prep_index response(s,r).prep_onset(j)+prep_initial_shift:response(s,r).rest_response(j)];
                    end
                end
                if ~isempty(intersect(rest_index,prep_index))
                    intersect(rest_index,prep_index)
                    error('Indexes of resting and preping vactors intersect.')
                end
                %%
                rest_index = intersect(index_vector,rest_index) + bold_shift;
                prep_index = intersect(index_vector,prep_index) + bold_shift;
                
                if t == 0
                    if numel(rest_index) > numel(prep_index)
                        plot_feature_matrix = [ feature_vector(rest_index)' [feature_vector(prep_index) linspace(NaN,NaN,numel(rest_index) - numel(prep_index))]' ];
                    end
                    if numel(rest_index) < numel(prep_index)
                        plot_feature_matrix = [ [feature_vector(rest_index) linspace(NaN,NaN,numel(prep_index) - numel(rest_index))]' feature_vector(prep_index)'];
                    end
                    if numel(rest_index) == numel(prep_index)
                        plot_feature_matrix = [feature_vector(rest_index)' feature_vector(prep_index)'];
                    end
                    
                    close all
                    boxplot(plot_feature_matrix);
                    boxplot_title = sprintf('Box plot of feature values (DMN BOLD derivative) \nLevels: Rest ? 1, Prep ? 2');
                    title(boxplot_title)
                    saveas(gca,sprintf('%s/boxplots/Boxplot s%d r%d shift%d.png',path.save,s,r,bold_shift))
                    
                    close all
                    hold on
                    hist(plot_feature_matrix);
                    legend({'Rest';'Prep'})
                    hist_title = sprintf('Histogram of feature values (DMN BOLD derivative)');
                    title(hist_title)
                    saveas(gca,sprintf('%s/histograms/Histogram s%d r%d shift%d.png',path.save,s,r,bold_shift))
                else
                    %%
                    threshold = mean([feature_vector(prep_index_t) feature_vector(rest_index_t)]);
                    
                    t0 = response(s,r).rest_response + bold_shift;
                    tp = response(s,r).prep_onset + bold_shift;
                    
                    rest_index = tr(j):tp(j)-1 + prep_initial_shift;
                    prep_index = tp(j) + prep_initial_shift : t0(j);
                    rest_bold = mean(matrix(:,rest_index));
                    prep_bold = mean(matrix(:,prep_index));
                    
                    
                    
                    
                    
                    
                end
                
            end
            
            
            %%
            f1 = 2;
            f2 = 1;
            feature_vector1 = feature_dmn{f1};
            feature_vector2 = feature_dmn{f2};
%             feature_vector_index = feature_dmn_index{f};

                rest_index = rest_index + bold_shift;
                prep_index = prep_index + bold_shift;

                feature_vector1 = [zeros([1 size(matrix,2)-size(feature_vector1,2)]) feature_vector1]; 
                feature_vector2 = [zeros([1 size(matrix,2)-size(feature_vector2,2)]) feature_vector2]; 

                rest_value1 = feature_vector1(rest_index);
                prep_value1 = feature_vector1(prep_index);
                rest_value2 = feature_vector2(rest_index);
                prep_value2 = feature_vector2(prep_index);
                
                figure
                hold on
                scatter(rest_value1,rest_value2,'g')

            end
            
            %%
            t0 = response(s,r).rest_response;       % get all responce event volumes
            tp = response(s,r).prep_onset;
            tr = [1; response(s,r).rest_onset(1:numel(response(s,r).rest_onset)-1)];

            prep_duration = response(s,r).rest_response - response(s,r).prep_onset;
            prep_onset = response(s,r).prep_onset;


            feature_name = '';
    %         plot_line = feature_both{1};
            plot_line = feature_dmn{2};
            plot_line = [zeros([1 size(matrix,2)-size(plot_line,2)]) plot_line];
            fig_line_color = 'b';

            time_index = (0:tr_sec:tr_sec*(size(matrix,2)-1))-bold_shift*tr_sec;

            close all
            h = figure('position',[1 500 1900 300]);
            hold on
            for p = 1:length(prep_duration)
                area(tr_sec*[prep_onset(p) prep_onset(p)+prep_duration(p)],[max(plot_line) max(plot_line)],'facecolor',fig_area_color,'edgecolor',fig_area_color);
                area(tr_sec*[prep_onset(p) prep_onset(p)+prep_duration(p)],[min(plot_line) min(plot_line)],'facecolor',fig_area_color,'edgecolor',fig_area_color);
            end
            for p = 1:length(t0)
                area(tr_sec*[t0(p) t0(p)+.1],[max(plot_line(:)) max(plot_line(:))],'facecolor',fig_press_color,'edgecolor',fig_press_color);
                area(tr_sec*[t0(p) t0(p)+.1],[min(plot_line(:)) min(plot_line(:))],'facecolor',fig_press_color,'edgecolor',fig_press_color);
            end

%             plot(time_index,mean_smn-mean(mean_smn(:)),'r','linewidth',2)
            plot(time_index,mean_dmn-mean(mean_dmn(:)),'g','linewidth',2)
            
            plot(time_index,plot_line,'color',fig_line_color,'linewidth',2)

            textTitle = sprintf('%s of Subject %d, Session %d (Time Shift %d s.)',feature_name,s,r,bold_shift*tr_sec);
            title(textTitle,'FontName','Monaco','FontSize',13)
            set(gca,'LooseInset',get(gca,'TightInset'))
            set(h,'PaperPositionMode','auto');
            box off

            ylim([min(plot_line(:)) max(plot_line(:))])
            xlim([min(time_index) max(time_index)])

        
        end
    end
end
fprintf('\nDone.\n')















































