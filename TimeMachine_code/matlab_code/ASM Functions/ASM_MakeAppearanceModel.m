%% Gray-Level Appearance Model
function AppearanceData=ASM_MakeAppearanceModel(TrainingData,options)
%���ܣ�����������ľֲ��Ҷ�ģ�ͣ�������������㸽����������Ϣ

% ѵ��������������Ŀ
num_sample = length(TrainingData);

% ÿ��������������ĸ���
num_feather = length(TrainingData(1).x);

% ����ÿ��������������ÿһ��ĻҶȵ���
for i=1:num_sample
  [TrainingData(i).normalsx,TrainingData(i).normalsy]=ASM_GetContourNormals(TrainingData(i).x,TrainingData(i).y);
end

% Inverse of covariance matrix sometimes badly scaled
warning('off','MATLAB:nearlySingularMatrix');

AppearanceData=struct;

% ���ö�ֱ��ʵķ�����ȡÿһ���������Ӧ�ľֲ���Ϣ
for itt_res=1:options.nscales %��ÿһ��
    scale=1 / (2^(itt_res-1));% 1 1/2 1/4 

    % Get the pixel profiles of every landmark perpendicular to the contour
    for i=1:num_sample  %��ÿһ������
        
        %����ֱ�Ӵ���᲻�����һЩ����
        px = TrainingData(i).x*scale;  py = TrainingData(i).y*scale;
        Ismall=imresize(TrainingData(i).I,scale);
        nx = TrainingData(i).normalsx; ny = TrainingData(i).normalsy;
        
        %��ȡÿ������ͼ����ÿһ�����Ӧ�ľֲ��Ҷ���Ϣ
        [TrainingData(i).GrayProfiles,TrainingData(i).DerivativeGrayProfiles]=ASM_getProfileAndDerivatives(Ismall,px,py,nx,ny,options.k);
        % GrayProfiles  ������λ��
        % DerivativeGrayProfiles һ�׵���
    end

    % Profile length * space for rgb
    % ÿһ���������Ӧ�ľֲ��Ҷ���Ϣ����������
    length_point = (options.k*2+1)*size(TrainingData(1).I,3);
    
    % Calculate a covariance matrix for all landmarks
    % ��ÿһ���㣬����õ��Ӧ�����Э������󣬴Ӷ��ҵ���ά�ռ����������
    PCAData=cell(1,num_feather);
    for j=1:num_feather % ��ÿһ��������
        %% The orginal search method using Mahanobis distance with
        % edge gradient information
        dg=zeros(length_point,num_sample);%���������Ӧ�ľֲ��Ҷ���Ϣ
        
        % ��¼�ò�������������Ӧ�����������ľֲ��Ҷ���Ϣ
        for i=1:num_sample
            dg(:,i)=TrainingData(i).DerivativeGrayProfiles(:,j); 
        end
        
        dg_mean=mean(dg,2);%��ֵ
        dg=dg-repmat(dg_mean,1,num_sample);%��
        % Calculate the coveriance matrix and its inverse
        
        %itt_res���µ�j���������Ӧ�ľֲ��Ҷ���Ϣ����Ӧ��Э�������
        AppearanceData(itt_res).Landmarks(j).num_sample = cov(dg');
        AppearanceData(itt_res).Landmarks(j).Sinv = inv(AppearanceData(itt_res).Landmarks(j).num_sample);
        AppearanceData(itt_res).Landmarks(j).dg_mean = dg_mean;
        
        %% The new search method using PCA on intensities, and minimizing
        % parameters / the distance to the mean during the search.
        % Make a matrix with all intensities
        
        % g ��¼���˵�j���������Ӧ�����������ľֲ��Ҷ���Ϣ
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
    
    % �����Դ�ѭ����
    % AppearanceData(itt_res).PCAData{j}��¼������itt_res����,��j������������Ӧ�����������ľֲ��Ҷ���
    % Ϣ��PCA��Բ����
    
    % AppearanceData(itt_res).Landmarks(j) ��¼�µ�����itt_res���£���j������������Ӧ�ľֲ��Ҷ��ݶ���Ϣ
    AppearanceData(itt_res).PCAData=PCAData;
end