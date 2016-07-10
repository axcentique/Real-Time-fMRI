#!/bin/csh
# This is made from csfwm_filter.csh.
# this script requires files from csf_filer.csh
# the associated files Feat_Custom1.txt,  csf_filter_design.fsf csf_filter_Delta.fsf need to  be located in the same directory as this script.
# the FEAT setup is based on 225 volumes
# this script requires a brain extracted high resolution T1 image

if ($#argv < 3) then
echo "Usage: sbjid run study"
exit 1
endif


set SBJID = $1
set RUN = $2
set STUDY = $3

cd /Volumes/Annex1/${STUDY}/${SBJID}/

#run FAST on T1 anatomical image to obtain CSF mask. 3 tissue type masks will be created.
fast -t 1 -g --nopve -o ${SBJID}_mask ${SBJID}_brain

#motion correct fMRI data
mcflirt -plots ${SBJID}_${RUN}_mc.par -in ${SBJID}_${RUN}.nii.gz  -out ${SBJID}_${RUN}_mc

#register anatomical to motion corrected fMRI data  
flirt -in ${SBJID}_brain.nii.gz -ref ${SBJID}_${RUN}_mc.nii.gz -out  ${SBJID}_ANAT2${RUN} -omat ${SBJID}_ANAT2${RUN}.mat -dof 12 

#apply registration matrix to CSF segmentation mask
flirt -in ${SBJID}_mask_seg_0.nii.gz -ref ${SBJID}_${RUN}_mc.nii.gz -out ${SBJID}_ANAT2${RUN}_csf -init ${SBJID}_ANAT2${RUN}.mat -applyxfm

#apply registration matrix to WM segmentation mask
flirt -in ${SBJID}_mask_seg_2.nii.gz -ref ${SBJID}_${RUN}_mc.nii.gz -out ${SBJID}_ANAT2${RUN}_wm -init ${SBJID}_ANAT2${RUN}.mat -applyxfm

#threshold WM segmentation mask from  .95-1
fslmaths  ${SBJID}_ANAT2${RUN}_wm.nii.gz -thr .95 -uthr 1 -bin ${SBJID}_ANAT2${RUN}_wm_mask

#threshold CSF segmentation mask from  .85-1
fslmaths  ${SBJID}_ANAT2${RUN}_csf.nii.gz -thr .85 -uthr 1 -bin ${SBJID}_ANAT2${RUN}_csf_mask

#view segmentation & registration
#fslview ${SBJID}_${RUN}_mc.nii.gz ${SBJID}_ANAT2${RUN}.nii.gz ${SBJID}_ANAT2${RUN}_wm_mask.nii.gz -l Green -t .5  &

#extract CSF timeseries
fslmeants -i ${SBJID}_${RUN}_mc.nii.gz -o ${SBJID}_${RUN}_csf_ts.txt -m ${SBJID}_ANAT2${RUN}_csf_mask

#extract WM timeseries
fslmeants -i ${SBJID}_${RUN}_mc.nii.gz -o ${SBJID}_${RUN}_wm_ts.txt -m ${SBJID}_ANAT2${RUN}_wm_mask

#binerize brain mask
fslmaths ${SBJID}_ANAT2${RUN} -bin ${SBJID}_ANAT2${RUN}_mask

#extract mean signal intesity
fslmeants -i ${SBJID}_${RUN}_mc.nii.gz -o ${SBJID}_${RUN}_mean_ts.txt -m ${SBJID}_ANAT2${RUN}_mask

#create motion EVs for matrix
awk '{print $1}' ${SBJID}_${RUN}_mc.par > ${SBJID}_${RUN}_mc_x.txt
awk '{print $2}' ${SBJID}_${RUN}_mc.par > ${SBJID}_${RUN}_mc_y.txt
awk '{print $3}' ${SBJID}_${RUN}_mc.par > ${SBJID}_${RUN}_mc_z.txt
awk '{print $4}' ${SBJID}_${RUN}_mc.par > ${SBJID}_${RUN}_mc_roll.txt
awk '{print $5}' ${SBJID}_${RUN}_mc.par > ${SBJID}_${RUN}_mc_pitch.txt
awk '{print $6}' ${SBJID}_${RUN}_mc.par > ${SBJID}_${RUN}_mc_yaw.txt


# Create CSF/WM/motion regressors
cd /Volumes/Annex1/${STUDY}/
sh FEAT_all.txt $SBJID $RUN $STUDY
cd /Volumes/Annex1/${STUDY}/${SBJID}/
mv ${SBJID}_${RUN}_mc.feat/design.mat ${SBJID}_${RUN}_all.mat
rm -rf ${SBJID}_${RUN}_mc.feat

# Create CSF/WM/motion/meants regressors
#cd /Volumes/Annex1/${STUDY}/
#sh FEAT_allmeants.txt $SBJID $RUN $STUDY
#cd /Volumes/Annex1/${STUDY}/${SBJID}/
#mv ${SBJID}_${RUN}_mc.feat/design.mat ${SBJID}_${RUN}_allmeants.mat
#rm -rf ${SBJID}_${RUN}_mc.feat

#Filter above regressors from the motion corrected func data
fsl_regfilt -i  ${SBJID}_${RUN}_mc.nii.gz -d ${SBJID}_${RUN}_all.mat -f "1,2,3,4,5,6,7,8" -o ${SBJID}_${RUN}_filt_all
#fsl_regfilt -i  ${SBJID}_${RUN}_mc.nii.gz -d ${SBJID}_${RUN}_allmeants.mat -f "1,2,3,4,5,6,7,8,9" -o ${SBJID}_${RUN}_filt_allmeants

# band pass filter is set to contain frequencies 0.01 < fz < 0.1 (T2=2 here - recall HWFM sigma)
#fslmaths ${SBJID}_${RUN}_filt_all -bptf 25 2.5 ${SBJID}_${RUN}_filt_all_bp
#fslmaths ${SBJID}_${RUN}_filt_allmeants -bptf 25 2.5 ${SBJID}_${RUN}_filt_allmeants_bp



