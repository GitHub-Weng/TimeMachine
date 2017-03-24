function [ShapeData,TrainingData]= ASM_MakeShapeModel(TrainingData)

% ѵ��������������Ŀ
s=length(TrainingData);

% ÿ�����������������Ŀ
nl = length(TrainingData(1).x);

%% Shape model

% �����ݽ����ڲ��Ĺ�һ������ȥ����ת���߶ȵ����ص�Ӱ��
for i=1:s
    [TrainingData(i).centerx ,TrainingData(i).centery, TrainingData(i).tform]=ASM_align_data(TrainingData(i).x, TrainingData(i).y);
end

% ����һ�����ݽṹ�������������������ĵ����������������
x=zeros(nl*2,s); %n1������ĸ���  s ��������Ŀ
for i=1:length(TrainingData)
    x(:,i)=[TrainingData(i).centerx TrainingData(i).centery]';
end

%�������ɷַ�������ȡ��Ҫ����
[Evalues, Evectors, x_mean]=PCA(x);

% Keep only 98% of all eigen vectors, (remove contour noise)
i=find(cumsum(Evalues)<sum(Evalues)*0.98,1,'last')+1;
Evectors=Evectors(:,1:i);
Evalues=Evalues(1:i);

% Store the Eigen Vectors and Eigen Values
ShapeData.Evectors=Evectors; %�������� 
ShapeData.Evalues=Evalues;   %����ֵ
ShapeData.x_mean=x_mean;     %���������ռ�ľ�ֵ
ShapeData.x=x;               %���������ռ�




