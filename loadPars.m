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
params.event_duration = 7; %including stimulus presentation, decision and confidence rating
params.keys = {'a','s'};

params.conf_width_px = 200;
params.conf_height_px = 200;
params.image_size_px = [300,300];

%create fuzzy borders
ims = params.image_size_px;
[x,y] = meshgrid((1:ims(2))-ims(2)/2,(1:ims(1))-ims(1)/2);
xsd = ims(1)/2.0;
ysd = ims(2)/2.0;
fuzzy_borders = exp(-((x/xsd).^2)-((y/ysd).^2));
params.fuzzy_borders = repmat(fuzzy_borders,[1,1,3]);

[params.center(1), params.center(2)] = RectCenter(rect);
params.rect = rect;
params.yesTexture = Screen('MakeTexture', w, imread(fullfile('textures','yes.png')));
params.noTexture = Screen('MakeTexture', w, imread(fullfile('textures','no.png')));

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
    params.onsets = cumsum(params.event_duration*ones(params.Ntrials,1));
    params.vis_peak = randi([round(params.display_duration/params.ifi/4),...
    round(3*params.display_duration/params.ifi/4)],params.Ntrials,1);

elseif strfind(lower(name),'practice')
    
    params.Ntrials = 8;
    params.block_number = block_number;
    params.present = [1 1 1 0 0 1 0 0];
    %this version will only show faces during the practice block
    params.house = [0 0 0 0 0 0 0 0];
    %previous version showed both faces and houses:
    %params.house = [0 0 1 0 0 1 0 0];
    params.stimulus = 1:8;
    params.onsets = cumsum(params.event_duration*ones(params.Ntrials,1));
    params.vis_peak = randi([round(params.display_duration/params.ifi/4),...
            round(3*params.display_duration/params.ifi/4)],params.Ntrials,1);
    params.visibility = -1.3*ones(8,1);

    
else %experimental run, because a block_number has been provided
    
    params.block_number = block_number;
%     calibration = load(fullfile('data',strcat(params.name, '_calibration.mat')));
    params.vis_face = -1.9; %calibration.vis_face;
    params.vis_house = -1.3; %calibration.vis_house;
    params.Ntrials = 120;
    params.Nblocks = 4;
    
    if block_number == 1 %first block;
       params.plan = makePlan(params);
    else
       old_params = load(fullfile('data',strcat(params.name, '_block1.mat')));
       params.plan = old_params.params.plan;
    end
  
    params.present = params.plan.present(:,block_number);
    params.visibility = params.plan.visibility(:,block_number);
    params.house = params.plan.house(:,block_number);
    params.stimulus = params.plan.stimulus(:,block_number);
    params.onsets = params.plan.onsets(:,block_number);
    params.vis_peak = params.plan.vis_peak(:,block_number);
    
end