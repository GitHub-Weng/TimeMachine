% if(isempty(whos('pathname')) | isequal(pathname,0) ) 
%     pathname=[]; 
% end  
% [filename, pathname] = uigetfile([pathname,'*.bmp;*.jpg;*.png'], 'Pick an image');
% if isequal(filename,0) | isequal(pathname,0)    
%     clear all;
%     return;
% end
% photo = imread([pathname,filename]);
% ����Ӧ�ĺ���·���������
function [status] = main()
 functionname='ASM.m'; functiondir=which(functionname);
functiondir=functiondir(1:end-length(functionname));
addpath([functiondir '/Functions'])
addpath([functiondir '/ASM Functions'])
functionname='main.m'; functiondir=which(functionname);
functiondir=functiondir(1:end-length(functionname));
addpath([functiondir '/warp'])
addpath([functiondir '/facepp'])
%%
file_path =  'D:\matlab_java_result\';% ͼ���ļ���·��
 
img_path_list = dir(strcat(file_path,'*.jpg'));%��ȡ���ļ���������jpg��ʽ��ͼ��
 
img_num = length(img_path_list);%��ȡͼ��������
 
if img_num > 0 %������������ͼ��
 
        for j = 1:img_num %��һ��ȡͼ��
 
            image_name = img_path_list(j).name;% ͼ����
            photo_path = strcat(file_path,image_name);
            photo =  imread(photo_path);
 
            fprintf('%d %d %s\n',i,j,photo_path);% ��ʾ���ڴ����ͼ����
 
            %ͼ������� ʡ��
 
        end
end

% 
% options=load('/training_data/options.mat');
% TrainingData=('/training_data/TrainingData.mat');
% ShapeData=('/training_data/ShapeData.mat');
% AppearanceData=('/training_data/AppearanceData.mat');
% base_points = ASM(photo,ShapeData,AppearanceData,options);
% facepp_getmat('/warp/12.jpg');
photo = imresize(photo,[400,320]);
facepp_getmat(photo_path);
points = cell2mat(struct2cell(load('points/input_photo_points.mat')));
% getFacepp83points(points);
get83points(points,photo);

 j=0.1;
 for ii = 5:-1:1
     myWarping(photo,imread('/warp/baby.jpg'),'points/points2.lmk','/warp/baby.lmk',83,j,ii);
     j=j+0.1;
 end
 j=0.1;
 for ii = 6:10
     myWarping(photo,imread('/warp/12.jpg'),'points/points2.lmk','/warp/12.lmk',83,j,ii);
     j=j+0.1;
 end
 status='SUCCESS';