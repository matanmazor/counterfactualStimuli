function [ acc2AFC ] = accYN2accAFC( accYN )
% input: desired accuracy in detection.
% output: necessary accuracy in 2AFC
% assuming no response bias and independent sensitivities to the two 
acc2AFC = normcdf(sqrt(2)*norminv(accYN));

end

