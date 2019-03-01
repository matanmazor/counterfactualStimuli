function [response] = trialGradual( num_trial, visibility )

global log
global params
global global_clock
global w %psychtoolbox window


if nargin<2
    visibility = params.visibility(num_trial);
end

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

if params.present(num_trial)==0 %noise trial
    schedule = zeros(size(schedule));
end

target = {};
bg = {};

fprintf('entered trialGradual %f\n',toc(global_clock))
for i_frame = 1:length(schedule)
    
    target{i_frame} = Screen('MakeTexture',w, ...
        makeStimulus(rescale(imread(stimulus_path))*255,schedule(i_frame)*exp(visibility)));
    bg{i_frame} = Screen('MakeTexture',w, ...
        rand([round(max(target_size)*1.2),round(max(target_size)*1.2),3])*255);

end
fprintf('started trialGradual %f\n',toc(global_clock))

 while toc(global_clock)<params.onsets(num_trial)-0.5
        % Present a dot at the centre of the screen.
        Screen('DrawDots', w, [0 0]', ...
            10, [255 255 255], params.center,1);
        vbl=Screen('Flip', w);%initial flip

        keysPressed = queryInput();
 end
fprintf('trial onset-0.5 %f\n',toc(global_clock))

  while toc(global_clock)<params.onsets(num_trial)
        % Present a dot at the centre of the screen.
        Screen('DrawLines', w, [0 0 -10 10; -10 10 0 0],...
            4, [0,0,0], params.center, 1);  
        vbl=Screen('Flip', w);%initial flip

        keysPressed = queryInput();
  end

fprintf('trial onset %f\n',toc(global_clock))
tini = GetSecs;
% The onset of the stimulus is encoded in the log file as '0'.
log.events = [log.events; 0 toc(global_clock)];

% display stimulus




%1. display first stimulus
for i_frame = 1:length(schedule)
    
    while GetSecs-tini<params.ifi*i_frame
        
        Screen('DrawTextures',w,bg{i_frame});
        Screen('DrawTextures',w,target{i_frame});
        
        Screen('DrawLines', w, [0 0 -10 10; -10 10 0 0],...
            4, [0,0,0], params.center, 1);  

        vbl=Screen('Flip', w);
        keysPressed = queryInput();
    end
end



%2. wait for response
while (GetSecs - tini)<params.display_duration+params.time_to_respond
            
    %During the first 200 milliseconds a fixation cross appears on
    %the screen. The subject can respond during this time.

    
    if (GetSecs - tini)<params.display_duration+0.2
       
    else
        
        Screen('DrawTexture', w, params.yesTexture, [], params.positions{1}, ...
         [],[], 0.5+0.5*(response(2)==1))
        Screen('DrawTexture', w, params.noTexture, [], params.positions{2},...
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
   
%close all textures to free memory
for i_frame = 1:length(schedule)
    Screen('Close', target{i_frame}); 
    Screen('Close', bg{i_frame}); 
end

end

