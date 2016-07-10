function fsfgen(varargin)
% Use header info to generate a fsf file.
if numel(varargin) == 0
    filterspec = {'nii','nii.gz'};
    [filename filepath]= uigetfile(filterspec);
    if filename == 0
        error('No file selected')
    end
    path = [filepath filename];
else
    path = varargin{:};
end

data = MRIread(path);