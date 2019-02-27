correct = [];
p = 1;
for trial = 1:10000
    correct(end+1) = binornd(1,p(trial));
    p(trial+1) = p(trial);
    if numel(correct)==2 
        if sum(correct)==2 %[1 1]
            p(trial+1) = max(0, p(trial)-0.01);
        elseif sum(correct)==1 %[1 0]
            p(trial+1) = min(1, p(trial)+0.01);
        end
        correct = [];
    elseif numel(correct)==1 && sum(correct)==0 %[0]
        correct = [];
        p(trial+1) = min(1, p(trial)+0.01);
    end
end

correct = [];
p = 1;
for trial = 1:10000
    correct(end+1) = binornd(1,p(trial));
    p(trial+1) = p(trial);
   if correct(end)==0 %[0]
        correct = [];
        p(trial+1) = min(1, p(trial)+0.01);
   elseif numel(correct)==3 && sum(correct)==3
       correct = [];
        p(trial+1) = max(0, p(trial)-0.01);
   end
end