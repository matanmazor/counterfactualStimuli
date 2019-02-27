function params = loadPars(rect, name, block_number)
% load parameters for the counterfactual stimuli experiment. for
% calibration, leave block_number blank. if name == practice, run 4
% practice trials.

global w

 %% general visual and timing parameters
 
 params.display_duration = 1;
params.ifi = 1/30;
params.time_to_respond = 1.5;
params.time_to_conf = 2.5;

params.keys = {'j','k'};

params.conf_width_px = 200;
params.conf_height_px = 200;

[params.center(1), params.center(2)] = RectCenter(rect);
params.rect = rect;
params.yesTexture = Screen('MakeTexture', w, imread(fullfile('textures','yes.png')));
params.noTexture = Screen('MakeTexture', w, imread(fullfile('textures','no.png')));

params.oneTexture = Screen('MakeTexture', w, imread(fullfile('textures','1.png')));
params.twoTexture = Screen('MakeTexture', w, imread(fullfile('textures','2.png')));

params.positions = {[params.center(1)-250, params.center(2)-50,...
                            params.center(1)-150, params.center(2)+50],...
             [params.center(1)+150, params.center(2)-50,...
                            params.center(1)+250, params.center(2)+50]};
                        
%% other general parameters                       
params.name = name;
[params.house_list, params.face_list] = extractTextureLists( );

if nargin<3 %calibration, because no block_number has been provided
    
    params.Ntrials = 120;
    params.present = binornd(1,0.5,params.Ntrials,1);
    house = repmat([1,0]',params.Ntrials/2,1);
    permutation = randperm(params.Ntrials);
    params.house = house(permutation);
    params.stimulus = ...
        randi([1,min(numel(params.house_list),numel(params.face_list))],...
        params.Ntrials,1);
    params.onsets = cumsum(5.5*ones(params.Ntrials,1))-3;
    params.vis_peak = randi([round(params.display_duration/params.ifi/4),...
    round(3*params.display_duration/params.ifi/4)],params.Ntrials,1);

else %experimental run, because a block_number has been provided
    
    params.block_number = block_number;
    calibration = load(fullfile('data',strcat(params.name, '_calibration.mat')));
    params.vis_face = calibration.vis_face;
    params.vis_house = calibration.vis_house;
    params.Ntrials = 150;
    params.Nblocks = 4;
    
    if block_number == 1 %first block;
       params.plan = makePlan(params);
    else
       old_params = load(fullfile('data',strcat(params.name, '_block1.mat')));
       params.plan = old_params.plan;
    end
  
    params.present = params.plan.present(:,block_number);
    params.visibility = params.plan.visibility(:,block_number);
    params.house = params.plan.house(:,block_number);
    params.stimulus = params.plan.stimulus(:,block_number);
    params.onsets = params.plan.onsets(:,block_number);
    params.vis_peak = params.plan.vis_peak(:,block_number);
    
    params.present = [binornd(1,0.5,10,1); params.present];
    params.visibility = [linspace(-1,params.visibility(1),10)'; params.visibility];
    params.house = [binornd(1,0.5,10,1); params.house];
    params.stimulus = [randi(max(params.stimulus),10,1); params.stimulus];
    params.onsets = [cumsum(4*ones(10,1)); 40+params.onsets];
    params.vis_peak = [randi([round(params.display_duration/params.ifi/4),...
        round(3*params.display_duration/params.ifi/4)],10,1);params.vis_peak];
    
end