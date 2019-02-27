function [response] = trialGradual2AFC( num_trial, visibility )

if nargin<2
    visibility = params.visibility(num_trial);
end

global log
global params
global global_clock
global w %psychtoolbox window

% Restrat Queue
% KbQueueStart;

response = [nan nan];

Screen('DrawDots', w, [0 0]', ...
    10, [255 255 255], params.center,1);
vbl=Screen('Flip', w);

if params.house(num_trial)
    stimulus_path = fullfile('textures','houses',params.house_list(params.stimulus(num_trial)).name);
else
    stimulus_path = fullfile('textures','faces',params.face_list(params.stimulus(num_trial)).name);
end

target_size = size(imread(stimulus_path));

% load all textures in advance to avoid delays in stimulus presentation

% schedule of visibility gradient
schedule = exp(-abs((1:round(params.display_duration/params.ifi)) -...
    params.vis_peak(num_trial))/2);

if params.present(num_trial)==1 %present image in the first display
    schedule1 = schedule;
    schedule2 = zeros(size(schedule));
else
    schedule1 = zeros(size(schedule));
    schedule2 = schedule;
end

target1 = {};
target2 = {};
bg = {};

for i_frame = 1:length(schedule)
    
    target1{i_frame} = Screen('MakeTexture',w, ...
        makeStimulus(rescale(imread(stimulus_path))*255,schedule1(i_frame)*exp(visibility)));
    target2{i_frame} = Screen('MakeTexture',w, ...
        makeStimulus(rescale(imread(stimulus_path))*255,schedule2(i_frame)*exp(visibility)));
    bg{i_frame} = Screen('MakeTexture',w, ...
        rand([round(max(target_size)*1.2),round(max(target_size)*1.2),3])*255);

end

 while toc(global_clock)<params.onsets(num_trial)-0.5
        % Present a dot at the centre of the screen.
        Screen('DrawDots', w, [0 0]', ...
            10, [255 255 255], params.center,1);
        vbl=Screen('Flip', w);%initial flip

        keysPressed = queryInput();
 end

  while toc(global_clock)<params.onsets(num_trial)
        % Present a dot at the centre of the screen.
        Screen('DrawLines', w, [0 0 -10 10; -10 10 0 0],...
            4, [0,0,0], params.center, 2);  
        vbl=Screen('Flip', w);%initial flip

        keysPressed = queryInput();
 end
 
% display stimulus

tini = GetSecs;
% The onset of the stimulus is encoded in the log file as '0'.
log.events = [log.events; 0 toc(global_clock)];


%1. display first stimulus
for i_frame = 1:length(schedule)
    
    while GetSecs-tini<params.ifi*i_frame
        
        Screen('DrawTextures',w,bg{i_frame});
        Screen('DrawTextures',w,target1{i_frame});
        
        Screen('DrawLines', w, [0 0 -10 10; -10 10 0 0],...
            4, [0,0,0], params.center, 1);  

        vbl=Screen('Flip', w);
        keysPressed = queryInput();
    end
end

while GetSecs-tini<params.display_duration+0.2
    
     Screen('DrawLines', w, [0 0 -10 10; -10 10 0 0],...
            4, [0,0,0], params.center, 1);  

        vbl=Screen('Flip', w);
        keysPressed = queryInput();
        
end

%2. display second stimulus
for i_frame = 1:length(schedule)
    
    while GetSecs-tini<params.display_duration + params.ifi*i_frame
        
        Screen('DrawTextures',w,bg{i_frame});
        Screen('DrawTextures',w,target2{i_frame});
        
        Screen('DrawLines', w, [0 0 -10 10; -10 10 0 0],...
            4, [0,0,0], params.center, 1);  

        vbl=Screen('Flip', w);
        keysPressed = queryInput();
    end
end

%3. wait for response
while (GetSecs - tini)<2*params.display_duration+0.2+params.time_to_respond
            
    %During the first 200 milliseconds a fixation cross appears on
    %the screen. The subject can respond during this time.

    
    if (GetSecs - tini)<params.display_duration+0.2
       
    else
        
        Screen('DrawTexture', w, params.oneTexture, [], params.positions{1}, ...
         [],[], 0.5+0.5*(response(2)==1))
        Screen('DrawTexture', w, params.twoTexture, [], params.positions{2},...
         [],[], 0.5+0.5*(response(2)==0))
        
    end
    Screen('DrawLines', w, [0 0 -10 10; -10 10 0 0],...
        4, [0,0,0], params.center, 1);   
    
    vbl=Screen('Flip', w);
    keysPressed = queryInput();
    if keysPressed(KbName(params.keys{1}))
        response = [GetSecs-tini 1];
    elseif keysPressed(KbName(params.keys{2}))
        response = [GetSecs-tini 0];
    end
end
        
end

