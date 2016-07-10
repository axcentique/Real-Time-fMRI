% run classification for all scan sessions
run ~/Desktop/scripts/rtfMRI_import_responses_round_plus1.m

path.feat = '~/Desktop/FEAT_group_analysis/transformed_contrasts_contrasts/';
path.save = '~/Desktop/rtfMRI Reports/13:4:22-motor';

rest_num = 1;
dmn_seed = 1;
dmn_corr_thresh = .33;


number_thresholds = 30;
tr_sec = 2;

fig_area_color = [.7 .7 .7];
fig_press_color = [.7 0 0];

omit_run{4} = [];
z_smn{4} = 4;
z_dmn{4} = -1.5;

omit_run{6} = [];
z_smn{6} = 2.3;
z_dmn{6} = -1.5;

omit_run{7} = 4;
z_smn{7} = 4;
z_dmn{7} = -.5;

omit_run{8} = [];
z_smn{8} = 4;
z_dmn{8} = -.5;

omit_run{10} = 4;
z_smn{10} = 4;
z_dmn{10} = -1.5;


% for f = 1:6
%     class_result_cumulative{f}.wrong = [];
%     class_result_cumulative{f}.right = [];
%     class_result_cumulative{f}.overall = [];
% end
%%
for s = [4 6 7 8 10]
    fprintf('\n\nLoading Subject %d',s)
    for r = 1:5
        if ~isempty(find(omit_run{s} == r))
            continue
        end
        fprintf('\nLoading Run %d',r)
        if char(mean(response(s,r).rest_button)) == 'r' || char(mean(response(s,r).rest_button)) == 'b' || numel(find(response(s,r).rest_button=='r'))+numel(find(response(s,r).rest_button=='b')) ~= 21
            continue
        end
        cd('/Users/george/Data/rtfMRI/August/subjects/preprocessed/dmn/transformed_dmn_maps/')

%         path.func = sprintf('/Users/george/Data/rtfMRI/August/Processing/subject%d/run%d_elliot.nii.gz',s,r);
        path.func_hipass = sprintf('/Users/george/Data/rtfMRI/August/subjects/filtered/subject%d_run%d_band_pass.nii.gz',s,r);
%         path.zmap_dmn = sprintf('%ssubject%d_run%d_contrast1_exclude%d_mni_1mm_in_func.nii.gz',path.feat,s,r,s);
        path.zmap_smn = sprintf('/Users/george/Data/rtfMRI/August/subjects/feat+ica/subject%d_run%d.feat/stats/zstat1.nii.gz',s,r);
%         path.dmn = sprintf('subject%d_rest%d_dmn%d_IN_run%d.nii.gz',s,rest_num,dmn_seed,r);

%         func = MRIread(path.func);
        func_hipass = MRIread(path.func_hipass);
%         zmap_dmn = MRIread(path.zmap_dmn);
        zmap_smn = MRIread(path.zmap_smn);
%         dmn_map = MRIread(path.dmn);

        cd('/Users/george/dev/rtfMRI_classifier')
        %%
%         dmn_map_vol = zeros(size(dmn_map.vol));
%         dmn_map_vol(find(dmn_map.vol>dmn_corr_thresh)) = 1;

%         thresholded_zmap_dmn = zeros(size(zmap_dmn.vol));
%         thresholded_zmap_dmn(find(zmap_dmn.vol<z_dmn{s})) = 1;
%         thresholded_zmap_dmn = thresholded_zmap_dmn .* dmn_map_vol;

        %%
        thresholded_zmap_smn = zeros(size(zmap_smn.vol));
        thresholded_zmap_smn(find(zmap_smn.vol>z_smn{s})) = 1;
        
        thresholded_zmap_smn(size(thresholded_zmap_smn,1):-1:floor(size(thresholded_zmap_smn,1)-size(thresholded_zmap_smn,1)/2.2),:,:) = 0;
        thresholded_zmap_smn(1:floor(size(thresholded_zmap_smn,1)/4.5),:,:) = 0;
        thresholded_zmap_smn(:,1:floor(size(thresholded_zmap_smn,2)/2),:) = 0;
        thresholded_zmap_smn(:,:,1:floor(size(thresholded_zmap_smn,3)/2)) = 0;

%         vol3d_mri(thresholded_zmap_smn)

        %%

        matrix = rtfMRI_volume2matrix(mask_volume(func_hipass.vol,thresholded_zmap_smn));
%         matrix = rtfMRI_volume2matrix(mask_volume(func_hipass.vol,thresholded_zmap_smn));
%         matrix_hi = rtfMRI_volume2matrix(mask_volume(func_hipass.vol,thresholded_zmap_dmn));

%         mean_smn = mean(matrix);
%         mean_dmn = mean(matrix_hi);
        mean_smn = demean_rows(matrix);
%         mean_dmn = demean_rows(matrix_hi);
        %%
        clear feature feature_index feature_name

%         feature{1} = mean_dmn;
%         feature_index{1} = 1:size(feature{1},2);
%         feature_name{1} = 'Mean DMN BOLD';
%         
%         [feature{2} feature_index{2}] = feature_derivative(mean_dmn);
%         feature_name{2} = 'Mean DMN BOLD Derivative';
        
        feature{1} = mean_smn;
        feature_index{1} = 1:size(feature{1},2);
        feature_name{1} = 'Mean SMN BOLD';
        
        [feature{2} feature_index{2}] = feature_derivative(mean_smn);
        feature_name{2} = 'Mean SMN BOLD Derivative';

%         [feature{5} feature_index{5}] = feature_anticorr(mean_dmn,mean_smn);
%         feature_name{5} = 'DMN & SMN BOLD derivative substraction';
%         
%         [feature{6} feature_index{6}] = feature_anticorr_multi(mean_dmn,mean_smn);
%         feature_name{6} = 'DMN & SMN BOLD derivative multiplication';

        %%

        for f = 2%1:numel(feature)
            %%
            feature_vector = feature{f};
            index_vector = feature_index{f};
            feature_title = feature_name{f};
            index_shift = numel(index_vector) - size(matrix,2);
            
            
            for number_selected_voxels = 10%5:5:50
                for pret0 = 0%:2
                    for bold_shift = 3%[2 3]
                        for prep_initial_shift = -1%[-1 0]

                            t0 = response(s,r).rest_response + bold_shift;       % get all responce event volumes
                            tp = response(s,r).prep_onset + bold_shift;
                            tr = [1; response(s,r).rest_response(1:numel(response(s,r).rest_response)-1)+1] + bold_shift;
                            tb = response(s,r).rest_button;

        %                     detection_table = zeros([number_thresholds numel(t0)*2]);

                            ntest = 1;
                            ntrain = numel(t0) - ntest;

                            test_bold_debug_prep_b = [];
                            test_bold_debug_prep_r = [];

                            for t = 1:numel(t0) %0:numel(t0)
                                clc
                                fprintf('\n\nSubject %d, Run %d, Trial %d/%d',s,r,t,numel(t0))
                                prep_index1 = [];
                                prep_index2 = [];
                                prep_train1 = [];
                                prep_train2 = [];

                                nont_tb = char(mean(tb(find(tb ~= tb(t)))));
                                if max(nont_tb == 'rb') == 0
                                    error('More than two buttons were pressed?')
                                end

                                for j = 1:length(tp)
                                    if j==t
                                        prep_index_t = tp(j)+prep_initial_shift:t0(j);
        %                                 prep_test = mean(feature_vector(:,prep_index_t + index_shift)');
                                        prep_test = feature_vector(:,prep_index_t(end-pret0) + index_shift)';
                                    else
                                        if tb(t) == tb(j)
                                            prep_index_j = tp(j)+prep_initial_shift:t0(j);
                                            prep_index1 = [prep_index1 prep_index_j];
        %                                     prep_train1 = [prep_train1; mean(feature_vector(:,prep_index_j + index_shift)')];
                                            prep_train1 = [prep_train1; feature_vector(:,prep_index_j(end-pret0) + index_shift)'];
                                        else
                                            prep_index_j = tp(j)+prep_initial_shift:t0(j);
                                            prep_index2 = [prep_index2 prep_index_j];
        %                                     prep_train2 = [prep_train2; mean(feature_vector(:,prep_index_j + index_shift)')];
                                            prep_train2 = [prep_train2; feature_vector(:,prep_index_j(end-pret0) + index_shift)'];
                                        end
                                    end
                                end
                                clear prep_index_j

                                [Y I] = sort(abs(mean(prep_train1)-mean(prep_train2)),'descend');
                                selected_voxels = I(1:number_selected_voxels);
%                                 selected_voxels = ':';

                                if ~isempty(intersect(prep_index1,prep_index2))
                                    intersect(prep_index1,prep_index2)
                                    error('Indexes of motor vectors intersect.')
                                end

                                %%
        %                         rest_index = intersect(index_vector,rest_index);
        %                         prep_index = intersect(index_vector,prep_index);

                                %%
                                train_bold = [prep_train1; prep_train2];
                                train_label = char([linspace(tb(t),tb(t),size(prep_train1,1)) linspace(nont_tb,nont_tb,size(prep_train2,1))])';
                                test_bold = prep_test;
                                test_label = char(linspace(tb(t),tb(t),size(prep_test,1)))';

                                switch tb(t)
                                    case 'b'
                                        test_bold_debug_prep_b = [test_bold_debug_prep_b; test_bold(:,selected_voxels)];
                                    case 'r'
                                        test_bold_debug_prep_r = [test_bold_debug_prep_r; test_bold(:,selected_voxels)];
                                end
                                %%
                                SVMStruct = svmtrain(train_bold(:,selected_voxels),train_label);
                                test_svm_label{t} = svmclassify(SVMStruct,test_bold(:,selected_voxels));
        %                         test_svm_label_size(t) = numel(test_svm_label{t});
        %                         test_svm_label_size_rest(t) = size(rest_test,1);
        %                         test_svm_label_size_prep(t) = size(prep_test,1);
                                clear SVMStruct 
        %                         %%
        %                         if t ~= 0
        %                             rest_feature_vector = feature_vector(:,rest_index_t);
        %                             prep_feature_vector = feature_vector(:,prep_index_t);
        % 
        % %                             threshold = linspace(max([feature_vector(prep_index) feature_vector(rest_index)]),min([feature_vector(prep_index) feature_vector(rest_index)]),number_thresholds);
        % 
        %                             for thresh = 1:numel(threshold)
        %                                 if max(rest_feature_vector < threshold(thresh)) ~= 0
        %                                     if detection_table(thresh,2*t-1) ~= 0
        %                                         error('Detection value already exists')
        %                                     end
        %                                     detection_table(thresh,2*t-1) = 1;
        %                                 end
        %                                 if max(prep_feature_vector < threshold(thresh)) ~= 0
        %                                     if detection_table(thresh,2*t) ~= 0
        %                                         error('Detection value already exists')
        %                                     end
        %                                     detection_table(thresh,2*t) = 2;
        %                                 end
        %                             end
        %                         end                
                            end
                            fprintf('\n')
                            %
        %                     im_label = zeros([max(test_svm_label_size(:)) numel(t0)]);
        %                     ts_label = [];
        %                     for t = 1:numel(t0)
        %                         im_label(end-test_svm_label_size(t)+1:end,t) = test_svm_label{t};
        %                         ts_label = [ts_label test_svm_label{t}'];
        %                     end
        %                     imagesc(im_label)

        %                     hold on
        %                     plot(tr(1):t0(end),ts_label,'r')
        %                     plot((1:size(mean_dmn,2))+bold_shift,mean(mean_dmn))
                            %
        %                     close all
        %                     avg_bold(response,s,r,[zeros([1 tr(1) - 1]) ts_label zeros([1 size(matrix,2) - (numel(ts_label) + tr(1) - 1)])],tr_sec*index_shift,'r',' ')
        %                     saveas(gca,sprintf('%s/%s svm labels s%d r%d shift%d prep%d.png',path.save,feature_title,s,r,bold_shift,prep_initial_shift))

                            %

        %                     imagesc([test_bold_debug(1:2:end,:); test_bold_debug(2:2:end,:)])
        %                     clear test_bold_debug

%                             clear accuracy
        %                     for t=1:numel(t0)
        %                         accuracy(t) = mean([linspace(1,1,test_svm_label_size_rest(t)) linspace(2,2,test_svm_label_size_prep(t))] == test_svm_label{t}');
        %                     end

%                             accuracy = [tb' == [test_svm_label{:}]];
%                             accuracy_total{s,r,pret0+1,number_selected_voxels/5} = accuracy;
%                             accuracy_mean(s,r,pret0+1,number_selected_voxels/5) = mean(accuracy);
                            
                            accuracy_mean_r(s,r) = mean(tb(find(tb=='r'))' == [test_svm_label{find(tb=='r')}]);
                            accuracy_mean_b(s,r) = mean(tb(find(tb=='b'))' == [test_svm_label{find(tb=='b')}]);

        %                     test_svm_label_session = [test_svm_label{:}];
        %                     accuracy_rest{s,r,f,bold_shift,prep_initial_shift+2} = numel(find(test_svm_label_session(1,:) == label_rest)) / numel(t0);
        %                     accuracy_prep{s,r,f,bold_shift,prep_initial_shift+2} = numel(find(test_svm_label_session(2,:) == label_prep)) / numel(t0);

        %                     mean([accuracy_rest{s,r,f,bold_shift,prep_initial_shift+2} accuracy_prep{s,r,f,bold_shift,prep_initial_shift+2}])

        %                     class_result.wrong = [];
        %                     class_result.right = [];
        %                     for j=1:size(detection_table,1)
        %                         class_result.wrong = [class_result.wrong numel(find(detection_table(j,:) == 1))/numel(t0)];
        %                         class_result.right = [class_result.right numel(find(detection_table(j,:) == 2))/numel(t0)];
        %                     end
        %                     class_result.overall = mean([1-class_result.wrong' class_result.right' ]');
        % 
        %                     
        %                     class_result_cumulative{f}.wrong = [class_result_cumulative{f}.wrong; class_result.wrong];
        %                     class_result_cumulative{f}.right = [class_result_cumulative{f}.right; class_result.right];
        %                     class_result_cumulative{f}.overall = [class_result_cumulative{f}.overall; class_result.overall];

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

                            %%

        %                     prep_duration = response(s,r).rest_response - response(s,r).prep_onset;
        % 
        %                     plot_line = feature_vector;
        %         %             plot_line = feature_dmn{2};
        %                     plot_line = [zeros([1 size(matrix,2)-size(plot_line,2)]) plot_line];
        %                     fig_line_color = 'b';
        % 
        %                     time_index = (0:tr_sec:tr_sec*(size(matrix,2)-1))-bold_shift*tr_sec;
        %                     %%
        %                     close all
        %                     avg_bold(response,s,r,feature_vector,'g',feature_title)
        %                     line([time_index(1) time_index(end)],[mean(feature_vector) mean(feature_vector)],'color','r')



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
    end
end

%%
clc

out_table_avg = [];
out_table_range = [];

for s = [4 6 7 8 10]
    temp_subj = [];
    for r = 1:5
        if (accuracy_mean_r(s,r)) ==0 && (accuracy_mean_b(s,r) == 0)
            continue
        else
            temp_subj = [temp_subj; accuracy_mean_r(s,r) accuracy_mean_b(s,r)];
        end
    end
    out_table_avg = [out_table_avg; mean(temp_subj)];
    out_table_range = [out_table_range; min(temp_subj) max(temp_subj)];
end

out_table_r = [out_table_avg(:,1) out_table_range(:,[1 3])]
out_table_b = [out_table_avg(:,2) out_table_range(:,[2 4])]



%%
% for f = 1:6
%     close all
%     hold on
%     plot(mean(class_result_cumulative{f}.wrong),mean(class_result_cumulative{f}.right),'b','linewidth',2)
%     plot(0:1,0:1,'k','linewidth',1)
%     xlabel('False positive rate'),ylabel('True positive rate'),daspect([1 1 1])
%     roc_title = sprintf('ROC of feature values (%s), Group plot (BOLD shift %ds, Prep Add %ds)',feature_name{f},bold_shift*tr_sec,prep_initial_shift*tr_sec);
%     title(roc_title)
%     saveas(gca,sprintf('%s/roc/%s group shift%d prepadd%d.png',path.save,feature_name{f},bold_shift,prep_initial_shift))
% end
% 
% fprintf('\nDone.\n')
clc


% close all
% figure
% hold on

plotline_bold = [];
plotline_prep = [];
for s = [4 6 7 8 10]
    for r = 1:5
        for f = 2%:4
            for prep_initial_shift = 1:2
                plotline_bold = [plotline_bold; accuracy_rest{s,r,f,[2 end],prep_initial_shift} accuracy_prep{s,r,f,[2 end],prep_initial_shift}];                
            end
            for bold_shift = 1:2
                plotline_prep = [plotline_prep; accuracy_rest{s,r,f,bold_shift,[1 end]} accuracy_prep{s,r,f,bold_shift,[1 end]}];
            end
        end
    end
end

% mean(plotline_bold)
mean(plotline_bold(:,1:2) + plotline_bold(:,3:4))/2

% mean(plotline_prep)
mean(plotline_prep(:,1:2) + plotline_prep(:,3:4))/2

% imagesc((plotline_bold(:,1:2) + plotline_bold(:,3:4))/2)
% imagesc((plotline_prep(:,1:2) + plotline_prep(:,3:4))/2)

% imagesc(plotline_bold(1:2:end,:))
% imagesc(plotline_bold(2:2:end,:))
% imagesc(plotline_prep(1:2:end,:))
% imagesc(plotline_prep(2:2:end,:))




%%
accuracy_mean(s,r,pret0+1,:)

%%

clc
clear table_csv_out

table_csv_out{1,3} = 5;
table_csv_out{1,4} = 10;
table_csv_out{1,5} = 15;
table_csv_out{1,6} = 20;
table_csv_out{1,7} = 25;

index_csv = 2;
for s = [4 6 7 8 10]
    for r = 1:5
        table_csv_out{index_csv,1} = sprintf('Subject %d, Run %d',s,r);
        for v = 1:5
            table_csv_out{index_csv,v+1} = mean(accuracy_total{s,r,3,v});
        end
        index_csv = index_csv + 1;
    end
end

cell2csv('~/Desktop/motor_decoding_pt_-2.csv',table_csv_out)
































