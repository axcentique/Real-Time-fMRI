% run classification for all scan sessions
run ~/Desktop/scripts/rtfMRI_import_responses_round_plus1.m

path.feat = '~/Desktop/FEAT_group_analysis/transformed_contrasts_contrasts/';
path.save = '~/Desktop/rtfMRI Reports/13:5:23';

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
        path.t1 = sprintf('/Users/george/Data/rtfMRI/August/subjects/transformations/subject%d_run%d_t1INfunc.nii.gz',s,r);
        path.func_hipass = sprintf('/Users/george/Data/rtfMRI/August/subjects/filtered/subject%d_run%d_band_pass.nii.gz',s,r);
%         path.zmap_dmn = sprintf('%ssubject%d_run%d_contrast1_exclude%d_mni_1mm_in_func.nii.gz',path.feat,s,r,s);
        path.zmap_smn = sprintf('/Users/george/Data/rtfMRI/August/subjects/feat+ica/subject%d_run%d.feat/stats/zstat1.nii.gz',s,r);
%         path.dmn = sprintf('subject%d_rest%d_dmn%d_IN_run%d.nii.gz',s,rest_num,dmn_seed,r);

%         func = MRIread(path.func);
        func_hipass = MRIread(path.func_hipass);
%         zmap_dmn = MRIread(path.zmap_dmn);
        zmap_smn = MRIread(path.zmap_smn);
%         dmn_map = MRIread(path.dmn);
%         t1 = MRIread(path.t1);

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
%         mean_smn = demean_rows(matrix);
%         mean_dmn = demean_rows(matrix_hi);
        %%
        clear feature feature_index feature_name

%         feature{1} = mean_dmn;
%         feature_index{1} = 1:size(feature{1},2);
%         feature_name{1} = 'DMN BOLD';
%         
%         [feature{2} feature_index{2}] = feature_derivative(mean_dmn);
%         feature_name{2} = 'DMN BOLD Derivative';
        
%         feature{1} = mean_smn;
%         feature_index{1} = 1:size(feature{1},2);
%         feature_name{1} = 'SMN BOLD';
%         
%         [feature{2} feature_index{2}] = feature_derivative(mean_smn);
%         feature_name{2} = 'SMN BOLD Derivative';

        [feature{1} feature_index{1}] = feature_teager(matrix);
        feature_name{1} = '(Teager)';

%         [feature{5} feature_index{5}] = feature_anticorr(mean_dmn,mean_smn);
%         feature_name{5} = 'DMN & SMN BOLD derivative substraction';
%         
%         [feature{6} feature_index{6}] = feature_anticorr_multi(mean_dmn,mean_smn);
%         feature_name{6} = 'DMN & SMN BOLD derivative multiplication';

        %%

        for f = 1%:numel(feature)
            %%
            feature_vector = feature{f};
            index_vector = feature_index{f};
            feature_title = feature_name{f};
            index_shift = numel(index_vector) - size(matrix,2);
            %%
            
            for number_selected_voxels = 0%5:5:50
                for pret0 = 0%:2
                    for bold_shift = 3%[2 3]
                        for prep_initial_shift = -1%[-1 0]

                            t0 = response(s,r).rest_response + bold_shift;       % get all responce event volumes
                            tp = response(s,r).prep_onset + bold_shift;
                            tr = [1; response(s,r).rest_response(1:numel(response(s,r).rest_response)-1)+1] + bold_shift;
                            tb = response(s,r).rest_button;
                            
                            %%
                            close all
                            
%                             index_substract = 0;
%                             preps_b = [];
%                             preps_r = [];
%                             t0_b = [];
%                             t0_r = [];
% 
%                             feature_vector_b = [];
%                             feature_vector_r = [];
%                             for j = 1:numel(tp)
%                                 switch tb(j)
%                                     case 'b'
%                                         preps_b = [preps_b tp(j)+prep_initial_shift:t0(j)];
%                                         t0_b = [t0_b t0(j)];
%             %                             [mx ind] = max(feature_vector(:,preps_b)');
%             %                             
%             %                             clear feature_vector_value_b
%             %                             for i = 1:size(feature_vector,1)
%             %                                 feature_vector_value_b(i) = feature_vector(i,ind(i));
%             %                             end
%             %                             
%             %                             feature_vector_b = [feature_vector_b feature_vector_value_b'];
% 
%             %                             preps_b = [preps_b t0(j)-index_substract:t0(j)];
%                                     case 'r'
%                                         preps_r = [preps_r tp(j)+prep_initial_shift:t0(j)];
%                                         t0_r = [t0_r t0(j)];
%             %                             [mx ind] = max(feature_vector(:,preps_r)');
%             %                             
%             %                             clear feature_vector_value_r
%             %                             for i = 1:size(feature_vector,1)
%             %                                 feature_vector_value_r(i) = feature_vector(i,ind(i));
%             %                             end
%             % 
%             %                             feature_vector_r = [feature_vector_r feature_vector_value_r'];
% 
%             %                             preps_r = [preps_r t0(j)-index_substract:t0(j)];
%                                 end
%                             end
% 
%                             imagesc([feature_vector(:,preps_b) feature_vector(:,preps_r)])
%                             hold on
% 
%                             for i = 1:numel(t0_b)
%                                 l = line([t0(i) t0(i)], [0 size(feature_vector,1)]);
%                                 switch tb(i)
%                                     case 'b'
%                                         set(l,'Color','b')
%                                     case 'r'
%                                         set(l,'Color','r')
%                                 end
%                             end

                            imagesc(feature_vector)
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
                            filename = sprintf('%s of subject %d, run %d',feature_name{f},s,r);
                            title(filename,'FontName','Monaco','FontSize',13)
                            colorbar
%                             caxis([-1 1]*20000)
%                             caxis([-30 30])
%                             colormap('hot')
                            saveas(gca,sprintf('%s/%s.png',path.save,filename))

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
































