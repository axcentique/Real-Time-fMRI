%%%%%%%%%%%% Block Design
pathEV = '~/Desktop/tutorial/';
event_file{1} = 'RBlock.tab';
event_file{2} = 'LBlock.tab';
% event_file{3} = 'restBlock.txt';

%%%%%%%%%%%% Event Design
% contrast_mask.right = MRIread('~/Desktop/tutorial/EventOutput/EventDesignVanillaTiming.feat/stats/zstat1.nii.gz');
% contrast_mask.left = MRIread('~/Desktop/tutorial/EventOutput/EventDesignVanillaTiming.feat/stats/zstat2.nii.gz');
% contrast_mask.rest = MRIread('~/Desktop/tutorial/EventOutput/EventDesignVanillaTiming.feat/stats/zstat3.nii.gz');
% func = MRIread('~/Desktop/tutorial/EventOutput/EventDesignVanillaTiming.feat/filtered_func_data.nii.gz');
% 
%%% Volumized
% contrast_mask.right = MRIread('~/Desktop/tutorial/EventOutput/EventDesign.feat/stats/zstat1.nii.gz');
% contrast_mask.left = MRIread('~/Desktop/tutorial/EventOutput/EventDesign.feat/stats/zstat2.nii.gz');
% contrast_mask.rest = MRIread('~/Desktop/tutorial/EventOutput/EventDesign.feat/stats/zstat3.nii.gz');
% func = MRIread('~/Desktop/tutorial/EventOutput/EventDesign.feat/filtered_func_data.nii.gz');
%%
% pathEV = '~/Desktop/tutorial/';
% event_file{1} = 'REvent.tab';
% event_file{2} = 'LEvent.tab';
% event_file{3} = 'restEvent.tab';
%%%%%%%%%%%

ev.right = load([pathEV event_file{1}]);
ev.left = load([pathEV event_file{2}]);