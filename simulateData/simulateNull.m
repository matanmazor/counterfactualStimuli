function simulated_data = simulateNull()

addpath('..'); % needed in order to run makePlan

% some parameters that are needed for the makePlan function to run:
params.Nblocks = 4;
params.Ntrials = 120;
params.ifi = 1/30;
params.vis_face = -1.5; %calibration.vis_face;
params.vis_house = -1.3; %calibration.vis_house;
params.event_duration = 1;
params.display_duration = 1;
params.house_list = cell(1000,1);
params.face_list = cell(1000,1);
plan = makePlan(params);

%% 1. initialize log
log.resp = nan(params.Nblocks*params.Ntrials,2);
log.visibility = nan(params.Nblocks*params.Ntrials,1);
log.correct = nan(params.Nblocks*params.Ntrials,1);
log.confidence =  nan(params.Nblocks*params.Ntrials,1);
log.internal_variable =  nan(params.Nblocks*params.Ntrials,1);
log.expected_visibility = nan(params.Nblocks*params.Ntrials,1);

%% internal parameters
% these parameters reflect internal components of the simulated agent
mean_noise = -4; %remains constant
mean_signal = nanmean(plan.visibility(plan.present==1));
perceptual_std = 2; 
criteria = -4:2:4; % The 3rd (decision) criterion is set to 0.
scalar = 1; % A scalar by which the criteria are scaled. 
shifter = mean([mean_noise, mean_signal]); % A constant addition to the criterion set.


%% Run null model for each trial
for trial = 1:params.Nblocks*params.Ntrials
    
    %this reflects the agent's belief about the mean of the distribution of
    %visbility levels.
    cur_expected_visibility = log.expected_visibility(trial); 
    
    % in the case that this is a noise trial, the input to the perceptual system
    % is the mean of the noise distribution.    
    if plan.present(trial)==0
        cur_visibility = mean_noise; 
    %otherwise, it is the visibility level on this trial.    
    else
        cur_visibility = plan.visibility(trial);
    end
    
%     %model 1 assumes a rigid shift in criteria as a function of expVis
%     if isnan(cur_expected_visibility)
%          shifter = 0;
%     else
%         shifter = mean([mean_noise, cur_expected_visibility]); 
%     end
    
    %%model 2 assumes a scaling of the criteria as a function of expVis
%     if isnan(cur_expected_visibility)
%         scalar = 1;
%     else
%         scalar = abs(cur_expected_visibility/6);
%     end
    
    new_criteria = scalar*criteria + shifter;
    
    %the decision variable is centered around the objective input to the
    %perceptual system, and varies as a function of the perceptual
    %variance.
    decision_variable = normrnd(cur_visibility, perceptual_std);
    %the decision is made based on the location of the decision variable
    %with respect to the set of criteria.
    decision = discretize(decision_variable, [-inf new_criteria inf]);
    
    if decision>3 %if yes response
        log.resp(trial)=1;
        log.confidence(trial) = decision-3;
        next_expected_visibility = cur_visibility;
    else %if no response
        log.resp(trial)=0;
        log.confidence(trial) = 4-decision;
        next_expected_visibility = cur_expected_visibility;
    end
    log.visibility(trial) = cur_visibility;
    log.internal_variable(trial) = decision_variable;
    log.correct(trial) = log.resp(trial)==plan.present(trial);
    
    %multiples of 120 (120, 240, 360, 480) correspond to the final trial
    %of a certain block, so expected value can be updated for every trial
    %except for the final one of each block (i.e. a multiple of 120).
    %since log.expected_visibility has been initialised with Nan values,
    %the loop can just continue for these final trials, such that the EVis
    %of the first trial within the next block will be NaN (no expectation)
    if mod(trial,120) ~= 0 % trial ~= 120 && trial ~= 240 && trial ~= 360 && trial ~= 480
        log.expected_visibility(trial+1) = next_expected_visibility;
    else
        continue %log.expected_visibility(trial+1) = NaN;
    end

end

simulated_data = log;
end