function [r,p] = nancorr(x,y)
%% Spearman's correlation exculding NaNs 
good_trials = find(~isnan(x) & ~isnan(y));
[r,p] = corr(x(good_trials),y(good_trials), 'Type', 'Spearman');
end