params.house = 0;
params.visibility = -inf;
params.vis_peak = 15;
params.stimulus_number = 23;
[params.house_list, params.face_list] = extractTextureLists( );

schedule = exp(-abs((1:30) - params.vis_peak)/2);
%create fuzzy borders
ims = [300,300];
[x,y] = meshgrid((1:ims(2))-ims(2)/2,(1:ims(1))-ims(1)/2);
xsd = ims(1)/2.0;
ysd = ims(2)/2.0;
fuzzy_borders = exp(-((x/xsd).^2)-((y/ysd).^2));
params.fuzzy_borders = repmat(fuzzy_borders,[1,1,3]);

if params.house
    stimulus_path = fullfile('textures','houses',params.house_list(params.stimulus_number).name);
else
    stimulus_path = fullfile('textures','faces',params.face_list(params.stimulus_number).name);
end

stimulus_matrix = nan(30,300,300,3);

for i_frame = 1:length(schedule)
    
    stimulus_matrix(i_frame,:,:,:) = ...
        makeStimulus(rescale(imread(stimulus_path))*255,...
        schedule(i_frame)*exp(params.visibility),...
        params.fuzzy_borders);
end

for n = 1:30
    im = squeeze(stimulus_matrix(n,:,:,:))/256;
    [A,map] = rgb2ind(im,256,'nodither');
    if n == 1;
        imwrite(A,map,'example.gif','gif','LoopCount',inf,'DelayTime',0.033);
    else
        imwrite(A,map,'example.gif','gif','WriteMode','append','DelayTime',0.033);
    end
end
im = zeros(size(im));
[A,map] = rgb2ind(im,256,'nodither');
for i=1:50
    imwrite(A,map,'example.gif','gif','WriteMode','append','DelayTime',0.033);
end
