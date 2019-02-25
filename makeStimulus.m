function [ stimulus ] = makeStimulus( image, p )

if numel(size(image))==2;
    image = repmat(image,1,1,3);
end
stimulus = 255*rand(size(image));

p_mask = p*ones(size(image));

[x,y] = meshgrid((1:size(p_mask,2))-size(p_mask,2)/2,...
    (1:size(p_mask,1))-size(p_mask,1)/2);

xsd = size(p_mask,1)/2.0;
ysd = size(p_mask,2)/2.0;

fuzzy_borders = exp(-((x/xsd).^2)-((y/ysd).^2));
fuzzy_borders = repmat(fuzzy_borders,1,1,3);

take_image_value = binornd(1,p_mask.*fuzzy_borders)>0;
% take_image_value = binornd(1,p_mask)>0;
stimulus(take_image_value) = image(take_image_value);



end

