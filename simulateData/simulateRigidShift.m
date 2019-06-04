function simulated_data = simulateNull()

addpath('..');
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

%% internal parameters
mean_noise = -4; %remains constant
perceptual_std = 2;
criteria = -6:2:2;

% Initialize log with NaNs where possible.
log.resp = nan(params.Nblocks*params.Ntrials,2);
log.visibility = nan(params.Nblocks*params.Ntrials,1);
log.correct = nan(params.Nblocks*params.Ntrials,1);
log.confidence =  nan(params.Nblocks*params.Ntrials,1);
log.internal_variable =  nan(params.Nblocks*params.Ntrials,1);
log.expected_visibility = nan(params.Nblocks*params.Ntrials,1);

% Run null model for each trial
for trial = 1:params.Nblocks*params.Ntrials
    
    cur_expected_visibility = log.expected_visibility(trial)
    
    if plan.present(trial)==0
        cur_visibility = mean_noise;
    else
        cur_visibility = plan.visibility(trial);
    end
    
    decision_variable = normrnd(cur_visibility, perceptual_std);
    
    if cur_expected_visibility > decision_variable
        criteria = criteria + (cur_expected_visibility - decision_variable);
    end
    
    decision = discretize(decision_variable, [-inf criteria inf]);
    
    if decision>3 %if yes response
        log.resp(trial)=1;
        log.confidence(trial) = decision-3;
        next_expected_visibility = cur_visibility;
    else %if no response
        log.resp(trial)=0;
        log.confidence(trial) = 4-decision;
        next_expected_visibility = mean_noise;
    end
    log.visibility(trial) = cur_visibility;
    log.internal_variable(trial) = decision_variable;
    log.correct(trial) = log.resp(trial)==plan.present(trial);
    
    if trial ~= 120 && trial ~= 240 && trial ~= 360 && trial ~= 480
        log.expected_visibility(trial+1) = next_expected_visibility;
    else
        continue %log.expected_visibility(trial+1) = NaN;
    end

end

simulated_data = log;
end