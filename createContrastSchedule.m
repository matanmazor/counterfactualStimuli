function [ contrast_schedule ] = createContrastSchedule( N_trials, step_std )


%1. do random walk
x = cumsum(normrnd(0,step_std, N_trials,1));
%2. mean center
contrast_schedule = x-mean(x);

end

