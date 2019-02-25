%counterfactual stimuli experiment. 

clear all
version = '2019-02-20';

global log
global params
global global_clock
global w %psychtoolbox window

%% 1. ask for name and block number
prompt = {'Name: ','Block number:'};
dlg_title = 'Filename'; % title of the input dialog box
num_lines = 1; % number of input lines
default = {'42KaFr','0'}; % default filename
savestr = inputdlg(prompt,dlg_title,num_lines,default);
name = savestr{1};
block_number = str2double(savestr{2});

%% 2. set preferences and open screen

% change to w = setWindow(1) for debugging mode.
[w,rect] = setWindow(0); %open psychtoolbox. 
params = loadPars(rect, name, block_number);
        
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
  
    response = trialGradual(num_trial);
    
    log.resp(num_trial,:) = response;
    log.correct(num_trial) = log.resp(num_trial,2)==params.present(num_trial);
    
end

% close
Priority(0);
ShowCursor
Screen('CloseAll');

% Make a gong sound so that I can hear from outside the testing room that
% the behavioural session is over :-)
load gong.mat;
soundsc(y);

