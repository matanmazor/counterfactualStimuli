function bonus = getBonusOG()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% load data from all participants and arrange in a dictionary
data_struct = containers.Map;

% load subject list
subj_list = {}
files = dir(fullfile('..','data'))
subj_list{end+1} = files(end).name(1:7)
subj = subj_list{1}
subj_files = dir(fullfile('..','data',[subj,'_block*.mat']))


if ~isempty(subj_files)

    subject_data.RandomCorrect = [];
    subject_data.RandomConf = [];
    subject_data.StructConf = [];
    subject_data.StructCorrect = [];
    subject_data.bonus = [];


    for j = 1:length(subj_files)
        load(fullfile('..','data',subj_files(j).name))

        % is this a random or a structured block?
        is_random = (params.block_number<3 & params.plan.random_first)...
            | (params.block_number>2 & ~params.plan.random_first)

        % get relevant information

        if is_random
            subject_data.RandomCorrect = [subject_data.RandomCorrect;...
                log.correct]
            subject_data.RandomConf = [subject_data.RandomConf;...
                log.confidence]
        else
            subject_data.StructCorrect = [subject_data.StructCorrect;...
                log.correct]
            subject_data.StructConf = [subject_data.StructConf;...
                log.confidence]
        end

        % calculate bonus
        subject_data.bonus = [subject_data.bonus; ((subject_data.RandomCorrect(find(~isnan(subject_data.RandomConf)))-0.5)'...
            *subject_data.RandomConf(find(~isnan(subject_data.RandomConf)))+...
        (subject_data.StructCorrect(find(~isnan(subject_data.StructConf)))-0.5)'...
        *subject_data.StructConf(find(~isnan(subject_data.StructConf))))/100]

    end

data_struct(subj_list{1}) = subject_data
end
end

