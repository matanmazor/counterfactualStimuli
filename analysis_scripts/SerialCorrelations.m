%Serial correlations
Struct_Coeffs = [];
Rand_Coeffs = [];

Struct_corr = [];
Rand_corr = [];

for s=1:length(subj_list) %run over subjects
    
    subject = data_struct(subj_list{s});
    
    StructRespMat = [];
    RandRespMat = [];
    
    StructSigMat = [];
    RandSigMat = [];
    
    StructRespBlock1 = subject.StructResp(1:119); %responses for structured
    StructRespBlock2 = subject.StructResp(121:239); %responses for structured
    RandRespBlock1 = subject.RandomResp(1:119); %responses for random
    RandRespBlock2 = subject.RandomResp(121:239); %responses for random
    
    StructSigBlock1 = subject.StructSignal(2:120); %signal for structured
    StructSigBlock2 = subject.StructSignal(122:240); %signal for structured
    RandSigBlock1 = subject.RandomSignal(2:120); %signal for random
    RandSigBlock2 = subject.RandomSignal(122:240); %signal for random
    
    StructVisBlock1 = nanzscore(subject.StructDemeanVisibility(2:120));
    StructVisBlock2 = nanzscore(subject.StructDemeanVisibility(122:240));
    RandVisBlock1 = nanzscore(subject.RandomDemeanVisibility(2:120));
    RandVisBlock2 = nanzscore(subject.RandomDemeanVisibility(122:240));
    
    StructExpVisBlock1 = nanzscore(demeaned_struct_Evis(2:120));
    StructExpVisBlock2 = nanzscore(demeaned_struct_Evis(122:240));
    RandExpVisBlock1 = nanzscore(demeaned_random_Evis(2:120));
    RandExpVisBlock2 = nanzscore(demeaned_random_Evis(122:240));
    
    StructDesignMatrix = [[StructRespBlock1;StructRespBlock1],[StructSigBlock1;StructSigBlock2],...
        [StructVisBlock1;StructVisBlock2],[StructExpVisBlock1;StructExpVisBlock2]];
    RandDesignMatrix = [[RandRespBlock1;RandRespBlock2],[RandSigBlock1;RandSigBlock2],...
        [RandVisBlock1;RandVisBlock2],[RandExpVisBlock1;RandExpVisBlock2]];
    
    toPredictStruct = [subject.StructResp(2:120);subject.StructResp(122:240)]; % what I want to predict is the last response at t
    toPredictStruct(toPredictStruct==0)=2; %the second category is used as reference by mnrfit
    Struct_B = mnrfit(StructDesignMatrix, toPredictStruct); %fit a logistic regression model
    
    toPredictRand = [subject.RandomResp(2:120);subject.RandomResp(122:240)];
    toPredictRand(toPredictRand==0)=2; %the second category is used as reference by mnrfit
    Rand_B = mnrfit(RandDesignMatrix, toPredictRand); %fit a logistic regression model
    
    Struct_Coeffs = [Struct_Coeffs Struct_B(2:length(Struct_B))]; % add only the slope betas and not the bias
    Rand_Coeffs = [Rand_Coeffs Rand_B(2:length(Struct_B))]; % add only the slope betas and not the bias
    %{
    Struct_corr = cat(3, Struct_corr, corr(StructDesignMatrix(~any(isnan(StructDesignMatrix),2),:))); %compute correlations
    Rand_corr = cat(3, Rand_corr, corr(RandDesignMatrix(~any(isnan(RandDesignMatrix),2),:)));  %compute correlations
    %}
end
%{
Struct_corr_vec = squeeze(Struct_corr(5:-1:1,6,:))';
Rand_corr_vec = squeeze(Rand_corr(5:-1:1,6,:))';
figure
hold on
mseb(1:5, [mean(Struct_corr_vec);mean(Rand_corr_vec)] ,...
    [std(Struct_corr_vec); std(Rand_corr_vec)]/sqrt(length(subj_list))*2, lineProps);
legend('structured','random')
plot([1,5],[0,0],'--k');
xlabel('lag');
ylabel('correlation')
%}
figure
hold on
mseb(1:4, [mean(Struct_Coeffs');mean(Rand_Coeffs')],...
    [std(Struct_Coeffs'); std(Rand_Coeffs')]/sqrt(length(subj_list)), lineProps);
legend('structured','random')
plot([1,4],[0,0],'--k');
set(gca,'xtick',[1:4],'xticklabel',{'response', 'signal', 'visibility', 'expectedVisibility'})
xlabel('predictor');
ylabel('weight')
% check overall difference in dependency temporal window:
Struct_window = [];
Rand_window = [];
Struct_height = [];
Rand_height = [];
for s = 1:length(subj_list)
    Struct_window(s) = find([Struct_Coeffs(:,s); 0]<=0,1);
    Rand_window(s) = find([Rand_Coeffs(:,s); 0]<=0,1);
    Struct_height(s) = mean(Struct_Coeffs(1:Struct_window(s)-1,s));
    Rand_height(s) = mean(Rand_Coeffs(1:Struct_window(s)-1,s));

end

%{
%3.1 Alternating and sustained effects of previous trials

alternating_regressor = [-1 1 -1 1 -1 1 -1];
sustained_regressor = 3:-1:-3;
predictors = [ones(7,1), alternating_regressor', sustained_regressor'];
trends_Struct = [];
trends_Rand = [];

for i_s = 1:length(subj_list)
    trends_Struct(:, i_s) = regress(Struct_Coeffs(:,i_s), predictors);
    trends_Rand(:, i_s) = regress(Rand_Coeffs(:,i_s), predictors);
end
%}