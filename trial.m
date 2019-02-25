function [response] = trial( num_trial )

global log
global params
global global_clock
global w %psychtoolbox window

% Restrat Queue
KbQueueStart;

response = [nan nan];
if params.house(num_trial)
    stimulus_path = fullfile('textures','houses',params.house_list(params.stimulus(num_trial)).name);
else
    stimulus_path = fullfile('textures','faces',params.face_list(params.stimulus(num_trial)).name);
end

target = Screen('MakeTexture',w, ...
    makeStimulus(rescale(imread(stimulus_path))*255,exp(params.visibility(num_trial))));
target_size = size(imread(stimulus_path));

%1. display a fixation cross on the screen
while toc(global_clock)<params.onsets(num_trial)
    % Present the fixation cross.
    bg = Screen('MakeTexture',w, rand([round(max(target_size)*1.2),round(max(target_size)*1.2),3])*255);
    Screen('DrawTextures',w,bg);
    
    Screen('DrawLines', w, [0 0 -10 10; -10 10 0 0],...
        4, [0,0,0], params.center, 2);  

    vbl=Screen('Flip', w);
    keysPressed = queryInput();
end

%2. present the stimulus.
tini = GetSecs;
% The onset of the stimulus is encoded in the log file as '0'.
log.events = [log.events; 0 toc(global_clock)];


 
while (GetSecs - tini)<params.display_time
    
    bg = Screen('MakeTexture',w, rand([round(max(target_size)*1.2),round(max(target_size)*1.2),3])*255);
    Screen('DrawTextures',w,bg);

    if params.present(num_trial)%set alpha to e^vis
        Screen('DrawTextures',w,target)%, [], [], [], [],exp(params.visibility(num_trial)));
    end
    Screen('DrawLines', w, [0 0 -10 10; -10 10 0 0],...
        4, [0,0,0], params.center, 2);       vbl=Screen('Flip', w);
    keysPressed = queryInput();
end

%3. wait for response
while (GetSecs - tini)<params.display_time+params.time_to_respond
            
    %During the first 200 milliseconds a fixation cross appears on
    %the screen. The subject can respond during this time.

    
    if (GetSecs - tini)<params.display_time+0.2

       bg = Screen('MakeTexture',w, rand([round(max(target_size)*1.2),round(max(target_size)*1.2),3])*255);
       Screen('DrawTextures',w,bg);
       
    else
        
        Screen('DrawTexture', w, params.yesTexture, [], params.positions{1}, ...
         [],[], 0.5+0.5*(response(2)==1))
        Screen('DrawTexture', w, params.noTexture, [], params.positions{2},...
         [],[], 0.5+0.5*(response(2)==0))
        
    end
    Screen('DrawLines', w, [0 0 -10 10; -10 10 0 0],...
        4, [0,0,0], params.center, 2);   
    
    vbl=Screen('Flip', w);
    keysPressed = queryInput();
    if keysPressed(KbName(params.keys{1}))
        response = [GetSecs-tini 1];
    elseif keysPressed(KbName(params.keys{2}))
        response = [GetSecs-tini 0];
    end
end
        
end

