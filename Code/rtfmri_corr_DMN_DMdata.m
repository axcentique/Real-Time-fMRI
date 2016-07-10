clear
clc


TS_plot_savepath = '~/Desktop/Output/';

%%%%%%%%%%%% Subject 1
contrast_mask.rest = MRIread('~/Desktop/DMdata/subject1/selfPaced_no67.feat/stats/zstat1.nii.gz');
% contrast_mask.rest = MRIread('~/Desktop/DMdata/subject1/selfPaced_no67.feat/stats/zstat3.nii.gz');
func = MRIread('~/Desktop/DMdata/subject1/selfPaced_no67.feat/filtered_func_data.nii.gz');
% 
%%
pathEV = '~/Desktop/DMdata/subject1/selfPaced_no67.feat/custom_timing_files/';
event_file{1} = 'ev1.txt';
% event_file{1} = 'ev3.txt';
%%%%%%%%%%%


%%%%%%%%%%%% Subject 2
% contrast_mask.rest = MRIread('~/Desktop/DMdata/subject2/selfPaced_postStat++.feat/stats/zstat1.nii.gz');
% contrast_mask.rest = MRIread('~/Desktop/DMdata/subject2/selfPaced_postStat++.feat/stats/zstat3.nii.gz');
% func = MRIread('~/Desktop/DMdata/subject2/selfPaced_postStat++.feat/filtered_func_data.nii.gz');
% 
%%
% pathEV = '~/Desktop/DMdata/subject2/selfPaced_postStat++.feat/custom_timing_files/';
% event_file{1} = 'ev1.txt';
% event_file{1} = 'ev3.txt';
%%%%%%%%%%%

% net = 'Right';
% net = 'Left';
net = 'Rest';
% volume = contrast_mask.right.vol;
% volume = contrast_mask.left.vol;
volume = contrast_mask.rest.vol;
writeFlag = 1;
dmnFlag = 1;
dmnSegment = 0;

% masking func data with PCC/precuneus

volumeSize = size(squeeze(func.vol(:,:,:,1)));
mask = MRIread('~/Desktop/DMdata/subject2/labeling/MNI_PCC_precuneus_func.nii.gz');
mask.vol(find(mask.vol))=1;

% figure, vol3d('cdata',func.vol(:,:,:,1)); axis tight; daspect([1,1,1]); view(135,45);
% figure, vol3d('cdata',mask.vol); axis tight; daspect([1,1,1]); view(135,45);

contrastThreshold = 2;
corTresh = .3;
TR = func.tr/10^3;

if dmnFlag == 1
    nifti_savepath = {'~/Desktop/Output/Rest_PCCPr_intersection.nii.gz';...
    '~/Desktop/Output/DMN_correlation_map.nii.gz';...
    '~/Desktop/Output/DMN_front.nii.gz';...
    '~/Desktop/Output/DMN_posterior_lateral.nii.gz';...
    '~/Desktop/Output/DMN_front_right.nii.gz';...
    '~/Desktop/Output/DMN_front_left.nii.gz';...
    '~/Desktop/Output/DMN_posterior_lateral_right.nii.gz';...
    '~/Desktop/Output/DMN_posterior_lateral_left.nii.gz'};
else
%     nifti_savepath = {'~/Desktop/Output/.nii.gz'};
end

%%
contrast_mask.selected = tresholdVolume(volume,contrastThreshold);

if dmnFlag == 1
    for t = 1:size(func.vol,4)
        masked.vol(:,:,:,t) = func.vol(:,:,:,t) .* mask.vol .* contrast_mask.selected ;
    end
else
    for t = 1:size(func.vol,4)
        masked.vol(:,:,:,t) = func.vol(:,:,:,t) .* contrast_mask.selected ;
    end
end

% get mean time-series
TS_mean = getMeanTS(masked.vol);
% plot(core_roi_TS_mean)

% figure, vol3d('cdata',masked.vol(:,:,:,1)); axis tight; daspect([1,1,1]); view(135,45);

%%
if dmnFlag == 1
    if writeFlag ~= 0
        % vol3d('cdata',(contrast_mask.selected + mask.vol./15)*20*max(func.vol(:)) + func.vol(:,:,:,1),'texture','3D'); axis tight; daspect(1./func.volres); view(135,45);
        figure, vol3d_4views((contrast_mask.selected + mask.vol./15)*20*max(func.vol(:)) + func.vol(:,:,:,1),'Intersection of Rest map & PCC/Precuneus',func.volres)
        saveNIFTI(func,masked.vol,net,nifti_savepath{1})
    end
    
    volInd = find(func.vol(:,:,:,1));
    [x y z] = ind2sub(volumeSize,volInd);

    clear brainTS
    parfor j=1:length(volInd)
        brainTS(j,:) = func.vol(x(j),y(j),z(j),:);
        brainCor(j) = corr2(TS_mean,brainTS(j,:));
        j/length(volInd)
    end
    
    brainCorVol = zeros(volumeSize);

    for j=1:length(volInd)
        [x y z] = ind2sub(volumeSize,volInd(j));
        brainCorVol(x,y,z) = brainCor(j);
        j/length(volInd)
    end
    clc
    clear brainTS brainCor
    % treshold and render the thresholded correlation volume

    clear volCor
    voxCorIndex = find(brainCorVol(:)>corTresh);
    volCor = zeros(volumeSize);
    volCor(voxCorIndex) = 1;

    figure, vol3d_4views(volCor*20*max(func.vol(:)) + func.vol(:,:,:,1),'DMN Posterior Lateral',func.volres)
    title(sprintf('Default Mode Network. In red - voxels with correation > 0.3'))
    saveas(gca,[TS_plot_savepath 'Default Mode Network.png']);
    close
        
    % average time series in DMN
    [x y z] = ind2sub(volumeSize,voxCorIndex);

    parfor j=1:length(voxCorIndex)
        dmn_TS(j,:) = func.vol(x(j),y(j),z(j),:);
        j
    end

    dmn_TS_mean = mean(dmn_TS);
%     figure, plot(dmn_TS_mean)
    
    if writeFlag ~= 0
        saveNIFTI(func,brainCorVol,net,nifti_savepath{2})
    end
    
    
    

    if dmnSegment == 1
        voxCorIndex = find(brainCorVol(:)>corTresh);
        volCor = zeros(volumeSize);
        volCor(voxCorIndex) = 1;

        % frontal
        volCorFront = volCor;
        volCorFront(1:45,:,:) = 0;
        
        % posterior lateral
        volCorPosLat = volCor;
        volCorPosLat(64:-1:25,:,:) = 0;
        volCorPosLat(:,25:39,:) = 0;
        volCorPosLat(:,:,1:15) = 0;
        
        % figure, vol3d('cdata',volCor*20*max(func.vol(:)) + func.vol(:,:,:,1)); axis tight; daspect(1./func.volres); view(135,45);

        figure, vol3d_4views(volCorFront*20*max(func.vol(:)) + func.vol(:,:,:,1),'DMN Front',func.volres)
        saveas(gca,[TS_plot_savepath 'DMN Front.png']);
        close
        
        figure, vol3d_4views(volCorPosLat*20*max(func.vol(:)) + func.vol(:,:,:,1),'DMN Posterior Lateral',func.volres)
        saveas(gca,[TS_plot_savepath 'DMN Posterior Lateral.png']);
        close
        
        clear volCor
    
        % average time series front and pos lat DMN
        for t = 1:size(func.vol,4)
            dmn_front(:,:,:,t) = multiMatrixProduct(0,func.vol(:,:,:,t),volCorFront);
        end
        for t = 1:size(func.vol,4)
            dmn_poslat(:,:,:,t) = multiMatrixProduct(0,func.vol(:,:,:,t),volCorPosLat);
        end
        
        TS_mean_front = getMeanTS(dmn_front);
        TS_mean_poslat = getMeanTS(dmn_poslat);


        % right/left/front/poslat combos
        rightHalf = zeros(volumeSize);
        leftHalf = zeros(volumeSize);
        rightHalf(:,round(volumeSize(2)/2)+1:volumeSize(2),:) = 1;
        leftHalf(:,1:round(volumeSize(2)/2),:) = 1;
        for t = 1:size(func.vol,4)
            dmn_front_right(:,:,:,t) = multiMatrixProduct(0,func.vol(:,:,:,t),rightHalf,volCorFront);
        end
        for t = 1:size(func.vol,4)
            dmn_front_left(:,:,:,t) = multiMatrixProduct(0,func.vol(:,:,:,t),leftHalf,volCorFront);
        end
        for t = 1:size(func.vol,4)
            dmn_poslat_right(:,:,:,t) = multiMatrixProduct(0,func.vol(:,:,:,t),rightHalf,volCorPosLat);
        end
        for t = 1:size(func.vol,4)
            dmn_poslat_left(:,:,:,t) = multiMatrixProduct(0,func.vol(:,:,:,t),leftHalf,volCorPosLat);
        end
        %%
%         figure, vol3d('cdata',dmn_front_right(:,:,:,t)); axis tight; daspect(1./func.volres); view(135,45);
%         figure, vol3d('cdata',dmn_front_left(:,:,:,t)); axis tight; daspect(1./func.volres); view(135,45);
%         figure, vol3d('cdata',dmn_poslat_right(:,:,:,t)); axis tight; daspect(1./func.volres); view(135,45);
%         figure, vol3d('cdata',dmn_poslat_left(:,:,:,t)); axis tight; daspect(1./func.volres); view(135,45);

        TS_mean_front_right = getMeanTS(dmn_front_right);
        TS_mean_front_left = getMeanTS(dmn_front_left);
        TS_mean_poslat_right = getMeanTS(dmn_poslat_right);
        TS_mean_poslat_left = getMeanTS(dmn_poslat_left);
        

        if writeFlag ~= 0
            saveNIFTI(func,dmn_front,net,nifti_savepath{3})
            saveNIFTI(func,dmn_poslat,net,nifti_savepath{4})
            saveNIFTI(func,dmn_front_right,net,nifti_savepath{5})
            saveNIFTI(func,dmn_front_left,net,nifti_savepath{6})
            saveNIFTI(func,dmn_poslat_right,net,nifti_savepath{7})
            saveNIFTI(func,dmn_poslat_left,net,nifti_savepath{8})
        end
        
        textTitle = 'DMN Front Right';
        figure, vol3d_4views(dmn_front_right(:,:,:,1),textTitle,func.volres)
        saveas(gca,[TS_plot_savepath textTitle '.png']);
        close
        
        textTitle = 'DMN Front Left';
        figure, vol3d_4views(dmn_front_left(:,:,:,1),textTitle,func.volres)
        saveas(gca,[TS_plot_savepath textTitle '.png']);
        close
        
        textTitle = 'DMN Posterior Lateral Right';
        figure, vol3d_4views(dmn_poslat_right(:,:,:,1),textTitle,func.volres)
        saveas(gca,[TS_plot_savepath textTitle '.png']);
        close
        
        textTitle = 'DMN Posterior Lateral Right';
        figure, vol3d_4views(dmn_poslat_left(:,:,:,1),textTitle,func.volres)
        saveas(gca,[TS_plot_savepath textTitle '.png']);
        close
        
    end
else
    %%
    rightHalf = zeros(volumeSize);
    leftHalf = zeros(volumeSize);
    rightHalf(:,round(volumeSize(2)/2)+1:volumeSize(2),:) = 1;
    leftHalf(:,1:round(volumeSize(2)/2),:) = 1;
    for t = 1:size(func.vol,4)
        motor_right(:,:,:,t) = multiMatrixProduct(0,masked.vol(:,:,:,t),rightHalf);
    end
    for t = 1:size(func.vol,4)
        motor_left(:,:,:,t) = multiMatrixProduct(0,masked.vol(:,:,:,t),leftHalf);
    end
    %
%     figure, vol3d('cdata',motor_right(:,:,:,t)); axis tight; daspect(1./func.volres); view(135,45);
    textTitle = sprintf('%s Motor Right Brain',net);
    figure, vol3d_4views(motor_right(:,:,:,1),textTitle,func.volres)
    saveas(gca,[TS_plot_savepath textTitle '.png']);
    close
    
    textTitle = sprintf('%s Motor Left Brain',net);
    figure, vol3d_4views(motor_left(:,:,:,1),textTitle,func.volres)
%     figure, vol3d('cdata',motor_left(:,:,:,t)); axis tight; daspect(1./func.volres); view(135,45);
    saveas(gca,[TS_plot_savepath textTitle '.png']);
    close
    
    TS_mean_right = getMeanTS(motor_right);
    TS_mean_left = getMeanTS(motor_left);
end


%% average raw signal

clc

ev.rest = load([pathEV event_file{1}]);
ev.rest = ev.rest'.*[1:length(ev.rest)]*TR;
ev.rest = ev.rest(find(ev.rest));
[starts ends] = getSessionIndeces(ev.rest');
ev.rest = [ev.rest(starts); ends-starts]';

TS_color = {'black','blue','red'};
if dmnFlag == 1
    textTitle = sprintf('Mean voxel time-series of DMN (cor >.3)');
    rtfmri_plot_TS_EV(dmn_TS_mean,ev,textTitle,{'black'},TR)
    saveas(gca,[TS_plot_savepath textTitle '.png']);
    close

%     textTitle = sprintf('Mean voxel time-series of frontal DMN regions (cor >.3)');
%     rtfmri_plot_TS_EV(TS_mean_front,ev,textTitle,{'black'},TR)
%     saveas(gca,[TS_plot_savepath textTitle '.png']);
%     close
%     
%     textTitle = sprintf('Mean voxel time-series of RIGHT brain frontal DMN regions (cor >.3)');
%     rtfmri_plot_TS_EV(TS_mean_front_right,ev,textTitle,{'black'},TR)
%     saveas(gca,[TS_plot_savepath textTitle '.png']);
%     close
%     
%     textTitle = sprintf('Mean voxel time-series of LEFT brain frontal DMN regions (cor >.3)');
%     rtfmri_plot_TS_EV(TS_mean_front_left,ev,textTitle,{'black'},TR)
%     saveas(gca,[TS_plot_savepath textTitle '.png']);
%     close

%     textTitle = sprintf('Mean voxel time-series of posterior lateral DMN regions (cor >.3)');
%     rtfmri_plot_TS_EV(TS_mean_poslat,ev,textTitle,{'black'},TR)
%     saveas(gca,[TS_plot_savepath textTitle '.png']);
%     close
%     
%     textTitle = sprintf('Mean voxel time-series of RIGHT brain post. lat. DMN regions');
%     rtfmri_plot_TS_EV(TS_mean_poslat_right,ev,textTitle,{'black'},TR)
%     saveas(gca,[TS_plot_savepath textTitle '.png']);
%     close
%     
%     textTitle = sprintf('Mean voxel time-series of LEFT brain post. lat. DMN regions');
%     rtfmri_plot_TS_EV(TS_mean_poslat_left,ev,textTitle,{'black'},TR)
%     saveas(gca,[TS_plot_savepath textTitle '.png']);
%     close

else    
%     textTitle = sprintf('Mean voxel time-series of %s v. Rest (Self-Initiated Presses)', net);
%     rtfmri_plot_TS_EV(TS_mean,ev,textTitle,{'black'},TR)
%     saveas(gca,[TS_plot_savepath textTitle '.png']);
%     close
    
%     textTitle = sprintf('Mean voxel time-series of %s v. Rest activation map in RIGHT brain', net);
%     rtfmri_plot_TS_EV(TS_mean_right,ev,textTitle,{'black'},TR)
%     saveas(gca,[TS_plot_savepath textTitle '.png']);
%     close
%     
%     textTitle = sprintf('Mean voxel time-series of %s v. Rest activation map in LEFT brain', net);
%     rtfmri_plot_TS_EV(TS_mean_left,ev,textTitle,{'black'},TR)
%     saveas(gca,[TS_plot_savepath textTitle '.png']);
%     close
end







