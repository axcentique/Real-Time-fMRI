% function mni2func
dataDir = '/Users/george/Desktop/DMdata/subject2/'; % name of directory where files are
%% extract T1 brain with BET
fsl(dataDir,'bet','T1',dataDir,'T1','-m');
%% reg T1 to MNI
fsl(dataDir,'flirt','-in','T1','-ref','/usr/share/data/fsl-mni152-templates/MNI152_T1_1mm_brain.nii.gz','-out','T1_brain_mni','-omat','T12mni.mat','-searchrx -180 180 -searchry -180 180 -searchrz -180 180');
%% reg mean_func to T1
fsl(dataDir,'flirt','-in','mean_func','-ref','T1','-out','mean_func_reg','-omat','func2T1.mat','-searchrx -180 180 -searchry -180 180 -searchrz -180 180');
%% concat for FUNC to MNI
% convert_xfm -omat <outmat_AtoC> -concat <mat_BtoC> <mat_AtoB>
fsl(dataDir,'convert_xfm','-omat','func2mni.mat','-concat','T12mni.mat','func2T1.mat');
%% invert xfm func2mni to mni2func
fsl(dataDir,'convert_xfm','-omat','mni2func.mat','-inverse','func2mni.mat');
