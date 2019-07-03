function [EV_vec,EVres_vec] = getExpectedVisbility(vis,pres,resp)

EV_raw_vec = nan(size(vis)); %initialize

vis_vec = vis;
vis_vec(pres==0)= -5;

 for i_v = 1:size(resp)-1
        
        if resp(i_v) == 1  %hit - change next expected visibility to current displayed visibility
            EV_raw_vec(i_v+1) = vis_vec(i_v);
        elseif resp(i_v)==0 %miss or correct rejection - carry forward current expected visibility to next trial
            EV_raw_vec(i_v+1) = EV_raw_vec(i_v);
        end    
 end


EV_vec = EV_raw_vec-nanmean(EV_raw_vec); %mean center
[~,~,EVres_vec] = regress(EV_vec,vis_vec);

end

