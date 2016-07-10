SUBJECTS=$(shell cat subjects.txt)

funcRun1InputFiles=$(wildcard ???/Run1.nii.gz)
funcRun2InputFiles=$(wildcard ???/Run2.nii.gz)
funcRun3InputFiles=$(wildcard ???/Run3.nii.gz)
funcRun4InputFiles=$(wildcard ???/Run4.nii.gz)
funcRun5InputFiles=$(wildcard ???/Run5.nii.gz)
funcRunInputFiles = $(funcRun1InputFiles) $(funcRun2InputFiles) $(funcRun3InputFiles) $(funcRun4InputFiles) $(funcRun5InputFiles)
funcRunMCFiles=$(funcRun1InputFiles:%/Run1.nii.gz=%/run1_mc.nii.gz) $(funcRun2InputFiles:%/Run2.nii.gz=%/run2_mc.nii.gz) $(funcRun3InputFiles:%/Run3.nii.gz=%/run3_mc.nii.gz) $(funcRun4InputFiles:%/Run4.nii.gz=%/run4_mc.nii.gz) $(funcRun5InputFiles:%/Run5.nii.gz=%/run5_mc.nii.gz)
funcRunFiles_final= $(funcRunMCFiles)

funcRestFiles=$(wildcard ???/RestingState.nii.gz)
funcRestFiles_final=$(funcRestFiles:%/RestingState.nii.gz=%/rest_mc.nii.gz) $(funcRestFiles:%/RestingState.nii.gz=%/rest_mc.par)

T1files=$(wildcard ???/MPRAGE.nii.gz)
T1files_seg=$(T1files:%/MPRAGE.nii.gz=%/T1_seg.nii.gz)
T1files_brain=$(T1files:%/MPRAGE.nii.gz=%/T1_brain.nii.gz)

all: $(T1files_seg) $(T1files_brain) $(funcRestFiles_final) $(funcRunFiles_final)

$(funcRunFiles_final): $(funcRunInputFiles)
	mcflirt -in $< -out $@ -plots

%/rest_mc.nii.gz %/rest_mc.par: %/RestingState.nii.gz
	mcflirt -in $< -out $*/rest_mc.nii.gz -plots; \
	mv $*/rest_mc.nii.gz.par $*/rest_mc.par

%/T1_seg.nii.gz: %/T1_brain.nii.gz
	fast -t 1 -g --nopve -o $@ $<; \
	mv $*/T1_seg_seg.nii.gz $*/T1_seg.nii.gz; \
	mv $*/T1_seg_seg_0.nii.gz $*/T1_seg_0.nii.gz; \
	mv $*/T1_seg_seg_1.nii.gz $*/T1_seg_1.nii.gz; \
	mv $*/T1_seg_seg_2.nii.gz $*/T1_seg_2.nii.gz

%/T1_brain.nii.gz: %/MPRAGE.nii.gz
	fslreorient2std $*/MPRAGE.nii.gz $*/MPRAGE_std.nii.gz; \
	bet $*/MPRAGE_std.nii.gz $@ -R
	
