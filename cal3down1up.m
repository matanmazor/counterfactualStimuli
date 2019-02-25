%calibration script for the counterfactual stimuli experiment. 

clear all
version = '2019-02-20';

global log
global params
global global_clock
global w %psychtoolbox window

%% 1. ask for name
prompt = {'Name: '};
dlg_title = 'Filename'; % title of the input dialog box
num_lines = 1; % number of input lines
default = {'42KaFr'}; % default filename
savestr = inputdlg(prompt,dlg_title,num_lines,default);
name = savestr{1};

%% 2. set preferences and open screen

% change to w = setWindow(1) for debugging mode.
[w,rect] = setWindow(0); %open psychtoolbox. 
params = loadPars(rect, name);
        
%% 3. initialize log

% Initialize log with NaNs where possible.
log.resp = nan(params.Ntrials,2);
log.visibility = nan(params.Ntrials,1);
log.correct = nan(params.Ntrials,1);
log.events = [];

vis_house_log = -1.5;
vis_face_log = -1.5;
correct_house = [];
correct_face = [];

%% 4. run calibration

global_clock = tic();

for num_trial = 1:params.Ntrials
  
    if params.house(num_trial)
         response = trialGradual2AFC(num_trial, vis_house_log(end));
    else
         response = trialGradual2AFC(num_trial, vis_face_log(end));
    end
    
    log.resp(num_trial,:) = response;
    log.correct(num_trial) = log.resp(num_trial,2)==params.present(num_trial);
    
    if params.house(num_trial)
        [vis_house_log,correct_house] = staircase(vis_house_log, [correct_house,...
            log.correct(num_trial)],0.2);
    else
        [vis_face_log,correct_face] = staircase(vis_face_log, [correct_face,...
            log.correct(num_trial)],0.2);
    end
    
end

% close
Priority(0);
ShowCursor
Screen('CloseAll');

% Make a gong sound so that I can hear from outside the testing room that
% the behavioural session is over :-)
load gong.mat;
soundsc(y);

%% 5. take mean of last 15 trials

vis_house = mean(vis_house_log(end-14:end));
vis_face = mean(vis_house_log(end-15:end));

save(fullfile('data',[params.name,'_calibration.mat']),...
    'vis_house_log','vis_face_log','vis_house','vis_face','params','log');