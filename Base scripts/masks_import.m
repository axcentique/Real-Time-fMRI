% set MATLAB working directory to the folder with the Art_Connect_1
filepath_masks_root = sprintf('Art_Connect_1/Subj_Regions/');

% path where to save the tables with correlation values 
savePath = '~/Desktop/';



subj = [444653; 445002; 554701; 554755; 555153; 664509; 664905; 664912; 665001; 665005; 665209; 665357; 665503; 774552; 774756; 774801; 774868; 774972; 774975; 775002; 775019; 775053; 775068; 775102; 775118; 775206; 775216; 775261; 775321];
regNum = 7;
hopNum = 10;
timeFrameNum = 1;

scan_size = [64 64 38];

% corrPath = sprintf('corr/aging/');
% % region names for filenames
% nameRegion{1} = 'bilateral medial frontal';
% nameRegion{2} = 'bilateral orbital frontal';
% nameRegion{3} = 'bilateral posterior cingulate';
% nameRegion{4} = 'left lateral parietal';
% nameRegion{5} = 'left medial temporal';
% nameRegion{6} = 'right lateral parietal';
% nameRegion{7} = 'right medial temporal';
%%

for s = 1:numel(subj)
        %%
        fprintf('\n\nSubject %1.0f | %1.0f',s,subj(s))
        
%         load(sprintf('%sPairCor_%d.mat',corrPath,subj(s)));
        filepath = sprintf('Art_Connect_1/%6.0f/%6.0f_rest_filt_all.nii.gz',subj(s),subj(s));
        import = MRIread(filepath);
        
        filepath_mask{1} = sprintf('%s%6.0f_B_medfrt.nii.gz',filepath_masks_root,subj(s));
        filepath_mask{2} = sprintf('%s%6.0f_B_orbfrt.nii.gz',filepath_masks_root,subj(s));
        filepath_mask{3} = sprintf('%s%6.0f_B_pocing.nii.gz',filepath_masks_root,subj(s));
        filepath_mask{4} = sprintf('%s%6.0f_L_latpar.nii.gz',filepath_masks_root,subj(s));
        filepath_mask{5} = sprintf('%s%6.0f_L_metemp.nii.gz',filepath_masks_root,subj(s));
        filepath_mask{6} = sprintf('%s%6.0f_R_latpar.nii.gz',filepath_masks_root,subj(s));
        filepath_mask{7} = sprintf('%s%6.0f_R_metemp.nii.gz',filepath_masks_root,subj(s));

        for i = 1:numel(filepath_mask)
            data = MRIread(filepath_mask{i});
            network.region{i} = find(squeeze(data.vol(:,:,:,1)));
        end

    
end
% end