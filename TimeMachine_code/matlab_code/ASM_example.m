%% This Script shows an example of an working basic Active Shape Model,
% with a few hand pictures.
%
% Literature used: Ginneken B. et al. "Active Shape Model Segmentation 
% with Optimal Features", IEEE Transactions on Medical Imaging 2002.
%
% Functions are written by D.Kroon University of Twente (February 2010)

%% %%%%%%%%%%   第一步：参数的设置     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add functions path to matlab search path
% 将对应的函数路径进行添加
functionname='ASM_example.m'; functiondir=which(functionname);
functiondir=functiondir(1:end-length(functionname));
addpath([functiondir '/Functions'])
addpath([functiondir '/ASM Functions'])
clear;clc
%% Set options
% 两个相邻的特征点之间的插值点的个数
options.ni=10;

% Length of landmark intensity profile
options.k = 8; 

% Search length (in pixels) for optimal contourpoint position, 
% in both normal directions of the contourpoint.
% 局部灰度模型中，每个特征点的搜索邻域数目
options.ns=4;

% 采用多分辨率的方法进行分析处理
options.nscales=4;

% Set normal contour, limit to +- m*sqrt( eigenvalue )
% 形变模型中参数的选择，最大值
options.m=3;

% Number of search itterations
% 每一次迭代过程中,搜索的次数
options.nsearch=40;

% 是否显示训练过程的图像
options.verbose=true;

% The original minimal Mahanobis distance using edge gradient (true)
% or new minimal PCA parameters using the intensities. (false)
% 得到了每一个点的局部灰度信息后，选择何种方式进行距离判断
options.originalsearch=0;   %OK

%% %%%%%%%%%%   第二步：读取训练数据，并按照给定参数进行重新等距采样  %%%%%%%%%%

% Load training data
% First Load the Hand Training DataSets (Contour and Image)
% The LoadDataSetNiceContour, not only reads the contour points, but 
% also resamples them to get a nice uniform spacing, between the important landmark contour points.

%声明 TrainingData 是结构体数据
TrainingData=struct;
if(options.verbose)
    figure
end

for i=1:1999  %存在10组训练数据
    is=num2str(i); number = '00000'; number(end-length(is)+1:end)=is; 
    filename=['Fotos/train' number '.mat'];
    
    %读取训练数据，对训练数据中的特征点按照给定的参数进行重新等距离采样分析
    [TrainingData(i).x,TrainingData(i).y,TrainingData(i).I]=LoadDataSetNiceContour(filename,options.ni,options.verbose);
    
    % 使用彩色图像代替灰度图像
	TrainingData(i).I=im2double(imread([filename(1:end-4) '.jpg']));

end
clear i is number
%%%%%%%%%%%%   第三步：根据给定的训练数据，建立形变模型  %%%%%%%%%%

%% Shape Model %%
% Make the Shape model, which finds the variations between contours in the training data sets. 
% And makes a PCA model describing normal contours

% 进行主成分分析, 获取N维空间中椭球的主轴，选取前面几个影响比较的大的主轴，
% 那么椭球中的每个数据点都可以近视的用这些主轴线性表示
[ShapeData TrainingData]= ASM_MakeShapeModel(TrainingData);

% ShapeData.Evectors=Evectors; %特征向量 382*6
% ShapeData.Evalues=Evalues;   %特征值   1*6
% ShapeData.x_mean=x_mean;     %样本向量空间的均值 382*1
% ShapeData.x=x;               %样本向量空间     382*10


% 显示原始的图像和采用主成分分析重构的图像
% if(options.verbose)
%     figure,
%     for i=1:6
%         xtest = ShapeData.x_mean + ShapeData.Evectors(:,i)*sqrt(ShapeData.Evalues(i))*3;
%         subplot(2,3,i), hold on;
%         plot(xtest(end/2+1:end),xtest(1:end/2),'r');
%         plot(ShapeData.x_mean(end/2+1:end),ShapeData.x_mean(1:end/2),'b');
%     end
% end

%%%%%%%%%%%%   第四步：建立局部灰度模型  %%%%%%%%%%%%%%%%%%%%
%% Appearance model %%
% Make the Appearance model, which samples a intensity pixel profile/line 
% perpendicular to each contourpoint in each trainingdataset. Which is 
% used to build correlation matrices for each landmark. Which are used
% in the optimization step, to find the best fit.
AppearanceData = ASM_MakeAppearanceModel(TrainingData,options);


%% Test the ASM model %%
%进行ASM形变模型的测试过程
Itest=im2double(imread('Fotos/test001.jpg'));

% Initial position offset and rotation, of the initial/mean contour
% 进行初始化参数设置
tform.offsetx=0; tform.offsety=0; tform.offsetr=0.36;

%posx posy 训练数据的均值
posx=ShapeData.x_mean(1:end/2)';  posy=ShapeData.x_mean(end/2+1:end)';
[posx,posy]=ASM_align_data_inverse(posx,posy,tform);

% Select the best starting position with the mouse
[x,y]=SelectPosition(Itest,posx,posy);
tform.offsetx=-x; tform.offsety=-y;

% Apply the ASM model onm the test image
base_points = ASM_ApplyModel(Itest,tform,ShapeData,AppearanceData,options);

IsegmentedLarge= drawObject(base_points,[size(Itest,1) size(Itest,2)]);
figure, imshow(IsegmentedLarge), title('Area contour');