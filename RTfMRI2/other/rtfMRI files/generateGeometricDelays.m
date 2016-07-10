clc

geoParameter = .25;
requredSize = 22;
timingMatrix = [];

for s = 1:50
    currentSize = 0;
    timingVector = [];
    while currentSize ~= requredSize
        geoValue = geornd(geoParameter);
        if geoValue <= 10
            timingVector(numel(timingVector)+1) = geoValue;
        end
        currentSize = numel(timingVector);
    end
    timingMatrix(:,s) = timingVector;
end

% timingMatrix
% hist(timingVector)
% figure, hist(timingMatrix(:))

mean(timingMatrix)

%%
% fid = fopen('~/Desktop/geoDelays.txt','wt');
% fprintf(fid, '%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d\n', timingMatrix);
% fclose(fid);


%%
clc

rest_Vector = 12:.25:16;

rest_g = .15;
rest_geoVal = geornd(rest_g,[22,1]);
rest_geoVal = sort(rest_geoVal)

rest_Vec_index = unique(rest_geoVal)
rest_Vec_weight = histc(rest_geoVal,unique(rest_geoVal))

sum(rest_Vector(rest_Vec_index+1).*rest_Vec_weight')