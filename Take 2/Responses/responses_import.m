clear 
clc

fprintf('Importing responses...\n')

path.full = '/Users/george/Desktop/RTfMRI/responses.xls';
[numbers header data] = xlsread(path.full);
row_shift = size(header,1) - size(numbers,1);
subject_list = 102:111;
number_of_trials = 22;
num.subjects = numel(subject_list);
num.runs = 5;

for subject_number = 1:num.subjects
    subject_name = subject_list(subject_number);
    subject_rows = find(numbers(:,1) == subject_name) + row_shift;
    subject_data = [header(1:2,:); data(subject_rows,:)];
    
    subject_session_numbers = cell2mat(subject_data(3:end,3));
    
    if unique(subject_session_numbers) ~= [1 2 3]'
        error('Which column contains the session numbers? (Assumed: 3rd)')
    end
    if ~((sum(subject_session_numbers == 1) == 2*number_of_trials)&&(sum(subject_session_numbers == 2) == 2*number_of_trials)&&(sum(subject_session_numbers == 3) == number_of_trials))
        error(sprintf('Each session must have %d trials!',number_of_trials))
    end
    
    subject_session_numbers(2*number_of_trials+1:end) = subject_session_numbers(2*number_of_trials+1:end) + 2;
    subject_data(3:end,3) = num2cell(subject_session_numbers);
    
    subject_responses{subject_number} = subject_data;
end

%%

verify.lastonset = zeros([num.subjects num.runs]);

for subject = 1:num.subjects
    for run = 1:num.runs
        [numbers header data] = xlsread(path.full);
        cell_string = {'WaitForTrigger.RTTime';'PrepSlide.OnsetTime';'PrepDuration';'RestSlide.OnsetTime';'RestDuration';'PrepSlide.RT';'PrepSlide.RESP';'RestSlide.RT';'RestSlide.RESP'};
        for c = 1:numel(cell_string)
            [row(c) col(c)] = find(strcmp(header, cell_string{c}));
        end

        response(subject,run).tr            = 1500;
        response(subject,run).trigger       = cell2mat(data(3,col(1)));
        response(subject,run).prep_onset	= cell2mat(data(3:end,col(2)))  -   response(subject,run).trigger;
        response(subject,run).prep_duration	= cell2mat(data(3:end,col(3)));
        response(subject,run).rest_onset	= cell2mat(data(3:end,col(4)))  -   response(subject,run).trigger;
        response(subject,run).rest_duration	= cell2mat(data(3:end,col(5)));
        response(subject,run).npreps        = length(response(subject,run).prep_onset);
        response(subject,run).nrests        = length(response(subject,run).rest_onset);
        response(subject,run).prep_button_t	= cell2str(data(3:end,col(7)));
        response(subject,run).rest_button_t	= cell2str(data(3:end,col(9)));
        response(subject,run).prep_response_t	= cell2mat(data(3:end,col(6)))	+	response(subject,run).prep_onset;
        response(subject,run).rest_response_t	= cell2mat(data(3:end,col(8)))  +   response(subject,run).rest_onset;

        if abs(response(subject,run).prep_onset + response(subject,run).prep_duration - response(subject,run).rest_onset) > 100
            fprintf('Check whether the Prep onset + its duration is roughly = Rest onset:\n')
            response(subject,run).prep_onset + response(subject,run).prep_duration - response(subject,run).rest_onset
        end
        clear c row col

        response(subject,run).prep_onset	= round(response(subject,run).prep_onset      / response(subject,run).tr) + 1;
        response(subject,run).rest_onset	= round(response(subject,run).rest_onset      / response(subject,run).tr) + 1;
        response(subject,run).prep_duration	= round(response(subject,run).prep_duration   / response(subject,run).tr);
        response(subject,run).rest_duration	= round(response(subject,run).rest_duration   / response(subject,run).tr);
        response(subject,run).lastonset     = max(max([response(subject,run).prep_onset response(subject,run).rest_onset]));
        response(subject,run).prep_response_t	= floor(response(subject,run).prep_response_t      / response(subject,run).tr)+ 1; %
        response(subject,run).rest_response_t	= floor(response(subject,run).rest_response_t      / response(subject,run).tr)+ 1; %
        response(subject,run).prep_response	= response(subject,run).prep_response_t(find(response(subject,run).prep_button_t~='t'));
        response(subject,run).rest_response	= response(subject,run).rest_response_t(find(response(subject,run).rest_button_t~='t'));
        response(subject,run).prep_button	= response(subject,run).prep_button_t(find(response(subject,run).prep_button_t~='t'));
        response(subject,run).rest_button	= response(subject,run).rest_button_t(find(response(subject,run).rest_button_t~='t'));

        cumulative.npreps(subject,run)    = response(subject,run).npreps;
        cumulative.nrests(subject,run)    = response(subject,run).nrests;
        cumulative.lastonset(subject,run) = response(subject,run).lastonset;

        clc
        fprintf('Number of Preps:\n')
        cumulative.npreps
        fprintf('Number of Rests:\n')
        cumulative.nrests
        fprintf('Last onset (TRs):\n')
        cumulative.lastonset
    end
end

verify = zeros([num.subjects num.runs]);
verify(find(cumulative.lastonset)) = 1;

clear subject run numbers data header cell_string path ans
