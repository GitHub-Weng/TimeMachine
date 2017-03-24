function base_points = ASM_ApplyModel(Itest,tform,ShapeData,AppearanceData,options)
% Optimalization 
% ��ʼ�����Ż�����

% Show the test image
figure, imshow(Itest); hold on;

% The initial contour is the Mean trainingdata set contour
% ѵ�������ĳ�ʼλ�ã����ھ����˵����������Ҫ�����������
num_point=length(ShapeData.x_mean)/2;
posx=ShapeData.x_mean(1:num_point)'; posy=ShapeData.x_mean(num_point+1:end)';
%posx=ShapeData.x(1:num_point,1)';
%posy=ShapeData.x(num_point+1:end,1)';

% Position the initial contour at a location close to the correct location
% ��posx posyת��Ϊ����ϵ�µ�����
[posx,posy]=ASM_align_data_inverse(posx,posy,tform);
 
% Handle later used to delete the plotted contour
h=[]; h2=[];

% We optimize starting from a rough to a fine image scale
% �Ӵֵ����Ľ����Ż�����
for itt_res=options.nscales:-1:1
    % Scaling of the image
    scale=1 / (2^(itt_res-1));

    PCAData=AppearanceData(itt_res).PCAData;
     
    % Do 40 ASM itterations
    for itt=1:options.nsearch %��һ����ʹ�õ����Ĵ���
        
        % Plot the contour
        % ��ͼ������ʾ�����е�ԭʼ�����������
        if(ishandle(h)), delete(h); end
        h=plot(posy,posx); drawnow('expose'); 
        
        % Calculate the normals of the contour points.
        % ������Щ���Ӧ�ķ���
        [nx,ny]=ASM_GetContourNormals(posx,posy);

        % Create long intensity profiles on the contour normals, for search of best point fit, 
        % using the correlation matrices made in the appearance model
        
        % Total Intensity line-profile needed, is the traininglength + the
        % search length in both normal directions
        n = options.k + options.ns;

        % Get the intensity profiles of all landmarks and there first order derivatives ��ȡ��Ӧ���һ�׵���
        [gt,dgt]=ASM_getProfileAndDerivatives(imresize(Itest,scale),posx*scale,posy*scale,nx,ny,n);
        
        % Loop through all contour points
        f=zeros(options.ns*2+1,num_point);
        for j=1:num_point %�����еĵ���з���
            % Search through the large sampeled profile, for the optimal position
            for i=1:(options.ns*2+1) %��������㸽����Ӧ����Щ��
                % A profile from the large profile, with the length of the trainingprofile (for rgb image 3x as long) 
                %�������RGB����,��Ҫ����ͨ��ȫ������
                gi=zeros((2*options.k+1)*size(Itest,3),1);
                
                %�������ַ��෽ʽ
                if(options.originalsearch) %ԭʼ�����Ͼ������
                    for k=1:size(Itest,3), 
                        coffset=(k-1)*(2*options.k+1);
                        coffset2=(k-1)*(options.ns*2+1);
                        gi(1+coffset:2*options.k+1+coffset)=dgt(i+coffset2:2*options.k+i+coffset2,j);
                    end
                    % Calculate the Mahalanobis distance from the current profile, to the training data 
                    % sets profiles through an inverse correlation matrix.
                    v=(gi- AppearanceData(itt_res).Landmarks(j).dg_mean);
                    f(i,j)=v'*AppearanceData(itt_res).Landmarks(j).Sinv*v; %��Ӧ�����Ͼ���
                
                else %�������ڽ����������
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
        
        %����,����f�ͱ������ڸò��У����ε��������е�ԭʼ������������븽�����еĵ�ľ���
        [~,i]=min(f);
        movement=((i-1)-options.ns);

        % Move the points to there new optimal positions
        % �Ե�ǰ�ĵ����λ�Ʋ������õ��µĵ���λ��
        posx=posx+(1/scale)*movement.*nx;
        posy=posy+(1/scale)*movement.*ny;
        
        % Show the new positions
        % ��ʾ�µ�λ����Ϣ
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