%% This Script shows an example of an working basic Active Shape Model,
% with a few hand pictures.
%
% Literature used: Ginneken B. et al. "Active Shape Model Segmentation 
% with Optimal Features", IEEE Transactions on Medical Imaging 2002.
%
% Functions are written by D.Kroon University of Twente (February 2010)

%% %%%%%%%%%%   ��һ��������������     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add functions path to matlab search path
% ����Ӧ�ĺ���·���������
functionname='ASM_example.m'; functiondir=which(functionname);
functiondir=functiondir(1:end-length(functionname));
addpath([functiondir '/Functions'])
addpath([functiondir '/ASM Functions'])
clear;clc
%% Set options
% �������ڵ�������֮��Ĳ�ֵ��ĸ���
options.ni=10;

% Length of landmark intensity profile
options.k = 8; 

% Search length (in pixels) for optimal contourpoint position, 
% in both normal directions of the contourpoint.
% �ֲ��Ҷ�ģ���У�ÿ�������������������Ŀ
options.ns=4;

% ���ö�ֱ��ʵķ������з�������
options.nscales=4;

% Set normal contour, limit to +- m*sqrt( eigenvalue )
% �α�ģ���в�����ѡ�����ֵ
options.m=3;

% Number of search itterations
% ÿһ�ε���������,�����Ĵ���
options.nsearch=40;

% �Ƿ���ʾѵ�����̵�ͼ��
options.verbose=true;

% The original minimal Mahanobis distance using edge gradient (true)
% or new minimal PCA parameters using the intensities. (false)
% �õ���ÿһ����ľֲ��Ҷ���Ϣ��ѡ����ַ�ʽ���о����ж�
options.originalsearch=0;   %OK

%% %%%%%%%%%%   �ڶ�������ȡѵ�����ݣ������ո��������������µȾ����  %%%%%%%%%%

% Load training data
% First Load the Hand Training DataSets (Contour and Image)
% The LoadDataSetNiceContour, not only reads the contour points, but 
% also resamples them to get a nice uniform spacing, between the important landmark contour points.

%���� TrainingData �ǽṹ������
TrainingData=struct;
if(options.verbose)
    figure
end

for i=1:1999  %����10��ѵ������
    is=num2str(i); number = '00000'; number(end-length(is)+1:end)=is; 
    filename=['Fotos/train' number '.mat'];
    
    %��ȡѵ�����ݣ���ѵ�������е������㰴�ո����Ĳ����������µȾ����������
    [TrainingData(i).x,TrainingData(i).y,TrainingData(i).I]=LoadDataSetNiceContour(filename,options.ni,options.verbose);
    
    % ʹ�ò�ɫͼ�����Ҷ�ͼ��
	TrainingData(i).I=im2double(imread([filename(1:end-4) '.jpg']));

end
clear i is number
%%%%%%%%%%%%   �����������ݸ�����ѵ�����ݣ������α�ģ��  %%%%%%%%%%

%% Shape Model %%
% Make the Shape model, which finds the variations between contours in the training data sets. 
% And makes a PCA model describing normal contours

% �������ɷַ���, ��ȡNά�ռ�����������ᣬѡȡǰ�漸��Ӱ��ȽϵĴ�����ᣬ
% ��ô�����е�ÿ�����ݵ㶼���Խ��ӵ�����Щ�������Ա�ʾ
[ShapeData TrainingData]= ASM_MakeShapeModel(TrainingData);

% ShapeData.Evectors=Evectors; %�������� 382*6
% ShapeData.Evalues=Evalues;   %����ֵ   1*6
% ShapeData.x_mean=x_mean;     %���������ռ�ľ�ֵ 382*1
% ShapeData.x=x;               %���������ռ�     382*10


% ��ʾԭʼ��ͼ��Ͳ������ɷַ����ع���ͼ��
% if(options.verbose)
%     figure,
%     for i=1:6
%         xtest = ShapeData.x_mean + ShapeData.Evectors(:,i)*sqrt(ShapeData.Evalues(i))*3;
%         subplot(2,3,i), hold on;
%         plot(xtest(end/2+1:end),xtest(1:end/2),'r');
%         plot(ShapeData.x_mean(end/2+1:end),ShapeData.x_mean(1:end/2),'b');
%     end
% end

%%%%%%%%%%%%   ���Ĳ��������ֲ��Ҷ�ģ��  %%%%%%%%%%%%%%%%%%%%
%% Appearance model %%
% Make the Appearance model, which samples a intensity pixel profile/line 
% perpendicular to each contourpoint in each trainingdataset. Which is 
% used to build correlation matrices for each landmark. Which are used
% in the optimization step, to find the best fit.
AppearanceData = ASM_MakeAppearanceModel(TrainingData,options);


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