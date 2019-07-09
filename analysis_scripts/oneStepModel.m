data_struct = loadData;
subj_list = data_struct.keys;
subj_list = subj_list(1)

[rand_yes_EVCcorr,struct_yes_EVCcorr, rand_no_EVCcorr, struct_no_EVCcorr] = deal(nan(size(subj_list)));

[rand_resp_EVcorr,struct_resp_EVcorr] = deal(nan(size(subj_list)));

[rand_yes_EVRTcorr,struct_yes_EVRTcorr, rand_no_EVRTcorr, struct_no_EVRTcorr] = deal(nan(size(subj_list)));

for i_s = 1:numel(subj_list)
    
    subj = subj_list{i_s};
    
    %setup variables
    
    struct_visibility = data_struct(subj).StructVisibility;
    struct_signal = data_struct(subj).StructSignal;
    struct_resp = data_struct(subj).StructResp;
    struct_expected_visibility = nan(size(struct_visibility)); %offset by 1 index to account for one-step expected values (i.e. first will be Nan)
    
    rand_visibility = data_struct(subj).RandomVisibility;
    rand_signal = data_struct(subj).RandomSignal;
    rand_resp = data_struct(subj).RandomResp;
    rand_expected_visibility = nan(size(rand_visibility)); %offset by 1 index to account for one-step expected values (i.e. first will be Nan)
    
    for i_v = 1:(numel(struct_visibility)-1)
        
        %structured condition
        
        st_vis = struct_visibility(i_v);
        st_pres = struct_signal(i_v);
        st_resp = struct_resp(i_v);
        st_currentExpVis = struct_expected_visibility(i_v);
        if i_v == 121 %2 blocks in vector and this is start of 2nd block
            struct_expected_visibility(i_v) = NaN;
        end
        if st_resp == 1 && st_pres == 1 %hit - change next expected visibility to current displayed visibility
            struct_expected_visibility(i_v+1) = st_vis;
        elseif (st_resp == 0 && st_pres == 1) || (st_resp == 0 && st_pres == 0) %miss or correct rejection - carry forward current expected visibility to next trial
            struct_expected_visibility(i_v+1) = st_currentExpVis;
        elseif st_resp == 1 && st_pres == 0 %false alarm - set next expected visibility to a very low value
            struct_expected_visibility(i_v+1) = -5;
        end
        
        %random condition
        
        ra_vis = rand_visibility(i_v);
        ra_pres = rand_signal(i_v);
        ra_resp = rand_resp(i_v);
        ra_currentExpVis = rand_expected_visibility(i_v);
        if i_v == 121 %2 blocks in vector and this is start of 2nd block
            rand_expected_visibility(i_v) = NaN;
        end
        if ra_resp == 1 && ra_pres == 1 %hit - change next expected visibility to current displayed visibility
            rand_expected_visibility(i_v+1) = ra_vis;
        elseif (ra_resp == 0 && ra_pres == 1) || (ra_resp == 0 && ra_pres == 0) %miss or correct rejection - carry forward current expected visibility to next trial
            rand_expected_visibility(i_v+1) = ra_currentExpVis;
        elseif ra_resp == 1 && ra_pres == 0 %false alarm - set next expected visibility to a very low value
            rand_expected_visibility(i_v+1) = -5;
        end
        
    end
    
    %demean the expected visibility
    
    demeaned_random_Evis = rand_expected_visibility - nanmean(rand_expected_visibility);
    demeaned_struct_Evis = struct_expected_visibility - nanmean(struct_expected_visibility);
    
    %calculate correlation between expected visibility and confidence
    
    demeaned_random_confidence = data_struct(subj).RandomDemeanConf;
    demeaned_struct_confidence = data_struct(subj).StructDemeanConf;
    
    struct_yes_EVCcorr(i_s) = nancorr(struct_expected_visibility(struct_resp==1 & data_struct(subj).StructCorrect==1),...
        demeaned_struct_confidence(struct_resp==1 & data_struct(subj).StructCorrect==1));
    struct_no_EVCcorr(i_s) = nancorr(struct_expected_visibility(struct_resp==0 & data_struct(subj).StructCorrect==1),...
        demeaned_struct_confidence(struct_resp==0 & data_struct(subj).StructCorrect==1));
    
    rand_yes_EVCcorr(i_s) = nancorr(rand_expected_visibility(rand_resp==1 & data_struct(subj).RandomCorrect==1),...
        demeaned_random_confidence(rand_resp==1 & data_struct(subj).RandomCorrect==1));
    rand_no_EVCcorr(i_s) = nancorr(rand_expected_visibility(rand_resp==0 & data_struct(subj).RandomCorrect==1),...
        demeaned_random_confidence(rand_resp==0 & data_struct(subj).RandomCorrect==1));
    
    %calculate correlation between expected visibility and response
    
    struct_resp_EVcorr(i_s) = nancorr(struct_expected_visibility, struct_resp);
    rand_resp_EVcorr(i_s) = nancorr(rand_expected_visibility, rand_resp);
    
    %calculate correlation between expected visibility and log RT
    
    struct_yes_EVRTcorr(i_s) = nancorr(struct_expected_visibility(struct_resp==1 & data_struct(subj).StructCorrect==1),...
        data_struct(subj).StructRT(struct_resp==1 & data_struct(subj).StructCorrect==1));
    struct_no_EVRTcorr(i_s) = nancorr(struct_expected_visibility(struct_resp==0 & data_struct(subj).StructCorrect==1),...
        data_struct(subj).StructRT(struct_resp==0 & data_struct(subj).StructCorrect==1));
    
    rand_yes_EVRTcorr(i_s) = nancorr(rand_expected_visibility(rand_resp==1 & data_struct(subj).RandomCorrect==1),...
        data_struct(subj).RandomRT(rand_resp==1 & data_struct(subj).RandomCorrect==1));
    rand_no_EVRTcorr(i_s) = nancorr(rand_expected_visibility(rand_resp==0 & data_struct(subj).RandomCorrect==1),...
        data_struct(subj).RandomRT(rand_resp==0 & data_struct(subj).RandomCorrect==1));
    
end
figure; hold on;
plot([rand_yes_EVCcorr;rand_no_EVCcorr;struct_yes_EVCcorr;struct_no_EVCcorr],'k');
scatter(ones(length(subj_list),1),rand_yes_EVCcorr,[],'MarkerEdgeColor','k','MarkerFaceColor',cb(2,:),'LineWidth',1);
scatter(2*ones(length(subj_list),1),rand_no_EVCcorr,[],'MarkerEdgeColor','k','MarkerFaceColor',cb(1,:),'LineWidth',1);
scatter(3*ones(length(subj_list),1),struct_yes_EVCcorr,[], 'd','MarkerEdgeColor','k','MarkerFaceColor',cb(2,:),'LineWidth',1);
scatter(4*ones(length(subj_list),1),struct_no_EVCcorr,[], 'd','MarkerEdgeColor','k','MarkerFaceColor',cb(1,:),'LineWidth',1);
ylabel('r(confidence,E(visibility))');
xlim([0,5]); xlabel('condition');
set(gca,'xtick',[1:4],'xticklabel',{'random yes','random no','structured yes','structured no'})
fig = gcf;
fig.PaperUnits = 'inches';