function [r,p] = nancorr(x,y)
good_trials = find(~isnan(x) & ~isnan(y));
[r,p] = corr(x(good_trials),y(good_trials));
end

