% load 2 nifti's to append them subsequently 
run1 = MRIread('/Users/george/Data/rtfMRI/20120323_154605WIPRun1SENSEs601a006.nii.gz');
run2 = MRIread('/Users/george/Data/rtfMRI/20120323_154605WIPRun2SENSEs701a007.nii.gz');

vol = run1.vol;

parfor d = 1:195
        vol(:,:,:,195+d) = run2.vol(:,:,:,d);
end

run.nframes = size(vol,4);

MRIwrite(run,'20120323_combined_run.nii.gz');