function saveNIFTI(template,vol,filename,savepath)

template.vol = vol;

if length(savepath)<3
    [filename path] = uiputfile('.nii',filename);
    % path = sprintf('~/Desktop/Output/%s.nii.gz',net);
    MRIwrite(template,[path filename '.gz'],'double');
else
    MRIwrite(template,[savepath filename],'double');
end