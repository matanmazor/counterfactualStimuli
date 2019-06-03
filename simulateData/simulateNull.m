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
mean_noise = -4;
perceptual_std = 2;
criteria = -6:2:2;

% Initialize log with NaNs where possible.
log.resp = nan(params.Nblocks*params.Ntrials,2);
log.visibility = nan(params.Nblocks*params.Ntrials,1);
log.correct = nan(params.Nblocks*params.Ntrials,1);
log.confidence =  nan(params.Nblocks*params.Ntrials,1);
log.internal_variable =  nan(params.Nblocks*params.Ntrials,1);

for trial = 1:params.Nblocks*params.Ntrials
    if plan.present(trial)==0
        cur_visibility = mean_noise;
    else
        cur_visibility = plan.visibility(trial);
    end
    decision_variable = normrnd(cur_visibility, perceptual_std);
    decision = discretize(decision_variable, [-inf criteria inf]);
    if decision>3
        log.resp(trial)=1;
        log.confidence(trial) = decision-3;
    else
        log.resp(trial)=0;
        log.confidence(trial) = 4-decision;
    end
    log.visibility(trial) = cur_visibility;
    log.internal_variable(trial) = decision_variable;
    log.correct(trial) = log.resp(trial)==plan.present(trial);
end

simulated_data = log;
end