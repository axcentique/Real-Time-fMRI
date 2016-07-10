%%%%%%%%%%%% Event Design
pathEV = '~/Desktop/tutorial/';
event_file{1} = 'REvent.tab';
event_file{2} = 'LEvent.tab';
% event_file{3} = 'restEvent.tab';

ev.right = load([pathEV event_file{1}]);
ev.left = load([pathEV event_file{2}]);