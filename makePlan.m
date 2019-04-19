function plan  = makePlan(params)
%makePlan: make a plan for the four experimental blocks.

if mod(params.Nblocks,2) ~= 0
    error(sprintf('%d isn not an even number of blocks',params.Nblocsk))
else
    Nb = params.Nblocks;
    Nt = params.Ntrials;
end

%should the random or the structured blocks take place first?
plan.random_first = 0; 
if binornd(1,0.5)
    plan.random_first = 1;
end

%start with creating the structured blocks

first_trials_present = [1 1 0 0 1 0 1 0]';
%this version of the experiment will only show faces (i.e. 0s for houses)
first_trials_house = [0 0 0 0 0 0 0 0]';
%original first trial structure mixed faces and houses:
%first_trials_house = [1 0 0 1 0 1 1 1]';

structured.present = nan(Nt,Nb/2);
structured.house = nan(Nt,Nb/2);


for i_b = 1:Nb/2
    
    structured.present(1:Nt-8,i_b) = [ones((Nt-8)/2,1); zeros((Nt-8)/2,1)];
    %first eight trials are always house,face, noise, noise, face, noise,
    %house, noise. Only in structured blocks!
    structured.present(:,i_b) = [first_trials_present;...
        structured.present(randperm(Nt-8),i_b)];
    
    %remove houses by changing ones to zeros
    structured.house(1:Nt-8,i_b) = [zeros((Nt-8)/2,1); zeros((Nt-8)/2,1)];
    %structured.house(1:Nt-8,i_b) = [ones((Nt-8)/2,1); zeros((Nt-8)/2,1)];
    structured.house(:,i_b) = [first_trials_house;...
        structured.house(randperm((Nt-8)),i_b)];
   
    structured.visibility(:,i_b) = createContrastSchedule(Nt,0.05)+...
        params.vis_face+structured.house(:,i_b)*(params.vis_house-params.vis_face);
    
    structured.vis_peak(:,i_b) = randi([round(params.display_duration/params.ifi/4),...
        round(3*params.display_duration/params.ifi/4)],Nt,1);

end

%now for the random ones:
for i_b = 1:Nb/2
    
    perm = randperm(Nt);
    
    random.present(:,i_b) = structured.present(perm,i_b);
    
    random.house(:,i_b) = structured.house(perm,i_b);
    
    random.visibility(:,i_b) = structured.visibility(perm,i_b);
    
    random.vis_peak(:,i_b) = structured.vis_peak(perm,i_b);

end

%merge:
if plan.random_first
    
    plan.present = [random.present structured.present];
    
    plan.house = [random.house structured.house];
    
    plan.visibility = [random.visibility structured.visibility];
    
    plan.vis_peak = [random.vis_peak structured.vis_peak];
    
else
    
    plan.present = [structured.present random.present];
    
    plan.house = [structured.house random.house];
    
    plan.visibility = [structured.visibility random.visibility];
    
    plan.vis_peak = [structured.vis_peak random.vis_peak];
end

%additional elements:

for i_b = 1:Nb
    
    plan.stimulus(:,i_b) = randi([1,min(numel(params.house_list),...
        numel(params.face_list))], Nt,1);
    
    plan.onsets(:,i_b) = cumsum(params.event_duration*ones(params.Ntrials,1));
    
end