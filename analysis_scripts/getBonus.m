function bonus = getBonus()
% get the value of the bonus for the last participant

data_struct = loadData;
full_subj_list = data_struct.keys;
subj_list = full_subj_list(end);
subj = subj_list{1};

bonus = (data_struct(subj).bonus)/2.5;

end