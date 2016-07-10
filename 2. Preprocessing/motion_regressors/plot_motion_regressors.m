clc
clear

cd('~/Desktop/motion_regressors/')

r_type_string = {'rest';'run'};

for s = 1:10
    for r_type = 1:2
        for r = 1:5
            filename = sprintf('subject%d_%s%d.txt',s,r_type_string{r_type},r);
            if exist(filename,'file') == 0
                continue
            else
                data = dlmread(filename);
                plot_limit_xyz_matrix(s,r_type,r,1) = max(max(abs(data(:,1:3))));
                plot_limit_rpy_matrix(s,r_type,r,1) = max(max(abs(data(:,4:6))));
                motion_components{s,r_type,r} = data;
            end
        end
    end
end

clear data filename
%%
clc

% plot_limit_xyz = max(plot_limit_xyz_matrix(:));
% plot_limit_rpy = max(plot_limit_rpy_matrix(:));

plot_limit_xyz_exception = zeros(size(plot_limit_xyz_matrix));
plot_limit_xyz_exception(find(plot_limit_xyz_matrix>2)) = 1;
plot_limit_xyz_final = max(plot_limit_xyz_matrix(find(plot_limit_xyz_exception==0)));

plot_limit_rpy_exception = zeros(size(plot_limit_rpy_matrix));
plot_limit_rpy_exception(find(plot_limit_rpy_matrix>5)) = 1;
plot_limit_rpy_final = max(plot_limit_rpy_matrix(find(plot_limit_rpy_exception==0)));

r_name_string = {'rest';'task'};

for s = 1:10
%     subj_max_motion = plot_limit(s,:,:);
    for r_type = 1:2
        for r = 1:5
            close all
            data = motion_components{s,r_type,r};
            if isempty(data) ~= 1
                subplot(2,1,1)
                plot(0:2:(size(data,1)-1)*2,data(:,1:3),'linewidth',2)
    %             ylim([-max(subj_max_motion(:)) max(subj_max_motion(:))]);
                ylim([-plot_limit_xyz_final plot_limit_xyz_final])
                xlim([0 size(data,1)*2])
                ylabel('Distance, mm')
                xlabel('Time, s')

                plotname = sprintf('Motion regressors (x,y,z)\nSubject %d, %s session #%d',s,r_name_string{r_type},r);
                if plot_limit_xyz_exception(s,r_type,r) == 1
                    plotname = [plotname sprintf('. Maximum value outside plot limits: %f',plot_limit_xyz_matrix(s,r_type,r))];
                end
                title(plotname)
                legend({'x','y','z'})
%                 saveas(gca,[plotname '.png'])

%                 close all
                subplot(2,1,2)
                data = motion_components{s,r_type,r};

                plot(0:2:(size(data,1)-1)*2,data(:,4:6),'linewidth',2)
    %             ylim([-max(subj_max_motion(:)) max(subj_max_motion(:))]);
                ylim([-plot_limit_rpy_final plot_limit_rpy_final])
                xlim([0 size(data,1)*2])
                ylabel('Rotation, degrees')
                xlabel('Time, s')

                plotname = sprintf('Motion regressors (roll, pitch, yaw)\nSubject %d, %s session #%d',s,r_name_string{r_type},r);
                if plot_limit_rpy_exception(s,r_type,r) == 1
                    plotname = [plotname sprintf('. Maximum value outside plot limits: %f',plot_limit_rpy_matrix(s,r_type,r))];
                end
                legend({'roll','pitch','yaw'})
                title(plotname)
                
                filename = sprintf('motion regressors, subject#%d, %s#%d',s,r_name_string{r_type},r);
                saveas(gca,[filename '.png'])
            else
                continue
            end
        end
    end
end
close all























