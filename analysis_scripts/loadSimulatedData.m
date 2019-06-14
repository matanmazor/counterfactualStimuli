function data_struct = loadSimulatedData(modelType, numberOfDataPoints) 
%call function with argument for the modelType ('Null','Shifter','Scalar')

if nargin<1
    modelType = 'Null';
end

data_struct = containers.Map;


%load data
for i_s = 1:numberOfDataPoints
    
    subj = strcat('subj_', int2str(i_s), '_', modelType, 'Model');
    
    addpath('../simulateData');
    [params, log] = simulateModel(modelType); 
    
    %random blocks
    subject_data.RandomVisibility = [];
    subject_data.RandomDemeanVisibility = [];
    subject_data.RandomCorrect = [];
    subject_data.RandomConf = [];
    subject_data.RandomDemeanConf = [];
    subject_data.RandomResp = [];
    subject_data.RandomRT = [];
    subject_data.RandomDemeanRT = [];
    subject_data.RandomSignal = [];
    
    %structured blocks
    subject_data.StructVisibility = [];
    subject_data.StructDemeanVisibility = [];
    subject_data.StructCorrect = [];
    subject_data.StructConf = [];
    subject_data.StructDemeanConf = [];
    subject_data.StructResp = [];
    subject_data.StructRT = [];
    subject_data.StructDemeanRT = [];
    subject_data.StructSignal = [];
    
    %general parameters
    subject_data.vTask = [];
    
    log.RT = log.resp(:,2);
    log.resp = log.resp(:,1);
    
    %structured blocks
    subject_data.StructVisibility = [subject_data.StructVisibility;...
        log.visibility(1:240)];
    subject_data.StructDemeanVisibility = [subject_data.StructDemeanVisibility;...
        log.visibility(1:240) - nanmean(log.visibility(1:240))];
    subject_data.StructCorrect = [subject_data.StructCorrect;...
        log.correct(1:240)];
    subject_data.StructConf = [subject_data.StructConf;...
        log.confidence(1:240)];
    subject_data.StructDemeanConf = [subject_data.StructDemeanConf;...
        log.confidence(1:240) - nanmean(log.confidence(1:240))];
    subject_data.StructResp = [subject_data.StructResp;...
        log.resp(1:240)];
    subject_data.StructRT = [subject_data.StructRT;...
        log.RT(1:240)];
    subject_data.StructDemeanRT = [subject_data.StructDemeanRT;...
        log.RT(1:240) - nanmean(log.RT(1:240))];
    subject_data.StructSignal = [subject_data.StructSignal;...
        params.present(1:240)];
    
    %random blocks
    subject_data.RandomVisibility = [subject_data.RandomVisibility;...
        log.visibility(241:480)];
    subject_data.RandomDemeanVisibility = [subject_data.RandomDemeanVisibility;...
        log.visibility(241:480) - nanmean(log.visibility(241:480))];
    subject_data.RandomCorrect = [subject_data.RandomCorrect;...
        log.correct(241:480)];
    subject_data.RandomConf = [subject_data.RandomConf;...
        log.confidence(241:480)];
    subject_data.RandomDemeanConf = [subject_data.RandomDemeanConf;...
        log.confidence(241:480) - nanmean(log.confidence(241:480))];
    subject_data.RandomResp = [subject_data.RandomResp;...
        log.resp(241:480)];
    subject_data.RandomRT = [subject_data.RandomRT;...
        log.RT(241:480)];
    subject_data.RandomDemeanRT = [subject_data.RandomDemeanRT;...
        log.RT(241:480) - nanmean(log.RT(241:480))];
    subject_data.RandomSignal = [subject_data.RandomSignal;...
        params.present(241:480)];
    
    %compute bonus
    subject_data.bonus = ((subject_data.RandomCorrect(find(~isnan(subject_data.RandomConf)))-0.5)'...
        *subject_data.RandomConf(find(~isnan(subject_data.RandomConf)))+...
        (subject_data.StructCorrect(find(~isnan(subject_data.StructConf)))-0.5)'...
        *subject_data.StructConf(find(~isnan(subject_data.StructConf))))/100;
    
    subject_data.vTask = 'structured_structured_random_random';
    data_struct(subj)=subject_data;
    
end