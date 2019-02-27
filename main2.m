clear all
version = '2019-02-20';

% add path to the preRNG folder, to support cryptographic time-locking of
% hypotheses and analysis plans. Can be downloaded/cloned from
% github.com/matanmazor/prerng
addpath('..\..\..\2018\preRNG\Matlab')

PsychDebugWindowConfiguration()

%{
  Matan Mazor, 2018
%}

%global variables
global log
global params
global global_clock
global w %psychtoolbox window

%name: name of subject. Should start with the subject number. The name of
%the subject should be included in the data/subjects.mat file.
%practice: 0 for no, 1 for discrimination practice, 2 for detection
%practice.
%scanning: 0 for no, 1 for yes. this parameter only affects the sensitivity
%of the inter-run staircasing procedure.
% prompt = {'Name: ', 'Practice: ', 'Scanning: '};
% dlg_title = 'Filename'; % title of the input dialog box
% num_lines = 1; % number of input lines
% default = {'999MaMa','0','0'}; % default filename
% savestr = inputdlg(prompt,dlg_title,num_lines,default);

%set preferences and open screen
Screen('Preference','SkipSyncTests', 1)
screens=Screen('Screens');
screenNumber=max(screens);
doublebuffer=1;

%The fMRI button box does not work well with KbCheck. I use KbQueue
%instead here, to get precise timings and be sensitive to all presses.
KbQueueCreate;
KbQueueStart;

%Open window.
[w, rect] = Screen('OpenWindow', screenNumber, 0,[], 32, doublebuffer+1);
Screen(w,'TextSize',40)
%Load parameters
params = loadPars(w, rect);

KbName('UnifyKeyNames');
AssertOpenGL;
PsychVideoDelayLoop('SetAbortKeys', KbName('Escape'));
HideCursor();
Priority(MaxPriority(w));

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Initialize log with NaNs where possible.
log.confidence = nan(params.trialsPerBlock,1);
log.resp = zeros(params.trialsPerBlock,2);
log.visibility = nan(params.trialsPerBlock,1);
log.correct = nan(params.trialsPerBlock,1);
log.events = [];

global_clock = tic();
%stop recording 5s from the scanner, because it seems to be too much for
%the kbcheck function.
DisableKeysForKbCheck(KbName('5%'));

%% MAIN LOOP:
for num_trial = 1:params.trialsPerBlock  
    % Restrat Queue
    KbQueueStart;
    % At the beginning of each experimental block:
    if mod(num_trial,round(params.trialsPerBlock))==1
        
        %1. Save data to file
        if ~params.practice
            save(fullfile('data', ['temp_',params.filename]),'params','log');
        end
        
        %3. Leave the instructions on the screen for 5 seconds.
        if num_trial==1
            remove_instruction_time=5;
        else
            remove_instruction_time = params.onsets(num_trial-1)+ ...
                params.fixation_time + params.display_time...
                + params.time_to_respond + params.time_to_conf+0.8+5;
        end
        
  
        %5. Present the instructions on the screen.
        while toc(global_clock)<remove_instruction_time
            
            if detection
                Screen('DrawTexture', w, params.yesTexture, [], params.positions{params.yes})
                Screen('DrawTexture', w, params.noTexture, [], params.positions{3-params.yes})
            else
                Screen('DrawTexture', w, params.vertTexture, [], params.positions{params.vertical},45)
                Screen('DrawTexture', w, params.horiTexture, [], params.positions{3-params.vertical},45)
            end
            
            DrawFormattedText(w, 'or','center','center');
            DrawFormattedText(w, '?',params.positions{2}(3)+100,'center');
            
            vbl=Screen('Flip', w);
            keysPressed = queryInput();
        end
    end
    
    % Start actual trials:
    % Generate the stimulus.
    target_xy = generate_stim(params, num_trial);
    target = Screen('MakeTexture',w, target_xy);
    
    % Save to log.
    log.Wg(num_trial) = params.vWg(num_trial)*params.Wg;
    log.direction(num_trial) = params.vDirection(num_trial);
    log.xymatrix{num_trial} = target_xy;
    log.detection(num_trial) = detection;
    

    while toc(global_clock)<params.onsets(num_trial)-0.5
        % Present a dot at the centre of the screen.
        Screen('DrawDots', w, [0 0]', ...
            params.fixation_diameter_px, [255 255 255]*0.4, params.center,1);
        vbl=Screen('Flip', w);%initial flip
   
        keysPressed = queryInput();
    end
        
    trial(target,visibility)
    
    % Write to log.
    log.resp(num_trial,:) = response;
    log.stimTime{num_trial} = vbl;
    if keysPressed(KbName('ESCAPE'))
        Screen('CloseAll');
    end
    
%     % Check if the response was accurate or not
%     if detection && ~isnan(log.resp(num_trial,2))
%         if log.resp(num_trial,2)== sign(params.vWg(num_trial))
%             log.correct(num_trial) = 1;
%         else
%             log.correct(num_trial) = 0;
%         end
%     elseif ~detection && ~isnan(log.resp(num_trial,2))
%         if log.resp(num_trial,2) == params.vDirection(num_trial)
%             log.correct(num_trial) = 1;
%         else
%             log.correct(num_trial) = 0;
%         end
%     end
    
    %% CONFIDENCE JUDGMENT
    if ~isnan(response(2))
        log.confidence(num_trial) = rateConf();
    end
end

% Wait for the run to end.
if ~params.practice
    Screen('DrawDots', w, [0 02], ...
        params.fixation_diameter_px, [255 255 255]*0.4, params.center,1);
    vbl=Screen('Flip', w);%initial flip
    
    while toc(global_clock)<params.run_duration
        keysPressed = queryInput();
    end
end

%% close
Priority(0);
ShowCursor
Screen('CloseAll');

% Make a gong sound so that I can hear from outside the testing room that
% the behavioural session is over :-)
if ~params.scanning
    load gong.mat;
    soundsc(y);
end

%% write to log

if ~params.practice
    %     answer = questdlg('Should this run be regarded as completed?');
    %     if strcmp(answer,'No')
    %         params.filename = strcat('ignore_',params.filename);
    %     end
    log.date = date;
    log.version = version;
    save(fullfile('data', params.filename),'params','log');
    if exist(fullfile('data', ['temp_',params.filename]), 'file')==2
        delete(fullfile('data', ['temp_',params.filename]));
    end
end

