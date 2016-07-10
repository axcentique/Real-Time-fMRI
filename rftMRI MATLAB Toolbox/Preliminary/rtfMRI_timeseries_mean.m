function TS_mean = rtfMRI_timeseries_mean(maskVol)
%%
volInd = find(maskVol(:,:,:,1));
[x y z] = ind2sub(size(maskVol(:,:,:,1)),volInd);

parfor j=1:length(volInd)
    %%
    TS(j,:) = squeeze(maskVol(x(j),y(j),z(j),:));
%     clc, fprintf('Progress: %d',j/length(volInd)*100)
end

TS_mean = mean(TS);