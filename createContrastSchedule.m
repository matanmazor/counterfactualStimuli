function [ contrast_schedule ] = createContrastSchedule( N_trials, step_std )


%1. do random walk
x = cumsum(normrnd(0,step_std, N_trials-10,1));
%2. mean center and add leading trials
contrast_schedule = [linspace(-1.5,-2.5,10)'; x-mean(x)];

end

