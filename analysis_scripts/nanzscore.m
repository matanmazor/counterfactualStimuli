function [zvec] = nanzscore(vec)
%zscore function that can deal with NaN values 
%   input a vector and the zscore normalized vector will be returned
if any(isnan(vec(:)))
    xmu=nanmean(vec);
    xsigma=nanstd(vec);
    zvec=(vec-repmat(xmu,length(vec),1))./repmat(xsigma,length(vec),1);
else
    [zvec,xmu,xsigma]=zscore(vec);
end
end