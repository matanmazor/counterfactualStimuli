function [AUROC] = extractAUROC(signalVec,respVec,confVec)
%Matan Mazor 2019
%matanmazor@outlook.com

signalVec = signalVec(:);
signals = unique(signalVec);
signalVec(signalVec == signals(1)) = -1;
signalVec(signalVec == signals(2)) = 1;
respVec = respVec(:);
respVec(respVec == signals(1)) = -1;
respVec(respVec == signals(2)) = 1;
confVec = confVec(:);

biConfVec = confVec.*respVec;

[nR_S1,nR_S2] = deal(nan(size(min(biConfVec):max(biConfVec))));

for rating = min(biConfVec):max(biConfVec)
    nR_S1(rating-min(biConfVec)+1) = sum(biConfVec == rating & signalVec == -1);
    nR_S2(rating-min(biConfVec)+1) = sum(biConfVec == rating & signalVec == 1);
end

pR_S1 = [0 cumsum(nR_S1(end:-1:1))/sum(nR_S1)];
pR_S2 = [0 cumsum(nR_S2(end:-1:1))/sum(nR_S2)];

AUROC = trapz(pR_S1,pR_S2);
end

