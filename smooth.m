function [ smoothed_vector ] = smooth( vector, window_size )
%SMOOTH returns a smoothed vector (because matlab2015b doesn't support
%smooth. matan mazor 2019


for i = 1:numel(vector)
    
    half_window = min(floor(window_size/2),min(floor(i/2),floor((numel(vector)-i)/2)));
    smoothed_vector(i) = mean(vector(i-half_window:i+half_window));
    
end

end

