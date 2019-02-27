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
    plan.random_first = 0;
end

%start with creating the structured blocks
for i_b = 1:Nb/2
    
    structured.present(:,i_b) = [ones(Nt/2,1); zeros(Nt/2,1)];
    structured.present(:,i_b) = structured.present(randperm(Nt),i_b);
    
    structured.house(:,i_b) = [ones(Nt/2,1); zeros(Nt/2,1)];
    structured.house(:,i_b) = structured.house(randperm(Nt),i_b);
    
%     structured.visibility(:,i_b) = ...
%         createContrastSchedule( Nt, 20, [params.vis_face-0.2,params.vis_face,params.vis_face+0.2], 0.05 )+...
%         structured.house(:,i_b)*(params.vis_house-params.vis_face);

    structured.visibility(:,i_b) = createContrastSchedule(Nt,0.05)+params.vis_face+...
        structured.house(:,i_b)*(params.vis_house-params.vis_face);
    
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