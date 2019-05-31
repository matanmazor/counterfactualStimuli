function [ contrast_schedule ] = createContrastSchedule( N_trials, step_std )


%1. do random walk
x = cumsum(normrnd(0,step_std, N_trials-20,1));
x = x-mean(x);
%2. mean center and add leading trials
contrast_schedule = [linspace(0.5,x(1),20)'; x];

end

