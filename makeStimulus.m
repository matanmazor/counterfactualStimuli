function [ stimulus ] = makeStimulus( image, p, mask )

if numel(size(image))==2;
    image = repmat(image,1,1,3);
else
    image = repmat(Scale(mean(image,3))*255,1,1,3);
end

stimulus = 255*rand(size(image));

p_mask = p*ones(size(image));


take_image_value = binornd(1,p_mask.*mask)>0;
stimulus(take_image_value) = image(take_image_value);


end

