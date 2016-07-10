function vol = volume_threshold_noBin(volume,thresh_low)

if numel(size(volume))~=3
    fprintf('Warning: Input volume is not in 3D.\n\n');
end

% if (numel(thresh_low) ~= numel(thresh_high)) && numel(thresh_high)>1
%     error('Different number of upper and lower thresholds.')
% end



% if isequal(thresh_percent,'percent')
%     if thresh_low < 0 || thresh_low > 1 || thresh_high < 0 || thresh_high > 1 
%         error('Threshold values shoud be in range [0,1]');
%     end
%     
%     delta = max(volume(:)) - min(volume(:));
%     if delta < 0 
%         error('Debug: Delta is negative.')
%     end
%     
%     thresh_low = thresh_low * delta + min(volume(:));
%     thresh_high = thresh_high * delta + min(volume(:));
% end





% if numel(thresh_high) == 1 && numel(thresh_low) > 1
%     thresh_high = linspace(thresh_high,thresh_high,numel(thresh_low));
% end


% for n=1:numel(thresh_low)
%     out.threshold.high = thresh_high(n);
%     out.threshold.low = thresh_low(n);
    vol = zeros(size(volume));

    index = find(volume >= thresh_low);
%     index_high = find(volume <= thresh_high(n));
%     index = intersect(index_low,index_high);

%     if isequal(norm_flag,'binarize')
%         vol(index) = 1;
%     else
        vol(index) = volume(index);
%     end

    % omit negative values in the thresholded volume if flag is set
%     if isequal(thresh_nonnegative,'nonnegative')
%         ind = find(out.vol < 0);
%         out.vol(ind) = 0;
%         
%         if ~isempty(ind)
%             fprintf('Warning: Some negative thresholded values were omitted.\n\n');
%         end
%     end
%     
%     outCell{n} = out;
% end
