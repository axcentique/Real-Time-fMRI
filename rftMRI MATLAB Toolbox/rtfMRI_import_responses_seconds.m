clear
clc

fprintf('Importing responses...\n')

path.data = '~/Data/rtfMRI/August/subjects/responses/';
num.subjects = 10;
num.runs = 5;

verify.lastonset = zeros([num.subjects num.runs]);

for subject = 1:num.subjects
    for run = 1:num.runs
        path.name = sprintf('%d-%d.xls',subject,run);
        path.full = [path.data path.name];
        if exist(path.full,'file') == 0
            continue
        else
            [numbers header data] = xlsread(path.full);
            cell_string = {'WaitForTrigger.RTTime';'PrepSlide.OnsetTime';'PrepDuration';'RestSlide.OnsetTime';'RestDuration';'PrepSlide.RT';'PrepSlide.RESP';'RestSlide.RT';'RestSlide.RESP'};
            for c = 1:numel(cell_string)
                [row(c) col(c)] = find(strcmp(header, cell_string{c}));
            end

            response_seconds(subject,run).tr            = 1000; % not TR, just to get the final output into seconds
            response_seconds(subject,run).trigger       = cell2mat(data(3,col(1)));
            response_seconds(subject,run).prep_onset	= cell2mat(data(3:end,col(2)))  -   response_seconds(subject,run).trigger;
            response_seconds(subject,run).prep_duration	= cell2mat(data(3:end,col(3)));
            response_seconds(subject,run).rest_onset	= cell2mat(data(3:end,col(4)))  -   response_seconds(subject,run).trigger;
            response_seconds(subject,run).rest_duration	= cell2mat(data(3:end,col(5)));
            response_seconds(subject,run).npreps        = length(response_seconds(subject,run).prep_onset);
            response_seconds(subject,run).nrests        = length(response_seconds(subject,run).rest_onset);
            response_seconds(subject,run).prep_button_t	= cell2str(data(3:end,col(7)));
            response_seconds(subject,run).rest_button_t	= cell2str(data(3:end,col(9)));
            response_seconds(subject,run).prep_response_t	= cell2mat(data(3:end,col(6)))	+	response_seconds(subject,run).prep_onset;
            response_seconds(subject,run).rest_response_t	= cell2mat(data(3:end,col(8)))  +   response_seconds(subject,run).rest_onset;

            if abs(response_seconds(subject,run).prep_onset + response_seconds(subject,run).prep_duration - response_seconds(subject,run).rest_onset) > 100
                fprintf('Check whether the Prep onset + its duration is roughly = Rest onset:\n')
                response_seconds(subject,run).prep_onset + response_seconds(subject,run).prep_duration - response_seconds(subject,run).rest_onset
            end
            clear c row col
            
            response_seconds(subject,run).prep_onset	= response_seconds(subject,run).prep_onset      / response_seconds(subject,run).tr;
            response_seconds(subject,run).rest_onset	= response_seconds(subject,run).rest_onset      / response_seconds(subject,run).tr;
            response_seconds(subject,run).prep_duration	= response_seconds(subject,run).prep_duration   / response_seconds(subject,run).tr;
            response_seconds(subject,run).rest_duration	= response_seconds(subject,run).rest_duration   / response_seconds(subject,run).tr;
            response_seconds(subject,run).lastonset     = max(max([response_seconds(subject,run).prep_onset response_seconds(subject,run).rest_onset]));
            response_seconds(subject,run).prep_response_t	= response_seconds(subject,run).prep_response_t      / response_seconds(subject,run).tr; %
            response_seconds(subject,run).rest_response_t	= response_seconds(subject,run).rest_response_t      / response_seconds(subject,run).tr; %
            response_seconds(subject,run).prep_response	= response_seconds(subject,run).prep_response_t(find(response_seconds(subject,run).prep_button_t~='t'));
            response_seconds(subject,run).rest_response	= response_seconds(subject,run).rest_response_t(find(response_seconds(subject,run).rest_button_t~='t'));
            response_seconds(subject,run).prep_button	= response_seconds(subject,run).prep_button_t(find(response_seconds(subject,run).prep_button_t~='t'));
            response_seconds(subject,run).rest_button	= response_seconds(subject,run).rest_button_t(find(response_seconds(subject,run).rest_button_t~='t'));
            
            cumulative.npreps(subject,run)    = response_seconds(subject,run).npreps;
            cumulative.nrests(subject,run)    = response_seconds(subject,run).nrests;
            cumulative.lastonset(subject,run) = response_seconds(subject,run).lastonset;
            
        end
        clc
        fprintf('Number of Preps:\n')
        cumulative.npreps
        fprintf('Number of Rests:\n')
        cumulative.nrests
        fprintf('Last onset (TRs):\n')
        cumulative.lastonset
        
        %save rest events
        event_file.rest = [response_seconds(subject,run).rest_onset response_seconds(subject,run).rest_duration linspace(1,1,numel(response_seconds(subject,run).rest_onset))'];
        %save prep events + version with 0s duration
        event_file.prep = [response_seconds(subject,run).prep_onset response_seconds(subject,run).prep_duration linspace(1,1,numel(response_seconds(subject,run).prep_onset))'];
        event_file.prep_0duration = [response_seconds(subject,run).prep_onset linspace(0,0,numel(response_seconds(subject,run).prep_onset))' linspace(1,1,numel(response_seconds(subject,run).prep_onset))'];
        %save button events
        response_timings = sort([response_seconds(subject,run).rest_response; response_seconds(subject,run).prep_response(find(response_seconds(subject,run).prep_button))]);
        event_file.button = [response_timings linspace(0,0,numel(response_timings))' linspace(1,1,numel(response_timings))'];
        %save blue button events
        response_timings = response_seconds(subject,run).rest_response(find(response_seconds(subject,run).rest_button=='b'));
        event_file.button_blue = [response_timings linspace(0,0,numel(response_timings))' linspace(1,1,numel(response_timings))'];
        %save blue prep events
        response_timings = response_seconds(subject,run).prep_onset(find(response_seconds(subject,run).rest_button=='b'));
        event_file.prep_0duration_blue = [response_timings linspace(0,0,numel(response_timings))' linspace(1,1,numel(response_timings))'];
        %save red prep events
        response_timings = response_seconds(subject,run).prep_onset(find(response_seconds(subject,run).rest_button=='r'));
        event_file.prep_0duration_red = [response_timings linspace(0,0,numel(response_timings))' linspace(1,1,numel(response_timings))'];
        %save red button events
        response_timings = response_seconds(subject,run).rest_response(find(response_seconds(subject,run).rest_button=='r'));
        event_file.button_red = [response_timings linspace(0,0,numel(response_timings))' linspace(1,1,numel(response_timings))'];
        
        if ~isempty(response_seconds(subject,run).prep_response)
            response_timings = response_seconds(subject,run).prep_response(find(response_seconds(subject,run).prep_button=='b'));
            event_file.button_blue_prep = [response_timings linspace(0,0,numel(response_timings))' linspace(1,1,numel(response_timings))'];
            event_file.button_blue = sort([event_file.button_blue; event_file.button_blue_prep],1,'ascend');
            
            response_timings = response_seconds(subject,run).prep_response(find(response_seconds(subject,run).prep_button=='r'));
            event_file.button_red_prep = [response_timings linspace(0,0,numel(response_timings))' linspace(1,1,numel(response_timings))'];
            event_file.button_red = sort([event_file.button_red; event_file.button_red_prep],1,'ascend');
        end

        filepath = sprintf('%ssubject%d_run%d_rest.txt',path.data,subject,run);
        dlmwrite(filepath, event_file.rest,' ');
        filepath = sprintf('%ssubject%d_run%d_prep.txt',path.data,subject,run);
        dlmwrite(filepath, event_file.prep,' ');
        filepath = sprintf('%ssubject%d_run%d_prep_0duration_blue.txt',path.data,subject,run);
        dlmwrite(filepath, event_file.prep_0duration_blue,' ');
        filepath = sprintf('%ssubject%d_run%d_prep_0duration_red.txt',path.data,subject,run);
        dlmwrite(filepath, event_file.prep_0duration_red,' ');
        filepath = sprintf('%ssubject%d_run%d_button.txt',path.data,subject,run);
        dlmwrite(filepath, event_file.button,' ');
        filepath = sprintf('%ssubject%d_run%d_button_blue.txt',path.data,subject,run);
        dlmwrite(filepath, event_file.button_blue,' ');
        filepath = sprintf('%ssubject%d_run%d_button_red.txt',path.data,subject,run);
        dlmwrite(filepath, event_file.button_red,' ');
        
        if ~isempty(find(response_seconds(subject,run).rest_button=='g'))
            wrong_presses.green(subject,run)=1;
            if isempty(find(response_seconds(subject,run).rest_button=='r'))
                %save blue button events
                response_timings = response_seconds(subject,run).rest_response(find(response_seconds(subject,run).rest_button=='g'));
                event_file.button_red = [response_timings linspace(0,0,numel(response_timings))' linspace(1,1,numel(response_timings))'];
                filepath = sprintf('%ssubject%d_run%d_button_red.txt',path.data,subject,run);
                dlmwrite(filepath, event_file.button_red,' ');
                %save blue prep events
                response_timings = response_seconds(subject,run).prep_onset(find(response_seconds(subject,run).rest_button=='g'));
                event_file.button_red = [response_timings linspace(0,0,numel(response_timings))' linspace(1,1,numel(response_timings))'];
                filepath = sprintf('%ssubject%d_run%d_prep_0duration_red.txt',path.data,subject,run);
                dlmwrite(filepath, event_file.prep_0duration_red,' ');
            end
        end
        if ~isempty(find(response_seconds(subject,run).rest_button=='y'))
            wrong_presses.yellow(subject,run)=1;
        end
    end
end

verify = zeros([num.subjects num.runs]);
verify(find(cumulative.lastonset)) = 1;

clear subject run numbers data header cell_string path ans



























