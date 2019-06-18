function bonus = getTotalBonus()
% get the total value of the bonus for the last participant

data_struct = loadData;
full_subj_list = data_struct.keys;
subj_list = full_subj_list(end);
subj = subj_list{1} %display participant code
randAccuracy = nanmean(data_struct(subj).RandomCorrect);
structAccuracy = nanmean(data_struct(subj).StructCorrect);
accuracy = (randAccuracy + structAccuracy)/2 %display overall accuracy

bonus = (data_struct(subj).bonus)/3.3;

end