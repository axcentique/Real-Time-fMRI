function [out index] = feature_derivative2(in)
[r c] = size(in);
out = in(:,2:c) - in(:,1:c-1);
out = sign(out).*(out.^2);
index = 2:c;