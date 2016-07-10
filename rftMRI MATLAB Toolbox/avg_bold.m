function avg_bold(response,s,r,mean_matrix,time_delay,linecolor,plotname)
%%
tr = response(s).tr / 1000;
% time_delay = -5; % seconds, compensating for BOLD delay
fig_area_color = [.9 .9 .9];
fig_press_color = [.7 .7 .7];

if isempty(linecolor)
    linecolor = char(linspace('b','b',size(mean_matrix,1)));
end

prep_press_present = find(response(s,r).prep_response-response(s,r).prep_onset>0);
if ~isempty(prep_press_present)
    t0 = sort([response(s,r).rest_response' response(s,r).prep_response(prep_press_present)'])';
else
    t0 = response(s,r).rest_response;
end

prep_duration = response(s,r).rest_response - response(s,r).prep_onset;
prep_onset = response(s,r).prep_onset;

h = figure('position',[1 500 1900 300]);
hold on
for p = 1:length(prep_duration)
    area(tr*[prep_onset(p) prep_onset(p)+prep_duration(p)],[max(mean_matrix(:)) max(mean_matrix(:))],'facecolor',fig_area_color,'edgecolor',fig_area_color);
    area(tr*[prep_onset(p) prep_onset(p)+prep_duration(p)],[min(mean_matrix(:)) min(mean_matrix(:))],'facecolor',fig_area_color,'edgecolor',fig_area_color);
end
for p = 1:length(t0)
    area(tr*[t0(p) t0(p)+.5],[max(mean_matrix(:)) max(mean_matrix(:))],'facecolor',fig_press_color,'edgecolor',fig_press_color);
    area(tr*[t0(p) t0(p)+.5],[min(mean_matrix(:)) min(mean_matrix(:))],'facecolor',fig_press_color,'edgecolor',fig_press_color);
end

time_index = (0:tr:tr*size(mean_matrix,2)-1)+time_delay;

for p = 1:size(mean_matrix,1)
    plot(time_index,mean_matrix(p,:),'color',linecolor(p),'linewidth',2)
end
ylim([min(mean_matrix(:)) max(mean_matrix(:))])
xlim([min(time_index(:)) max(time_index(:))])
ylabel('BOLD intensity change')
xlabel('Time, s')

textTitle = sprintf('%s subject %d, run %d (Time Shift %d s.)',plotname,s,r,time_delay);

title(textTitle,'FontName','Monaco','FontSize',13)
set(gca,'LooseInset',get(gca,'TightInset'))
set(h,'PaperPositionMode','auto');

% saveas(gca,sprintf('~/Desktop/rtfMRI Report/%s.png',textTitle))
end