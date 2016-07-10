% 
rtfMRI_import_responses_floor_plus1
clc

DaraDir='/Users/george/Data/rtfMRI/August/subjects/';
% WorkDir='intermediary/';
FuncDir='preprocessed/';
savePath = sprintf('%sresponses/',DaraDir);
time_delay = 0;

%%
for s = 1:10
    fprintf('-------Subject %d, Run:',s)
    for r = 1:5
        %%
        func_name = sprintf('%s%ssubject%d_run%d_filt_all_bp.nii.gz',DaraDir,FuncDir,s,r);
        if exist(func_name,'file') == 0
            continue
        else
            fprintf('%d,',r)
%             func = MRIread(func_name); 
            func.nframes = 195;
            events = zeros([func.nframes 1]);
            events(response(s,r).rest_response+time_delay) = 1;

%             event_path = sprintf('%ssubject%d_run%d_delay%d.txt',savePath,s,r,time_delay);
            event_path = sprintf('%ssubject%d_run%d.txt',savePath,s,r);
            dlmwrite(event_path,events);
        end
    end
    fprintf('\n')
end
fprintf('\n-------Done!')
