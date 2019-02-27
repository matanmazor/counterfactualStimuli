function [rating]= rateConf()
% RATECONF rate confidence by controlling the size and color of a circle.
% Matan Mazor, 2018

global params
global w

increase_key =KbName('q');
decrease_key = KbName('a');

timer = tic();

% initial confidence rating is determined randomly
rating = randperm(6,1);
new_rating = rating;
while toc(timer)<params.time_to_conf
  
    % draw scale
    Screen('DrawLine', w ,[255,255,255], params.center(1),...
        params.center(2)-200, params.center(1),  params.center(2)+200 ,2);
    for i_t=1:6
        tic_height = params.center(2)-200+(i_t-1)*400/5;
        Screen('DrawLine', w ,[255,255,255], params.center(1)-2,...
        tic_height, params.center(1)+2,  tic_height ,1);
    end
    
    %draw dot
    Screen('DrawDots', w, [0 200-(rating-1)*80]', ...
    10, [255 255 255], params.center,1);

    vbl=Screen('Flip', w);
    
    keysPressed = queryInput();
    
    if keysPressed(decrease_key)
        new_rating=max(1,rating-1);
    elseif keysPressed(increase_key)
        new_rating=min(6,rating+1);
    elseif ~keysPressed %update rating only when key is released
        rating = new_rating;
    end
end

% present the chosen confidence for 100 milliseconds
while toc(timer)<params.time_to_conf+0.1
    
    keysPressed = queryInput();
    
end