%Response Conditional ROCs
%{
[StructSignalYesGroup, StructSignalNoGroup, StructNoiseYesGroup, StructNoiseNoGroup] = deal([]);
[RandSignalYesGroup, RandSignalNoGroup, RandNoiseYesGroup, RandNoiseNoGroup] = deal([]);
[nR_StructSignal,nR_StructNoise,nR_RandSignal,nR_RandNoise] = deal([]);

for s=1:length(subj_list)
    
    subject = data_struct([subj_list{s}]);
    
    
    %break into taskXsignalXresponse
    StructSignalYes = histc(subject.StructConf(subject.StructSignal==1 & subject.StructResp==1),1:6);
    StructSignalNo = histc(subject.StructConf(subject.StructSignal==1 & subject.StructResp==0),1:6);
    StructNoiseYes = histc(subject.StructConf(subject.StructSignal==0 & subject.StructResp==1),1:6);
    StructNoiseNo = histc(subject.StructConf(subject.StructSignal==0 & subject.StructResp==0),1:6);
    
    RandSignalYes = histc(subject.RandomConf(subject.RandomSignal==1 & subject.RandomResp==1),1:6);
    RandSignalNo = histc(subject.RandomConf(subject.RandomSignal==1 & subject.RandomResp==0),1:6);
    RandNoiseYes = histc(subject.RandomConf(subject.RandomSignal==0 & subject.RandomResp==1),1:6);
    RandNoiseNo = histc(subject.RandomConf(subject.RandomSignal==0 & subject.RandomResp==0),1:6);
    
    nR_StructSignal(s,:) = [reshape(StructSignalNo(end:-1:1),1,[]) reshape(StructSignalYes,1,[])];
    nR_StructNoise(s,:) = [reshape(StructNoiseNo(end:-1:1),1,[]) reshape(StructNoiseYes,1,[])];
    nR_RandSignal(s,:) = [reshape(RandSignalNo(end:-1:1),1,[]) reshape(RandSignalYes,1,[])];
    nR_RandNoise(s,:) = [reshape(RandNoiseNo(end:-1:1),1,[]) reshape(RandNoiseYes,1,[])];
    
    
    %% plot random
    if sum(subject.RandomSignal==0 & subject.RandomResp==1)>1
        figure;
        subplot(1,2,1);
        hold on;
        axis equal
        
        %random yes responses
        plot([0; cumsum(RandNoiseYes(end:-1:1))/sum(RandNoiseYes)],...
            [0; cumsum(RandSignalYes(end:-1:1))/sum(RandSignalYes)], '-*r');
        
        RandYesAUC(s) = trapz([0; cumsum(RandNoiseYes(end:-1:1))/sum(RandNoiseYes)],...
            [0; cumsum(RandSignalYes(end:-1:1))/sum(RandSignalYes)]);
        
        RandNoiseYesGroup = [RandNoiseYesGroup [0; cumsum(RandNoiseYes(end:-1:1))/sum(RandNoiseYes)]];
        RandSignalYesGroup = [RandSignalYesGroup [0; cumsum(RandSignalYes(end:-1:1))/sum(RandSignalYes)]];
        
        %random no responses
        plot([0; cumsum(RandSignalNo(end:-1:1))/sum(RandSignalNo)],...
            [0; cumsum(RandNoiseNo(end:-1:1))/sum(RandNoiseNo)],'-ok');
        
        RandNoAUC(s) = trapz([0; cumsum(RandSignalNo(end:-1:1))/sum(RandSignalNo)],...
            [0; cumsum(RandNoiseNo(end:-1:1))/sum(RandNoiseNo)]);
        
        RandNoiseNoGroup = [RandNoiseNoGroup [0; cumsum(RandNoiseNo(end:-1:1))/sum(RandNoiseNo)]];
        RandSignalNoGroup = [RandSignalNoGroup [0; cumsum(RandSignalNo(end:-1:1))/sum(RandSignalNo)]];
        
        xlabel('p(conf|false positive)');
        ylabel('p(conf|hit)');
        title([subj_list{s}, ': random']);
        set(gca,'xtick',(0:0.2:1)); xlim([0,1]);
        set(gca,'ytick',(0:0.2:1)); ylim([0,1]);
        refline(1,0);
        legend('signal', 'noise', 'Location', 'southeast')
        
    end
    
    if sum(subject.StructSignal==0 & subject.StructResp==1)>1
        
        %% plot structured
        subplot(1,2,2);
        hold on;
        axis equal
        
        %structured yes responses
        plot([0; cumsum(StructNoiseYes(end:-1:1))/sum(StructNoiseYes)],...
            [0; cumsum(StructSignalYes(end:-1:1))/sum(StructSignalYes)], '-*r');
        
        StructYesAUC(s) = trapz([0; cumsum(StructNoiseYes(end:-1:1))/sum(StructNoiseYes)],...
            [0; cumsum(StructSignalYes(end:-1:1))/sum(StructSignalYes)]);
        
        StructNoiseYesGroup = [StructNoiseYesGroup [0; cumsum(StructNoiseYes(end:-1:1))/sum(StructNoiseYes)]];
        StructSignalYesGroup = [StructSignalYesGroup [0; cumsum(StructSignalYes(end:-1:1))/sum(StructSignalYes)]];
        
        %structured no responses
        plot([0; cumsum(StructSignalNo(end:-1:1))/sum(StructSignalNo)],...
            [0; cumsum(StructNoiseNo(end:-1:1))/sum(StructNoiseNo)],'-ok');
        
        StructNoAUC(s) = trapz([0; cumsum(StructSignalNo(end:-1:1))/sum(StructSignalNo)],...
            [0; cumsum(StructNoiseNo(end:-1:1))/sum(StructNoiseNo)]);
        
        StructNoiseNoGroup = [StructNoiseNoGroup [0; cumsum(StructNoiseNo(end:-1:1))/sum(StructNoiseNo)]];
        StructSignalNoGroup = [StructSignalNoGroup [0; cumsum(StructSignalNo(end:-1:1))/sum(StructSignalNo)]];
        
        xlabel('p(conf|false positive)');
        ylabel('p(conf|hit)');
        title('structured');
        set(gca,'xtick',(0:0.2:1)); xlim([0,1]);
        set(gca,'ytick',(0:0.2:1)); ylim([0,1]);
        refline(1,0);
        legend('signal', 'noise', 'Location', 'southeast')
    end
end

set(0,'defaultAxesFontSize',10)
figure;
ax1=subplot(3,4,[1,2,5,6]);
hold on;
axis equal
%up responses
refline(1,0);

errorbar(mean(StructSignalYesGroup,2),mean(StructSignalNoGroup,2),std(StructSignalYesGroup')/sqrt(length(subj_list)),std(StructSignalYesGroup')/sqrt(length(subj_list)),...
    std(StructSignalNoGroup')/sqrt(length(subj_list)),std(StructSignalNoGroup')/sqrt(length(subj_list)),'k')
c=plot(mean(StructSignalYesGroup,2),mean(StructSignalNoGroup,2), '-ok', 'MarkerFaceColor',cb(3,:));
errorbar(mean(StructNoiseYesGroup,2),mean(StructNoiseNoGroup,2),std(StructNoiseYesGroup')/sqrt(length(subj_list)),std(StructNoiseYesGroup')/sqrt(length(subj_list)),...
    std(StructNoiseNoGroup')/sqrt(length(subj_list)),std(StructNoiseNoGroup')/sqrt(length(subj_list)),'k')
a=plot(mean(StructNoiseYesGroup,2),mean(StructNoiseNoGroup,2), '-ok', 'MarkerFaceColor', cb(4,:));
xlabel('p(conf | false positive)');
ylabel('p(conf | hit)');
title('structured');
set(gca,'xtick',(0:0.2:1)); xlim([0,1]);
set(gca,'ytick',(0:0.2:1)); ylim([0,1]);
legend([c,a],{sprintf('signal (%.02f)',mean(StructYesAUC)), sprintf('noise (%.02f)',mean(StructNoAUC))}, 'Location', 'southeast')

ax2=subplot(3,4,[3,4,7,8]);
hold on;
axis equal
refline(1,0);
%up responses
errorbar(mean(StructYesGroup,2),mean(RandYesGroup,2),std(StructYesGroup')/sqrt(35),std(StructYesGroup')/sqrt(35),...
    std(RandYesGroup')/sqrt(35),std(RandYesGroup')/sqrt(35),'k')
y=plot(mean(StructYesGroup,2),mean(RandYesGroup,2), '-ok', 'MarkerFaceColor',cb(2,:));
errorbar(mean(RandNoGroup,2),mean(StructNoGroup,2),std(RandNoGroup')/sqrt(35),std(RandNoGroup')/sqrt(35),...
    std(StructNoGroup')/sqrt(35),std(StructNoGroup')/sqrt(35),'k')
n=plot(mean(RandNoGroup,2),mean(StructNoGroup,2), '-ok', 'MarkerFaceColor', cb(1,:));
xlabel('p(conf | false positive)');
ylabel('p(conf | hit)');
title('detection');
set(gca,'xtick',(0:0.2:1)); xlim([0,1]);
set(gca,'ytick',(0:0.2:1)); ylim([0,1]);
legend([y,n],{sprintf('signal (%.02f)',mean(RandYesAUC)), sprintf('noise (%.02f)', mean(RandNoAUC))}, 'Location', 'southeast')

ax3=subplot(3,4,[9,10]);
hold on;
c_bar = bar(mean(hist_C),'FaceColor',cb(3,:));
errorbar(1:6, mean(hist_C), std(hist_C)/sqrt(length(subjects)),'.k');
a_bar= bar(-mean(hist_A),'FaceColor',cb(4,:));
set(gca,'xtick',1:6); set(gca, 'ytick',[]);
xlabel('confidence ratings'); ylabel('frequency');
errorbar(1:6, -mean(hist_A), std(hist_A)/sqrt(length(subjects)),'.k');
plot([0,7],mean(hist_C(:)-hist_A(:))*[1,1],'--k');
ax4=subplot(3,4,[11,12]);
hold on;
y_bar = bar(mean(hist_Y),'FaceColor',cb(2,:));
errorbar(1:6, mean(hist_Y), std(hist_Y)/sqrt(length(subjects)),'.k');
n_bar = bar(-mean(hist_N),'FaceColor',cb(1,:));
errorbar(1:6, -mean(hist_N), std(hist_N)/sqrt(length(subjects)),'.k');
plot([0,7],mean(hist_Y(:)-hist_N(:))*[1,1],'--k');
linkaxes([ax3,ax4])
set(gca,'xtick',1:6); set(gca, 'ytick',[]);
xlabel('confidence ratings'); ylabel('frequency');
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 6.7*0.8 4];
print('figures/rcROC_distributions','-dpng','-r600');
print('figures/rcROC_distributions_300dpi','-dpng','-r300');

    %}