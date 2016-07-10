function [out index] = feature_anticorr(in1,in2)
if min(size(in1) ~= size(in1))
   error('\nInput matrix must be of the same size.\n') 
end
[r c] = size(in1);
% [r c] = size(in2);
out1 = in1(:,2:c) - in1(:,1:c-1);
out2 = in2(:,2:c) - in2(:,1:c-1);
out = out1 - out2;
% out = sign(out1 - out2).*((out1 - out2).^2);
index = 2:c;