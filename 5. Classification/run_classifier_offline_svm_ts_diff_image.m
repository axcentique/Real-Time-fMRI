feature_vector = feature{f};
index_vector = feature_index{f};
feature_title = feature_name{f};
index_shift = numel(index_vector) - size(matrix,2);


for number_selected_voxels = 15%5:5:50
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


                %%

                feature_vector_1 = [];
                feature_vector_2 = [];
                for i = 1:size(feature_vector,1)
                    parfor j = 1:size(feature_vector,1)
                        feature_vector_1 = [feature_vector_1; feature_vector(i,:)];
                    end
                    feature_vector_2 = [feature_vector_2; feature_vector];
                    i/size(feature_vector,1)
                end

                new_feature_vector = feature_vector_1 - feature_vector_2;
                
                %%
                index_substract = 0;
                preps_b = [];
                preps_r = [];
                
                feature_vector_b = [];
                feature_vector_r = [];
                for j = 1:numel(tp)
                    switch tb(j)
                        case 'b'
                            preps_b = [preps_b tp(j)+prep_initial_shift:t0(j)];
%                             [mx ind] = max(feature_vector(:,preps_b)');
%                             
%                             clear feature_vector_value_b
%                             for i = 1:size(feature_vector,1)
%                                 feature_vector_value_b(i) = feature_vector(i,ind(i));
%                             end
%                             
%                             feature_vector_b = [feature_vector_b feature_vector_value_b'];
                            
%                             preps_b = [preps_b t0(j)-index_substract:t0(j)];
                        case 'r'
                            preps_r = [preps_r tp(j)+prep_initial_shift:t0(j)];
%                             [mx ind] = max(feature_vector(:,preps_r)');
%                             
%                             clear feature_vector_value_r
%                             for i = 1:size(feature_vector,1)
%                                 feature_vector_value_r(i) = feature_vector(i,ind(i));
%                             end
% 
%                             feature_vector_r = [feature_vector_r feature_vector_value_r'];
                            
%                             preps_r = [preps_r t0(j)-index_substract:t0(j)];
                    end
                end
                
                imagesc([feature_vector(:,preps_b) feature_vector(:,preps_r)])
                hold on
                
                for i = 1:numel(tb)
                    l = line([t0(i) t0(i)], [0 size(feature_vector,1)]);
                    switch tb(i)
                        case 'b'
                            set(l,'Color','b')
                        case 'r'
                            set(l,'Color','r')
                    end
                end

                %%
                [tap_dif_b tap_ind_b] = sort(mean(feature_vector_b')'-mean(feature_vector_r')');
                [tap_dif_r tap_ind_r] = sort(mean(feature_vector_r')'-mean(feature_vector_b')');
                
                %%
                
                selection_size = 20;
                smn_voxel_index = find(thresholded_zmap_smn);
                tap_diff_vol = zeros(size(thresholded_zmap_smn));
                tap_diff_vol(smn_voxel_index(tap_ind_b(1:selection_size))) = 7;%+max(t1.vol(:));
                tap_diff_vol(smn_voxel_index(tap_ind_r(1:selection_size))) = 10;%+max(t1.vol(:));
                
                %%
                vol3d_mri(tap_diff_vol)
%                 vol3d_mri(tap_diff_vol+t1.vol)
                
%%
                
                feature_vector_1 = [];
                feature_vector_2 = [];
                for i = 1:size(feature_vector,1)
                    parfor j = 1:size(feature_vector,1)
                        feature_vector_1 = [feature_vector_1; feature_vector(i,preps_b)];
                    end
                    feature_vector_2 = [feature_vector_2; feature_vector(:,preps_r)];
                    clc
                    i/size(feature_vector,1)
                end

                new_feature_vector = feature_vector_1 - feature_vector_2;

                %%
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

                accuracy_mean_r(s,r)
                accuracy_mean_b(s,r)

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