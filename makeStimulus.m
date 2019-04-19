function [ stimulus ] = makeStimulus( image, p, mask )


image = Scale(mean(image,3))*255;

stimulus = 255*rand(size(image));

p_mask = p*ones(size(image));
p_mask = p_mask.*mask(:,:,1);

take_image_value = binornd(1,p_mask)>0;
stimulus(take_image_value) = image(take_image_value);

stimulus = repmat(stimulus,1,1,3);

end

