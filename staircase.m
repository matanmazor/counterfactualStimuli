function [vis,correct] = staircase(vis, correct, step_size)
% 3 down 1 up

if correct(end) == 0
    vis(end+1) = vis(end)+step_size;
    correct = [];
elseif numel(correct)==3 && sum(correct)==3
    vis(end+1) = vis(end)-step_size;
    correct = [];
else
    vis(end+1) = vis(end);
end

end

