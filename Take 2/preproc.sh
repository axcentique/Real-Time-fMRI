#!/bin/sh


DataDir="~/Data/rtfMRI/August"
T1="20120323_brain"
Rest="20120323_154605WIPRestingStateSENSEs401a004.nii.gz"
OutDir="~/Data/rtfMRI/August/FilteredData"

#fslreorient2std
#bet  -R
#bet func_std func_std_brain -R -m

#run FAST on T1 anatomical image to obtain CSF mask. 3 tissue type masks will be created.
fast -t 1 -g --nopve -o ${OutDir}/ ${DataDir}/${T1}

#motion correct fMRI data
mcflirt -plots ${OutDir}/run1_mc.par -in ${DataDir}/${Run1}  -out ${OutDir}/run1_mc
mcflirt -plots ${OutDir}/run2_mc.par -in ${DataDir}/${Run2}  -out ${OutDir}/run2_mc
mcflirt -plots ${OutDir}/rest_mc.par -in ${DataDir}/${Rest}  -out ${OutDir}/rest_mc


#register anatomical to motion corrected fMRI data  
flirt -in ${DataDir}/${T1} -ref ${OutDir}/run1_mc -out ${OutDir}/run1_ANAT2 -omat ${OutDir}/run1_ANAT2.mat -dof 12 
flirt -in ${DataDir}/${T1} -ref ${OutDir}/run2_mc -out ${OutDir}/run2_ANAT2 -omat ${OutDir}/run2_ANAT2.mat -dof 12
flirt -in ${DataDir}/${T1} -ref ${OutDir}/rest_mc -out ${OutDir}/rest_ANAT2 -omat ${OutDir}/rest_ANAT2.mat -dof 12


#apply registration matrix to CSF segmentation mask
flirt -in ${OutDir}/${T1}_seg_0.nii.gz -ref ${OutDir}/run1_mc -out ${OutDir}/run1_ANAT2_csf -init ${OutDir}/run1_ANAT2.mat -applyxfm
flirt -in ${OutDir}/${T1}_seg_0.nii.gz -ref ${OutDir}/run2_mc -out ${OutDir}/run2_ANAT2_csf -init ${OutDir}/run2_ANAT2.mat -applyxfm
flirt -in ${OutDir}/${T1}_seg_0.nii.gz -ref ${OutDir}/rest_mc -out ${OutDir}/rest_ANAT2_csf -init ${OutDir}/rest_ANAT2.mat -applyxfm


#apply registration matrix to WM segmentation mask
flirt -in ${OutDir}/${T1}_seg_2.nii.gz -ref ${OutDir}/run1_mc -out ${OutDir}/run1_ANAT2_wm -init ${OutDir}/run1_ANAT2.mat -applyxfm
flirt -in ${OutDir}/${T1}_seg_2.nii.gz -ref ${OutDir}/run2_mc -out ${OutDir}/run2_ANAT2_wm -init ${OutDir}/run2_ANAT2.mat -applyxfm
flirt -in ${OutDir}/${T1}_seg_2.nii.gz -ref ${OutDir}/rest_mc -out ${OutDir}/rest_ANAT2_wm -init ${OutDir}/rest_ANAT2.mat -applyxfm

##
#apply registration matrix to GM segmentation mask
flirt -in ${OutDir}/${T1}_seg_1.nii.gz -ref ${OutDir}/run1_mc -out ${OutDir}/run1_ANAT2_gm -init ${OutDir}/run1_ANAT2.mat -applyxfm
flirt -in ${OutDir}/${T1}_seg_1.nii.gz -ref ${OutDir}/run2_mc -out ${OutDir}/run2_ANAT2_gm -init ${OutDir}/run2_ANAT2.mat -applyxfm
flirt -in ${OutDir}/${T1}_seg_1.nii.gz -ref ${OutDir}/rest_mc -out ${OutDir}/rest_gm -init ${OutDir}/rest_ANAT2.mat -applyxfm
#threshold GM segmentation mask from  .95-1
fslmaths  ${OutDir}/run1_ANAT2_gm -thr .50 -uthr 1 -bin ${OutDir}/run1_gm_mask
fslmaths  ${OutDir}/run2_ANAT2_gm -thr .50 -uthr 1 -bin ${OutDir}/run2_gm_mask
fslmaths  ${OutDir}/rest_gm -thr .50 -uthr 1 -bin ${OutDir}/rest_gm_mask
##


#threshold WM segmentation mask from  .95-1
fslmaths  ${OutDir}/run1_ANAT2_wm -thr .95 -uthr 1 -bin ${OutDir}/run1_ANAT2_wm_mask
fslmaths  ${OutDir}/run2_ANAT2_wm -thr .95 -uthr 1 -bin ${OutDir}/run2_ANAT2_wm_mask
fslmaths  ${OutDir}/rest_ANAT2_wm -thr .95 -uthr 1 -bin ${OutDir}/rest_ANAT2_wm_mask


#threshold CSF segmentation mask from  .85-1
fslmaths  ${OutDir}/run1_ANAT2_csf -thr .85 -uthr 1 -bin ${OutDir}/run1_ANAT2_csf_mask
fslmaths  ${OutDir}/run2_ANAT2_csf -thr .85 -uthr 1 -bin ${OutDir}/run2_ANAT2_csf_mask
fslmaths  ${OutDir}/rest_ANAT2_csf -thr .85 -uthr 1 -bin ${OutDir}/rest_ANAT2_csf_mask

#view segmentation & registration
fslview ${OutDir}/run1_mc ${OutDir}/run1_ANAT2 ${OutDir}/run1_ANAT2_wm_mask -l Green -t .5  &
fslview ${OutDir}/run2_mc ${OutDir}/run2_ANAT2 ${OutDir}/run2_ANAT2_wm_mask -l Green -t .5  &
fslview ${OutDir}/rest_mc ${OutDir}/rest_ANAT2 ${OutDir}/rest_ANAT2_wm_mask -l Green -t .5  &


#extract CSF timeseries
fslmeants -i ${OutDir}/run1_mc -o ${OutDir}/run1_ANAT2_csf_ts.txt -m ${OutDir}/run1_ANAT2_csf_mask
fslmeants -i ${OutDir}/run2_mc -o ${OutDir}/run2_ANAT2_csf_ts.txt -m ${OutDir}/run2_ANAT2_csf_mask
fslmeants -i ${OutDir}/rest_mc -o ${OutDir}/rest_ANAT2_csf_ts.txt -m ${OutDir}/rest_ANAT2_csf_mask

#extract WM timeseries
fslmeants -i ${OutDir}/run1_mc -o ${OutDir}/run1_ANAT2_wm_ts.txt -m ${OutDir}/run1_ANAT2_wm_mask
fslmeants -i ${OutDir}/run2_mc -o ${OutDir}/run2_ANAT2_wm_ts.txt -m ${OutDir}/run2_ANAT2_wm_mask
fslmeants -i ${OutDir}/rest_mc -o ${OutDir}/rest_ANAT2_wm_ts.txt -m ${OutDir}/rest_ANAT2_wm_mask

#binerize brain mask
fslmaths ${OutDir}/run1_ANAT2 -bin ${OutDir}/run1_ANAT2_mask
fslmaths ${OutDir}/run2_ANAT2 -bin ${OutDir}/run2_ANAT2_mask
fslmaths ${OutDir}/rest_ANAT2 -bin ${OutDir}/rest_ANAT2_mask

#extract mean signal intesity
fslmeants -i ${OutDir}/run1_mc.nii.gz -o ${OutDir}/run1_mean_ts.txt -m ${OutDir}/run1_ANAT2_mask
fslmeants -i ${OutDir}/run2_mc.nii.gz -o ${OutDir}/run2_mean_ts.txt -m ${OutDir}/run2_ANAT2_mask
fslmeants -i ${OutDir}/rest_mc.nii.gz -o ${OutDir}/rest_mean_ts.txt -m ${OutDir}/rest_ANAT2_mask


#create motion EVs for matrix
awk '{print $1}' ${OutDir}/run1_mc.par > ${OutDir}/run1_mc_x.txt
awk '{print $2}' ${OutDir}/run1_mc.par > ${OutDir}/run1_mc_y.txt
awk '{print $3}' ${OutDir}/run1_mc.par > ${OutDir}/run1_mc_z.txt
awk '{print $4}' ${OutDir}/run1_mc.par > ${OutDir}/run1_mc_roll.txt
awk '{print $5}' ${OutDir}/run1_mc.par > ${OutDir}/run1_mc_pitch.txt
awk '{print $6}' ${OutDir}/run1_mc.par > ${OutDir}/run1_mc_yaw.txt

awk '{print $1}' ${OutDir}/run2_mc.par > ${OutDir}/run2_mc_x.txt
awk '{print $2}' ${OutDir}/run2_mc.par > ${OutDir}/run2_mc_y.txt
awk '{print $3}' ${OutDir}/run2_mc.par > ${OutDir}/run2_mc_z.txt
awk '{print $4}' ${OutDir}/run2_mc.par > ${OutDir}/run2_mc_roll.txt
awk '{print $5}' ${OutDir}/run2_mc.par > ${OutDir}/run2_mc_pitch.txt
awk '{print $6}' ${OutDir}/run2_mc.par > ${OutDir}/run2_mc_yaw.txt

awk '{print $1}' ${OutDir}/rest_mc.par > ${OutDir}/rest_mc_x.txt
awk '{print $2}' ${OutDir}/rest_mc.par > ${OutDir}/rest_mc_y.txt
awk '{print $3}' ${OutDir}/rest_mc.par > ${OutDir}/rest_mc_z.txt
awk '{print $4}' ${OutDir}/rest_mc.par > ${OutDir}/rest_mc_roll.txt
awk '{print $5}' ${OutDir}/rest_mc.par > ${OutDir}/rest_mc_pitch.txt
awk '{print $6}' ${OutDir}/rest_mc.par > ${OutDir}/rest_mc_yaw.txt

# Do FEAT with the above variables with the supplied FSL template

# Create CSF/WM/motion regressors
cd /Users/george/Desktop/Out/Run1.feat/
mv design.mat ../Run1_all.mat

cd /Users/george/Desktop/Out/Run2.feat/
mv design.mat ../Run2_all.mat

cd /Users/george/Desktop/Out/Rest.feat/
mv design.mat ../Rest_all.mat


#Filter above regressors from the motion corrected func data
cd ${OutDir}
fsl_regfilt -i  run1_mc -d Run1_all.mat -f "1,2,3,4,5,6,7,8" -o run1_filt_all
fsl_regfilt -i  run2_mc -d Run2_all.mat -f "1,2,3,4,5,6,7,8" -o run2_filt_all
fsl_regfilt -i  rest_mc -d Rest_all.mat -f "1,2,3,4,5,6,7,8" -o rest_filt_all


# band pass filter is set to contain frequencies 0.01 < fz < 0.1 (T2=2 here - recall HWFM sigma)
fslmaths run1_filt_all -bptf 25 2.5 run1_filt_all_bp
fslmaths run2_filt_all -bptf 25 2.5 run2_filt_all_bp
fslmaths rest_filt_all -bptf 25 2.5 rest_filt_all_bp

