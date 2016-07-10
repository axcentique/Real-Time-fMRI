DaraDir='/Users/george/Data/rtfMRI/August/subjects/';
WorkDir='intermediary/';
RestDir='preprocessed/';
savePath = '/Users/george/Data/rtfMRI/August/temp/dmn_seed_masks';
cd(DaraDir)
%%

s=1;r=1;
path.func_hipass = sprintf('/Users/george/Data/rtfMRI/August/subjects/filtered/subject%d_run%d_hi_pass_5.nii.gz',s,r);
func_hipass = MRIread(path.func_hipass);
scanSize = size(func_hipass.vol);

for s = 1:10
    for r = 1:2
        func_name = sprintf('rest%d',r);
        dmn_seeds = sprintf('transformations/subject%d_rest%d_dmn_seeds.txt',s,r);

        if exist([DaraDir dmn_seeds],'file') == 0
            continue
        else
            for c = 1:7
                clc
                fprintf('-------Subject %d, Rest %d',s,r)
                DMN = dlmread([DaraDir dmn_seeds]);

                vox = swapXY(round(DMN(c,:)));
                %%
                degree = 1;
                x = vox(1);
                y = vox(2);
                z = vox(3);

                vxlRange = [];
                for xInd = -degree:degree
                    for yInd = -degree:degree
                        for zInd = -degree:degree
                            if round(pdist([x y z ; x+xInd y+yInd z+zInd]))==degree
                                vxlRange = [vxlRange; sub2ind(scanSize,x+xInd,y+yInd,z+zInd)];
                            end
                        end
                    end
                end

                sphereMask = zeros(scanSize(1:3));
                sphereMask(vxlRange) = 1;
                
                %%
                out.vol = sphereMask;
                
                filename = sprintf('%s/subj%d_rest%d_seed%d.nii.gz',savePath,s,r,c);
                MRIwrite(out,filename);

            end 
        end
    end
end