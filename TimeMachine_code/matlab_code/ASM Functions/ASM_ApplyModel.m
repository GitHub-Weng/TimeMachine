function base_points = ASM_ApplyModel(Itest,tform,ShapeData,AppearanceData,options)
% Optimalization 
% 开始进行优化迭代

% Show the test image
figure, imshow(Itest); hold on;

% The initial contour is the Mean trainingdata set contour
% 训练样本的初始位置，由于经过了调整，因此需要后面坐标调整
num_point=length(ShapeData.x_mean)/2;
posx=ShapeData.x_mean(1:num_point)'; posy=ShapeData.x_mean(num_point+1:end)';
%posx=ShapeData.x(1:num_point,1)';
%posy=ShapeData.x(num_point+1:end,1)';

% Position the initial contour at a location close to the correct location
% 将posx posy转化为坐标系下的坐标
[posx,posy]=ASM_align_data_inverse(posx,posy,tform);
 
% Handle later used to delete the plotted contour
h=[]; h2=[];

% We optimize starting from a rough to a fine image scale
% 从粗到精的进行优化迭代
for itt_res=options.nscales:-1:1
    % Scaling of the image
    scale=1 / (2^(itt_res-1));

    PCAData=AppearanceData(itt_res).PCAData;
     
    % Do 40 ASM itterations
    for itt=1:options.nsearch %这一层中使用迭代的次数
        
        % Plot the contour
        % 在图像中显示出所有的原始特征点的坐标
        if(ishandle(h)), delete(h); end
        h=plot(posy,posx); drawnow('expose'); 
        
        % Calculate the normals of the contour points.
        % 计算这些点对应的方向
        [nx,ny]=ASM_GetContourNormals(posx,posy);

        % Create long intensity profiles on the contour normals, for search of best point fit, 
        % using the correlation matrices made in the appearance model
        
        % Total Intensity line-profile needed, is the traininglength + the
        % search length in both normal directions
        n = options.k + options.ns;

        % Get the intensity profiles of all landmarks and there first order derivatives 获取对应点的一阶导数
        [gt,dgt]=ASM_getProfileAndDerivatives(imresize(Itest,scale),posx*scale,posy*scale,nx,ny,n);
        
        % Loop through all contour points
        f=zeros(options.ns*2+1,num_point);
        for j=1:num_point %对所有的点进行分析
            % Search through the large sampeled profile, for the optimal position
            for i=1:(options.ns*2+1) %分析这个点附近对应的这些点
                % A profile from the large profile, with the length of the trainingprofile (for rgb image 3x as long) 
                %如果存在RGB分量,需要对三通道全部考虑
                gi=zeros((2*options.k+1)*size(Itest,3),1);
                
                %采用哪种分类方式
                if(options.originalsearch) %原始的马氏距离分析
                    for k=1:size(Itest,3), 
                        coffset=(k-1)*(2*options.k+1);
                        coffset2=(k-1)*(options.ns*2+1);
                        gi(1+coffset:2*options.k+1+coffset)=dgt(i+coffset2:2*options.k+i+coffset2,j);
                    end
                    % Calculate the Mahalanobis distance from the current profile, to the training data 
                    % sets profiles through an inverse correlation matrix.
                    v=(gi- AppearanceData(itt_res).Landmarks(j).dg_mean);
                    f(i,j)=v'*AppearanceData(itt_res).Landmarks(j).Sinv*v; %对应的马氏距离
                
                else %采用最邻近距离分析法
                    for k=1:size(Itest,3), 
                        coffset=(k-1)*(2*options.k+1);
                        coffset2=(k-1)*(options.ns*2+1);
                        gi(1+coffset:2*options.k+1+coffset)=gt(i+coffset2:2*options.k+i+coffset2,j);
                    end
                    % Calculate the PCA parameters, and normalize them with the variances.
                    % (Seems to work better with color images than the original method)
                    bc = PCAData{j}.Evectors'*(gi-PCAData{j}.Emean);
                    bc = bc./(sqrt(PCAData{j}.Evalues));
                    f(i,j)=sum(bc.^2);
                end
                
            end
            % Find the lowest Mahalanobis distance, and store it 
            % as movement step
        end
        
        %这样,矩阵f就保存了在该层中，本次迭代中所有的原始特征点在其距离附近所有的点的距离
        [~,i]=min(f);
        movement=((i-1)-options.ns);

        % Move the points to there new optimal positions
        % 对当前的点进行位移操作，得到新的迭代位置
        posx=posx+(1/scale)*movement.*nx;
        posy=posy+(1/scale)*movement.*ny;
        
        % Show the new positions
        % 显示新的位置信息
        if(ishandle(h2)), delete(h2); end
        h2=plot(posy,posx,'r.'); drawnow('expose'); 

        % Remove translation and rotation, as done when training the model.
        [posx,posy,tform]=ASM_align_data(posx,posy);
        
        % Describe the model by a vector b with model parameters
        x_search=[posx';posy'];
        b = ShapeData.Evectors'*(x_search-ShapeData.x_mean);

        % Limit the model parameters based on what is considered a nomal
        % contour, using the eigenvalues of the PCA-model
        maxb=options.m*sqrt(ShapeData.Evalues);
        b=max(min(b,maxb),-maxb);

        % Transform the model parameter vector b, back to contour positions
        x_search = ShapeData.x_mean + ShapeData.Evectors*b;
        posx=x_search(1:num_point)'; posy=x_search(num_point+1:end)';

        % Now add the previously removed translation and rotation
        [posx,posy]=ASM_align_data_inverse(posx,posy,tform);
    end
end

base_points=[posx(:) posy(:)];
%IsegmentedLarge= drawObject(base_points,[size(Itest,1) size(Itest,2)]);
%figure, imshow(IsegmentedLarge), title('Area contour');