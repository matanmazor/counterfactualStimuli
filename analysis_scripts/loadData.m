function data_struct = loadData()
% load data from all participants and arrange in a dictionary

data_struct = containers.Map;

% load subject list
subj_list = {};
files = dir(fullfile('..','data'));

for i_f = 1:numel(files)
    if regexp(files(i_f).name,'block4')
        subj_list{end+1} = files(i_f).name(1:7);
    end
end

%load data
for i_s = 1:length(subj_list)
    subj = subj_list{i_s};
        subj_files = dir(fullfile('..','data',[subj,'_block*.mat']));
        if ~isempty(subj_files)
            
            subject_data.isRandomFirst = [];
            
            %random blocks
            subject_data.RandomVisibility = [];
            subject_data.RandomDemeanVisibility = [];
            subject_data.RandomHouse = [];
            subject_data.RandomCorrect = [];
            subject_data.RandomConf = [];
            subject_data.RandomDemeanConf = [];
            subject_data.RandomConfInc = []; %increase confidence presses
            subject_data.RandomConfDec = []; %decrease confidence presses         
            subject_data.RandomResp = [];
            subject_data.RandomRT = [];
            subject_data.RandomDemeanRT = [];
            subject_data.RandomSignal = [];
            subject_data.RandomDemeanEV = [];
            subject_data.RandomDemeanEVres = [];
            

            %structured blocks
            subject_data.StructVisibility = [];
            subject_data.StructDemeanVisibility = [];
            subject_data.StructHouse = [];
            subject_data.StructCorrect = [];
            subject_data.StructConf = [];
            subject_data.StructDemeanConf = [];
            subject_data.StructConfInc = []; %increase confidence presses
            subject_data.StructConfDec = []; %decrease confidence presses         
            subject_data.StructResp = [];
            subject_data.StructRT = [];
            subject_data.StructDemeanRT = [];
            subject_data.StructSignal = [];
            subject_data.StructDemeanEV = [];
            subject_data.StructDemeanEVres = [];

            %general parameters
            subject_data.vTask = [];
            
            for j = 1:length(subj_files)
                load(fullfile('..','data',subj_files(j).name));

                % is this a random or a structured block?
                is_random = (params.block_number<3 & params.plan.random_first)...
                    | (params.block_number>2 & ~params.plan.random_first);
                
                %fix log.events so that it counts once each press
                diff_mat = diff(log.events);
                good_trials = find(diff_mat(:,2)>0.05 | diff_mat(:,1)~=0);
                log.events = log.events(good_trials,:);
                
                trial_events = find(log.events(:,1)==0);
                trial_events(121) = length(log.events)+1;
                [up_count, down_count] = deal(nan(120,1));
                for i_t = 1:120
                    up_count(i_t) = sum(abs(...
                        log.events(trial_events(i_t):trial_events(i_t+1)-1,1)-38)<eps);
                    down_count(i_t) = sum(abs(...
                        log.events(trial_events(i_t):trial_events(i_t+1)-1,1)-40)<eps);
                end
                
                if j==1
                    subject_data.isRandomFirst = [subject_data.isRandomFirst;...
                        params.plan.random_first];
                end
                
                if is_random
                    %random blocks
                    subject_data.RandomVisibility = [subject_data.RandomVisibility;...
                        params.visibility];
                    subject_data.RandomDemeanVisibility = [subject_data.RandomDemeanVisibility;...
                        params.visibility - nanmean(params.visibility)];
                    subject_data.RandomHouse = [subject_data.RandomHouse;...
                        params.house];
                    subject_data.RandomCorrect = [subject_data.RandomCorrect;...
                        log.correct];
                    subject_data.RandomConf = [subject_data.RandomConf;...
                        log.confidence];
                    subject_data.RandomDemeanConf = [subject_data.RandomDemeanConf;...
                        log.confidence - nanmean(log.confidence)];
                    subject_data.RandomConfInc = [subject_data.RandomConfInc;...
                        up_count]; %increase confidence presses
                    subject_data.RandomConfDec = [subject_data.RandomConfDec;...
                        down_count]; %decrease confidence presses         
                    subject_data.RandomResp = [subject_data.RandomResp;...
                        log.resp(:,2)];
                    subject_data.RandomRT = [subject_data.RandomRT;...
                        log2(log.resp(:,1))];
                    subject_data.RandomDemeanRT = [subject_data.RandomDemeanRT;...
                        log2(log.resp(:,1)) - nanmean(log2(log.resp(:,1)))];
                    subject_data.RandomSignal = [subject_data.RandomSignal;...
                        params.present];
                    [EV_vec,EVres_vec] = getExpectedVisbility(params.visibility,params.present,log.resp(:,2));
                    subject_data.RandomDemeanEV = [subject_data.RandomDemeanEV; EV_vec];
                    subject_data.RandomDemeanEVres = [subject_data.RandomDemeanEVres; EVres_vec];
                else
                    %structured blocks
                    subject_data.StructVisibility = [subject_data.StructVisibility;...
                        params.visibility];
                    subject_data.StructDemeanVisibility = [subject_data.StructDemeanVisibility;...
                        params.visibility - nanmean(params.visibility)];
                    subject_data.StructHouse = [subject_data.StructHouse;...
                        params.house];
                    subject_data.StructCorrect = [subject_data.StructCorrect;...
                        log.correct];
                    subject_data.StructConf = [subject_data.StructConf;...
                        log.confidence];
                    subject_data.StructDemeanConf = [subject_data.StructDemeanConf;...
                        log.confidence - nanmean(log.confidence)];
                    subject_data.StructConfInc = [subject_data.StructConfInc;...
                        up_count]; %increase confidence presses
                    subject_data.StructConfDec = [subject_data.StructConfDec;...
                        down_count]; %decrease confidence presses         
                    subject_data.StructResp = [subject_data.StructResp;...
                        log.resp(:,2)];
                    subject_data.StructRT = [subject_data.StructRT;...
                        log2(log.resp(:,1))];
                    subject_data.StructDemeanRT = [subject_data.StructDemeanRT;...
                        log2(log.resp(:,1)) - nanmean(log2(log.resp(:,1)))];
                    subject_data.StructSignal = [subject_data.StructSignal;...
                        params.present];
                    [EV_vec,EVres_vec] = getExpectedVisbility(params.visibility,params.present,log.resp(:,2));
                    subject_data.StructDemeanEV = [subject_data.StructDemeanEV; EV_vec];
                    subject_data.StructDemeanEVres = [subject_data.StructDemeanEVres; EVres_vec];
                end
                
                %compute bonus
                subject_data.bonus = ((subject_data.RandomCorrect(find(~isnan(subject_data.RandomConf)))-0.5)'...
                    *subject_data.RandomConf(find(~isnan(subject_data.RandomConf)))+...
                (subject_data.StructCorrect(find(~isnan(subject_data.StructConf)))-0.5)'...
                *subject_data.StructConf(find(~isnan(subject_data.StructConf))))/100;
                
            end
            if params.plan.random_first
                subject_data.vTask = 'random_random_structured_structured';
            else
                subject_data.vTask = 'structured_structured_random_random';
            end
            
            data_struct(subj)=subject_data;
            
        end
end

