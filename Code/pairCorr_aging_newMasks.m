clear
clc

% set MATLAB working directory to the folder with the Art_Connect_1
filepath_masks_root = sprintf('/share/Art_Connect_1/NewMasks/');

% path where to save the tables with correlation values 
savePath = '~/Desktop/aging/old_masks/mesh/';

subj = [444653; 445002; 554701; 554755; 555153; 664509; 664905; 664912; 665001; 665005; 665209; 665357; 665503; 774552; 774756; 774801; 774868; 774972; 774975; 775002; 775019; 775053; 775068; 775102; 775118; 775206; 775216; 775261; 775321];
regNum = 6;
hopNum = 10;
timeFrameNum = 1;

scan_size = [64 64 38];

% corrPath = sprintf('corr/aging/');
% % region names for filenames
% nameRegion{1} = 'bilateral medial frontal';
% nameRegion{2} = 'bilateral posterior cingulate';
% nameRegion{3} = 'left lateral parietal';
% nameRegion{4} = 'left medial temporal';
% nameRegion{5} = 'right lateral parietal';
% nameRegion{6} = 'right medial temporal';
%%

for s = 1:numel(subj)
        %%
        fprintf('\n\nSubject %1.0f | %1.0f',s,subj(s))
        
%         load(sprintf('%sPairCor_%d.mat',corrPath,subj(s)));
        filepath = sprintf('/share/Art_Connect_1/%6.0f/%6.0f_rest_filt_all.nii.gz',subj(s),subj(s));
        import = MRIread(filepath);
        
        filepath_mask{1} = sprintf('%s%6.0f_DMN_B_medfrt_thr3.nii.gz',filepath_masks_root,subj(s));
        filepath_mask{2} = sprintf('%s%6.0f_DMN_B_pocing_thr3.nii.gz',filepath_masks_root,subj(s));
        filepath_mask{3} = sprintf('%s%6.0f_DMN_L_latpar_thr3.nii.gz',filepath_masks_root,subj(s));
        filepath_mask{4} = sprintf('%s%6.0f_DMN_L_metemp_thr1.5.nii.gz',filepath_masks_root,subj(s));
        filepath_mask{5} = sprintf('%s%6.0f_DMN_R_latpar_thr3.nii.gz',filepath_masks_root,subj(s));
        filepath_mask{6} = sprintf('%s%6.0f_DMN_R_metemp_thr1.5.nii.gz',filepath_masks_root,subj(s));
%%
        funcInd = find(import.vol(:,:,:,1));
        for i = 1:numel(filepath_mask)
            data = MRIread(filepath_mask{i});
            network.region{i} = intersect(funcInd,find(squeeze(data.vol(:,:,:,1))));
        end
%%
    for reg=1:regNum
        fprintf('\nRegion %d. ',reg)

        vxl = network.region{reg};
        %% get region size by x y z
        [xVox yVox zVox] = ind2sub(scan_size,vxl);
        regSize = [max(xVox)-min(xVox) max(yVox)-min(yVox) max(zVox)-min(zVox)];
        %%
%         orphanedVoxelIndex = [];
%         fprintf('Hop:')
        for degree=ceil(2*max(regSize))%:hopNum
%             fprintf(' %d',degree)
%             if 2*degree > max(regSize)
%                 continue
%             end
            
            timeTotalLength = size(import.vol,4);
            %%
            timeFrameLength = timeTotalLength/timeFrameNum;
            timeFrameStart = timeFrameLength*(0:timeFrameNum-1)+1;
            timeFrameEnd = timeFrameLength*(1:timeFrameNum);
            %%
            for t = 1:timeFrameNum
                clear corMat orphanedVoxelIndex
                %%
                for i=1:numel(vxl)
                    %%
                    vxlRange = vxl';
                    vxlRange(i) = '';
%                     [x y z] = ind2sub(scan_size,vxl(i));
% 
%                     vxlRange = [];
%                     for xInd = -degree:degree
%                         for yInd = -degree:degree
%                             parfor zInd = -degree:degree
%                                 if ~(xInd==0 && yInd==0 && zInd==0)
%                                     if ((x+xInd)<=scan_size(1)) && ((y+yInd)<=scan_size(2)) && ((z+zInd)<=scan_size(3)) && (((x+xInd)>0) && ((y+yInd)>0) && ((z+zInd)>0))
%     %                                     if round(pdist([x y z ; x+xInd y+yInd z+zInd]))==degree
%                                             vxlRange = [vxlRange sub2ind(scan_size,x+xInd,y+yInd,z+zInd)];
%     %                                     end
%                                     end
%                                 end
%                             end
%                         end
%                     end
                    %%

    %                 vxlRangeIn = [];
    %                 for xInd = -(degree-1):(degree-1)
    %                     for yInd = -(degree-1):(degree-1)
    %                         for zInd = -(degree-1):(degree-1)
    %                             if ((x+xInd)<=scan_size(1)) && ((y+yInd)<=scan_size(2)) && ((z+zInd)<=scan_size(3)) && (((x+xInd)>0) && ((y+yInd)>0) && ((z+zInd)>0))
    %                                 vxlRangeIn = [vxlRangeIn sub2ind(scan_size,x+xInd,y+yInd,z+zInd)];
    %                             end
    %                         end
    %                     end
    %                 end
    % 
    %                 vxlRange = setdiff(vxlRange,vxlRangeIn);

                    %%
                    vxlRange = sort(vxlRange);
                    vxlRange = [vxl(i) vxlRange];

                    vxlIncluded = vxlRange(ismember(vxlRange,vxl));

                    if vxlRange(1)~= vxlIncluded(1)
                        error('The origin voxel is missing!?')
                    end
                    
                    if length(vxlIncluded) ~= length(vxlRange)
                        error('Voxel vector length mismatch')
                    end

                    if length(vxlIncluded)<=1
                        continue
%                         error('Orphan voxel')
                    end

                    [xR yR zR] = ind2sub(scan_size,vxlIncluded);

                    clear timeSeries
                    parfor j=1:length(xR)
                        timeSeries(j,:) = squeeze(import.vol(xR(j),yR(j),zR(j),timeFrameStart(t):timeFrameEnd(t)));
                    end

                    corValues = abs(1-pdist(timeSeries,'correlation'));
                    %%

    %                corMat(i,i) = 1;
                    voxInd = [];
                    for j=2:length(vxlIncluded)
                        curInd = find(vxl == vxlIncluded(j));
                        voxInd = [voxInd curInd];
                        corMat(curInd,i) = corValues(j-1);
                        corMat(i,curInd) = corValues(j-1);
                    end
                    %%
%                     orphanedVoxelIndex = find(bfs(corMat,1)==-1);
%         %             
%                     if length(orphanedVoxelIndex) > .5 * length(vxl)
%                         startNode = orphanedVoxelIndex(1);
%                         orphanedVoxelIndex = find(bfs(corMat,startNode)==-1);
%                     end
                    %%
        %             for j=1:numel(vxlIncluded)
        %                 vxlIndex = find(vxl==vxlIncluded(j));
        %                 linkMat(i,vxlIndex) = 1;
        %                 linkMat(vxlIndex,i) = 1;
        %                 if (size(corMat,1) ~= size(linkMat,1)) && (size(linkMat,1)>1)
        %                     j
        %                     error(':P');
        %                 end
        %             end
                    clc
                    fprintf('Subject %d/%d, Region %d, Progress: %f',s,numel(subj),reg,i/numel(vxl))
                end
        
            if size(corMat,1) ~= length(vxl)
                error('Correlation matrix size is different from that of the region')
            end
            if min([numel(vxl) numel(vxl)] ~= size(corMat))
                error('Non-square matrix')
            end 
            
%             if ~isempty(orphanedVoxelIndex)
%                 for i=length(orphanedVoxelIndex):-1:1
%                     corMat(:,orphanedVoxelIndex(i))=[];
%                     corMat(orphanedVoxelIndex(i),:)=[];
% %                     linkMat(:,orphanedVoxelIndex(i))=[];
% %                     linkMat(orphanedVoxelIndex(i),:)=[];
%                 end
%             end
%             if isempty(find(bfs(corMat,1)<0))
%                 [tree treeCorr] = UndirectedMaximumSpanningTree(corMat);
%                 resultTable(s,reg,degree) = treeCorr/(numel(vxl)-1);
%             else
%                 resultTable(s,reg,degree) = 999;
%             end
            
%             resultTable(s,reg,degree) = sum(corMat(:)) / length(find((corMat)));
            
% !!!!!!!!! Correlation matrixes
            corMatDB{s,reg,t} = corMat;
            
            z = 0.5*log((1 + corMat) ./ (1 - corMat));
            zscore(s,reg) = sum(z(:) / length(find(z)));
            zcorr(s,reg) = tanh(zscore(s,reg));

%             try
%                 [tree treeCorr] =  UndirectedMaximumSpanningTree (corMat);
%                 fprintf('Processed: %f\n', treeCorr/(numel(vxl)-1))
%                 resultTable(s,reg,degree) = treeCorr/(numel(vxl)-1);
%                 treeReg{t} = tree;
%             catch
%                 notLoaded(s,reg,t) = 1;
%                 fprintf('Not Processed: Error\n')
%             end
% 
%             treeMatDB{s,reg,t} = tree;
%             treeCorrDB{s,reg,t} = treeCorr;
            
%         dynSTtable(s+1,1) = subj(s);
% 
%         load(sprintf('%sPairCor_%d.mat',corrPath,subj(s)));
        save(sprintf('%sMesh_intraregion.mat',savePath),'corMatDB');
            
% % % % % %             filepath = sprintf('%sdynSPT_aging_step_%d,_hop%d.csv',savePath,t,degree);
% % % % % %             csvwrite(filepath, squeeze(resultTable(:,:,degree)));

%             filepath = sprintf('%sRing_PairCor_region_%d.csv',savePath,reg);
%             csvwrite(filepath, squeeze(resultTable(:,reg,:)));
% 
%             filepath = sprintf('%sRing_PairCor_subject_%d.csv',savePath,subj(s));
%             csvwrite(filepath, squeeze(resultTable(s,:,:)));
            %%

    %         if ~isempty(orphanedVoxelIndex)
    %             plot_4views(vxl,subj,s,nameRegion,reg,filepath_mask,1,1,orphanedVoxelIndex,'~/Pictures/aging/')
    %         end

    %         for i=length(orphanedVoxelIndex):-1:1
    %             corMat(:,orphanedVoxelIndex(i))=[];
    %             corMat(orphanedVoxelIndex(i),:)=[];
    %             linkMat(:,orphanedVoxelIndex(i))=[];
    %             linkMat(orphanedVoxelIndex(i),:)=[];
    %         end

    %%saving the correlation matrix
%             switch reg
%                 case 1
%                     PairCor_B_medfrt = corMat;
%                 case 2
%                     PairCor_B_orbfrt = corMat;
%                 case 3
%                     PairCor_B_pocing = corMat;
%                 case 4
%                     PairCor_L_latpar = corMat;
%                 case 5
%                     PairCor_L_metemp = corMat;
%                 case 6
%                     PairCor_R_latpar = corMat;
%                 case 7
%                     PairCor_R_metemp = corMat;
%             end
            
    %         try
    %             [ tree, treeCorr ] =  UndirectedMaximumSpanningTree ( corMat .* linkMat );
    %             fprintf('Processed: %f\n', treeCorr/(numel(vxl)-1))
    %             resultTable(s+1,reg+1) = treeCorr/(numel(vxl)-1);
    %             treeReg{reg} = tree;
    %         catch
    %             fprintf('Not Processed: Error\n')
    %         end
%             if resultTable(s+1,1,1) ~= subj(s)
%                 error('Subject Number mismatch')
%             end
            end
        end

%         filepath = sprintf('%sRing_PairCor_%d_hop.csv',savePath,degree);
%         csvwrite(filepath, [[0:length(squeeze(resultTable(1,:,1)))]; [subj(1:length(squeeze(resultTable(:,:,degree)))); squeeze(resultTable(:,:,degree))]']);
% 
%         filepath = sprintf('%sRing_PairCor_region_%d.csv',savePath,reg);
%         csvwrite(filepath, squeeze(resultTable(:,reg,:)));
% 
%         filepath = sprintf('%sRing_PairCor_subject_%d.csv',savePath,subj(s));
%         csvwrite(filepath, squeeze(resultTable(s,:,:)));
    end
    
%     resultTable = [];
%     for reg=1:regNum
%         resultTable = [resultTable; squeeze([corAverageDB{s,reg,:}])];
%     end
%     filepath = sprintf('%sMesh, subj %d.csv',savePath,subj(s));
%     csvwrite(filepath, squeeze(resultTable(:,:,degree)));
    
    filepath = sprintf('%smesh_interregion_zscore.csv',savePath);
    csvwrite(filepath, squeeze([subj(1:s), zscore(1:s,:)]));

    filepath = sprintf('%smesh_interregion_zcorr.csv',savePath);
    csvwrite(filepath, squeeze([subj(1:s), zcorr(1:s,:)]));    

end



% for degree=1:hopNum
%     filepath = sprintf('%sRing_PairCor_%d_hop.csv',savePath,degree);
%     csvwrite(filepath, squeeze(resultTable(:,:,degree)));
% end