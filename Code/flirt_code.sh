fslreorient2std ~/Data/rtfMRI/20120323_154605WIPMPRAGES2SENSEs301a003.nii.gz ~/Data/rtfMRI/20120323_154605WIPMPRAGES2SENSEs301a003_in_std.nii.gz

bet ~/Data/rtfMRI/20120323_154605WIPMPRAGES2SENSEs301a003_in_std.nii.gz ~/Data/rtfMRI/20120323_brain.nii.gz -R


# T1 to MNI
flirt -in ~/Data/rtfMRI/20120323_brain.nii.gz -ref /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -out ~/Data/rtfMRI/T1_brain_in_mni -omat ~/Data/rtfMRI/T12mni.mat -searchrx -180 180 -searchry -180 180 -searchrz -180 180



# functional to T1 (RUN 1)
flirt -in ~/Data/rtfMRI/run1.feat/mean_func.nii.gz -ref ~/Data/rtfMRI/20120323_brain.nii.gz -out ~/Data/rtfMRI/run1/func_in_T1 -omat ~/Data/rtfMRI/run1/func2T1.mat -searchrx -180 180 -searchry -180 180 -searchrz -180 180

# functional to T1 (RUN 2)
flirt -in ~/Data/rtfMRI/run2.feat/mean_func.nii.gz -ref ~/Data/rtfMRI/20120323_brain.nii.gz -out ~/Data/rtfMRI/run2/func_in_T1 -omat ~/Data/rtfMRI/run2/func2T1.mat -searchrx -180 180 -searchry -180 180 -searchrz -180 180

# functional to T1 (RUN 1+2)
flirt -in ~/Data/rtfMRI/rtfMRI001.feat/mean_func.nii.gz -ref ~/Data/rtfMRI/20120323_brain.nii.gz -out ~/Data/rtfMRI/runs12/func_in_T1 -omat ~/Data/rtfMRI/runs12/func2T1.mat -searchrx -180 180 -searchry -180 180 -searchrz -180 180



# functional to MNI (RUN 1)
flirt -in ~/Data/rtfMRI/run1.feat/mean_func.nii.gz -ref /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -out ~/Data/rtfMRI/run1/func_in_mni -omat ~/Data/rtfMRI/run1/func2mni.mat -searchrx -180 180 -searchry -180 180 -searchrz -180 180

# functional to MNI (RUN 2)
flirt -in ~/Data/rtfMRI/run2.feat/mean_func.nii.gz -ref /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -out ~/Data/rtfMRI/run2/func_in_mni -omat ~/Data/rtfMRI/run2/func2mni.mat -searchrx -180 180 -searchry -180 180 -searchrz -180 180

# functional to MNI (RUN 1+2)
flirt -in ~/Data/rtfMRI/rtfMRI001.feat/mean_func.nii.gz -ref /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -out ~/Data/rtfMRI/runs12/func_in_mni -omat ~/Data/rtfMRI/runs12/func2mni.mat -searchrx -180 180 -searchry -180 180 -searchrz -180 180


# generate MNI -> functional rot. matrix (RUN 1)
cd ~/Data/rtfMRI/run1/
convert_xfm -omat func2mni.mat -concat ../T12mni.mat func2T1.mat
convert_xfm -omat mni2func.mat -inverse func2mni.mat

# generate MNI -> functional rot. matrix (RUN 2)
cd ~/Data/rtfMRI/run2/
convert_xfm -omat func2mni.mat -concat ../T12mni.mat func2T1.mat
convert_xfm -omat mni2func.mat -inverse func2mni.mat

# generate MNI -> functional rot. matrix (RUN 1+2)
cd ~/Data/rtfMRI/runs12/
convert_xfm -omat func2mni.mat -concat ../T12mni.mat func2T1.mat
convert_xfm -omat mni2func.mat -inverse func2mni.mat



# flirt -in subject_2_func_brain_mni.nii.gz -ref /Users/george/Desktop/DMdata/subject2/selfPaced.ica/mean_func.nii.gz -out nmi2funcTEST.nii.gz -init mni2func.mat -applyxfm


cd ~/Data/rtfMRI/run1/
flirt -in ../MNI_PCC_precuneus.nii.gz -ref ~/Data/rtfMRI/run1.feat/mean_func.nii.gz -out ~/Data/rtfMRI/run1/MNI_PCC_precuneus_func.nii.gz -init mni2func.mat -applyxfm

cd ~/Data/rtfMRI/run2/
flirt -in ../MNI_PCC_precuneus.nii.gz -ref ~/Data/rtfMRI/run2.feat/mean_func.nii.gz -out ~/Data/rtfMRI/run2/MNI_PCC_precuneus_func.nii.gz -init mni2func.mat -applyxfm

cd ~/Data/rtfMRI/runs12/
flirt -in ../MNI_PCC_precuneus.nii.gz -ref ~/Data/rtfMRI/rtfMRI001.feat/mean_func.nii.gz -out ~/Data/rtfMRI/runs12/MNI_PCC_precuneus_func.nii.gz -init mni2func.mat -applyxfm




flirt -in /Users/george/Desktop/DMdata/subject2/selfPaced.ica/mean_func.nii.gz -ref /Users/george/Documents/MATLAB/spm8/templates/T1.nii -out func2mniTEST.nii.gz -init func2mni.mat -applyxfm