%% Test the ASM model %%
%����ASM�α�ģ�͵Ĳ��Թ���
Itest=im2double(imread('Fotos/test001.jpg'));

% Initial position offset and rotation, of the initial/mean contour
% ���г�ʼ����������
tform.offsetx=0; tform.offsety=0; tform.offsetr=0.36;

%posx posy ѵ�����ݵľ�ֵ
posx=ShapeData.x_mean(1:end/2)';  posy=ShapeData.x_mean(end/2+1:end)';
[posx,posy]=ASM_align_data_inverse(posx,posy,tform);

% Select the best starting position with the mouse
[x,y]=SelectPosition(Itest,posx,posy);
tform.offsetx=-x; tform.offsety=-y;

% Apply the ASM model onm the test image
base_points = ASM_ApplyModel(Itest,tform,ShapeData,AppearanceData,options);

IsegmentedLarge= drawObject(base_points,[size(Itest,1) size(Itest,2)]);
figure, imshow(IsegmentedLarge), title('Area contour');