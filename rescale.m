function [ rescaled_A ] = rescale( A )
% rescale matrix values to be in the interval between 0 and 1

A = double(A); %convert A to a float
rescaled_A = (A-min(A(:)))/(max(A(:))-min(A(:)));



end

