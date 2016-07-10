path_func = '/Users/george/Data/rtfMRI/rtfMRI001.feat/filtered_func_data.nii.gz';

data = MRIread(path_func);




%%



figure, vol3d('cdata',comp.thresh{:}.vol * 20* max(func.vol(:)) + func.vol(:,:,:,1)); daspect(1./comp.volres); axis vis3d; zoom on; view(135,20);