function [ house_list, face_list ] = extractTextureLists( )

face_list = dir(fullfile('textures','faces','*.png'));
house_list = dir(fullfile('textures','houses','*.png'));

end

