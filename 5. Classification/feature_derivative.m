function [out index] = feature_derivative(in)
[r c] = size(in);
out = in(:,2:c) - in(:,1:c-1);
index = 2:c;