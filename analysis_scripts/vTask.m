vTaskList = [];
for s=1:length(subj_list); %run over subjects
subject = data_struct(subj_list{s});
vTaskList = [vTaskList; subject.vTask];
end
vTaskList