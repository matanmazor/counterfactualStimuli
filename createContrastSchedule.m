function [ contrast_schedule ] = createContrastSchedule( N_trials, chunk_size, levels, std_noise )


%1. random jumping
level_order = levels(randperm(numel(levels)));
level_order(level_order==max(level_order)) = level_order(1);
level_order(1) = max(levels);
repetitions = ceil(N_trials/(chunk_size*numel(levels)));
for rep = 1:repetitions-1
    level_order = [level_order levels(randperm(numel(levels)))];
end
x = repelem(level_order,chunk_size);
x = x(1:N_trials);
% cur_value = max(levels);
% for i = 1:N_trials
%     x(i) = cur_value;
%     if binornd(1,p_change)
%         cur_value = levels(randperm(numel(levels),1));
%     end
% end

% 2. smooth
x = smooth(x,6);

%3. add noise
x = x+normrnd(0,std_noise,size(x));

contrast_schedule = x;

end

