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

%% 4. run calibration

global_clock = tic();

for num_trial = 1:params.Ntrials
  
 
    response = trialGradual2AFC(num_trial);
    
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

%% 5. extract psychometric curve

addpath('PsychometricCurveFitting')
%can be downloaded from: https://github.com/garethjns/PsychometricCurveFitting
%code by Gareth Jones 

x = -5:0.35:-1.6;

for i_v = 1:length(x)
    face_y(i_v) = 2*mean(log.correct(params.visibility==x(i_v) ...
        & params.house==0))-1;
    house_y(i_v) = 2*mean(log.correct(params.visibility==x(i_v) ...
        & params.house==1))-1;
end

[face_coeffs, face_curve, ~] = ...
    fitPsyche.fitPsycheCurveLogit(x, face_y);

[~,face_upper_index] = min(abs(face_curve(:,2)-2*(accYN2accAFC(0.8)-0.5)));
face_upper = face_curve(face_upper_index,1);

[~,face_lower_index] = min(abs(face_curve(:,2)-2*(accYN2accAFC(0.6)-0.5)));
face_lower = face_curve(face_lower_index,1);

[house_coeffs, house_curve, ~] = ...
    fitPsyche.fitPsycheCurveLogit(x, house_y);

[~,house_upper_index] = min(abs(house_curve(:,2)-2*(accYN2accAFC(0.8)-0.5)));
house_upper = house_curve(house_upper_index,1);

[~,house_lower_index] = min(abs(house_curve(:,2)-2*(accYN2accAFC(0.6)-0.5)));
house_lower = house_curve(house_lower_index,1);

save(fullfile('data',[params.name,'_calibration.mat']),...
    'house_lower','face_lower','house_upper','face_upper','params','log');