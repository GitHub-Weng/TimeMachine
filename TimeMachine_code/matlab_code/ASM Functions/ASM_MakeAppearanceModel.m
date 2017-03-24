%% Gray-Level Appearance Model
function AppearanceData=ASM_MakeAppearanceModel(TrainingData,options)
%功能：建立特征点的局部灰度模型，充分利用特征点附近的纹理信息

% 训练集中样本的数目
num_sample = length(TrainingData);

% 每个样本中特征点的个数
num_feather = length(TrainingData(1).x);

% 计算每个样本中轮廓中每一点的灰度导数
for i=1:num_sample
  [TrainingData(i).normalsx,TrainingData(i).normalsy]=ASM_GetContourNormals(TrainingData(i).x,TrainingData(i).y);
end

% Inverse of covariance matrix sometimes badly scaled
warning('off','MATLAB:nearlySingularMatrix');

AppearanceData=struct;

% 采用多分辨率的方法获取每一个轮廓点对应的局部信息
for itt_res=1:options.nscales %对每一层
    scale=1 / (2^(itt_res-1));% 1 1/2 1/4 

    % Get the pixel profiles of every landmark perpendicular to the contour
    for i=1:num_sample  %对每一个样本
        
        %这样直接处理会不会存在一些问题
        px = TrainingData(i).x*scale;  py = TrainingData(i).y*scale;
        Ismall=imresize(TrainingData(i).I,scale);
        nx = TrainingData(i).normalsx; ny = TrainingData(i).normalsy;
        
        %获取每幅样本图像在每一个点对应的局部灰度信息
        [TrainingData(i).GrayProfiles,TrainingData(i).DerivativeGrayProfiles]=ASM_getProfileAndDerivatives(Ismall,px,py,nx,ny,options.k);
        % GrayProfiles  轮廓点位置
        % DerivativeGrayProfiles 一阶导数
    end

    % Profile length * space for rgb
    % 每一个特征点对应的局部灰度信息的向量长度
    length_point = (options.k*2+1)*size(TrainingData(1).I,3);
    
    % Calculate a covariance matrix for all landmarks
    % 对每一个点，计算该点对应区域的协方差矩阵，从而找到高维空间的椭球主轴
    PCAData=cell(1,num_feather);
    for j=1:num_feather % 对每一个特征点
        %% The orginal search method using Mahanobis distance with
        % edge gradient information
        dg=zeros(length_point,num_sample);%该特征点对应的局部灰度信息
        
        % 记录该层下所有样本对应于这个特征点的局部灰度信息
        for i=1:num_sample
            dg(:,i)=TrainingData(i).DerivativeGrayProfiles(:,j); 
        end
        
        dg_mean=mean(dg,2);%均值
        dg=dg-repmat(dg_mean,1,num_sample);%差
        % Calculate the coveriance matrix and its inverse
        
        %itt_res层下第j个特征点对应的局部灰度信息所对应的协方差矩阵
        AppearanceData(itt_res).Landmarks(j).num_sample = cov(dg');
        AppearanceData(itt_res).Landmarks(j).Sinv = inv(AppearanceData(itt_res).Landmarks(j).num_sample);
        AppearanceData(itt_res).Landmarks(j).dg_mean = dg_mean;
        
        %% The new search method using PCA on intensities, and minimizing
        % parameters / the distance to the mean during the search.
        % Make a matrix with all intensities
        
        % g 记录下了第j个特征点对应的所有样本的局部灰度信息
        g=zeros(length_point,num_sample);
        for i=1:num_sample 
            g(:,i)=TrainingData(i).GrayProfiles(:,j); 
        end
                
        [Evalues, Evectors, Emean]=PCA(g);
        % Keep only 98% of all eigen vectors, (remove contour noise)
        i=find(cumsum(Evalues)<sum(Evalues)*0.98,1,'last')+1;
        PCAData{j}.Evectors= Evectors(:,1:i);
        PCAData{j}.Evalues = Evalues(1:i);
        PCAData{j}.Emean = Emean;
        
    end
    
    % 经过对此循环后
    % AppearanceData(itt_res).PCAData{j}记录下了再itt_res层下,第j个特征点所对应的所有样本的局部灰度信
    % 息的PCA椭圆主轴
    
    % AppearanceData(itt_res).Landmarks(j) 记录下的是在itt_res层下，第j个特征点所对应的局部灰度梯度信息
    AppearanceData(itt_res).PCAData=PCAData;
end