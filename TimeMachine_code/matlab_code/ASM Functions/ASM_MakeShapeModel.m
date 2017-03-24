function [ShapeData,TrainingData]= ASM_MakeShapeModel(TrainingData)

% 训练集中样本的数目
s=length(TrainingData);

% 每个样本中特征点的数目
nl = length(TrainingData(1).x);

%% Shape model

% 对数据进行内部的归一化处理，去除旋转，尺度等因素的影响
for i=1:s
    [TrainingData(i).centerx ,TrainingData(i).centery, TrainingData(i).tform]=ASM_align_data(TrainingData(i).x, TrainingData(i).y);
end

% 建立一个数据结构，用来保存所有样本的的所有特征点的坐标
x=zeros(nl*2,s); %n1特征点的个数  s 样本的数目
for i=1:length(TrainingData)
    x(:,i)=[TrainingData(i).centerx TrainingData(i).centery]';
end

%进行主成分分析，获取主要分量
[Evalues, Evectors, x_mean]=PCA(x);

% Keep only 98% of all eigen vectors, (remove contour noise)
i=find(cumsum(Evalues)<sum(Evalues)*0.98,1,'last')+1;
Evectors=Evectors(:,1:i);
Evalues=Evalues(1:i);

% Store the Eigen Vectors and Eigen Values
ShapeData.Evectors=Evectors; %特征向量 
ShapeData.Evalues=Evalues;   %特征值
ShapeData.x_mean=x_mean;     %样本向量空间的均值
ShapeData.x=x;               %样本向量空间




