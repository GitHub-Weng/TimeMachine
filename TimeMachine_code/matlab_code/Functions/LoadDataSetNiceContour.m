function [totalx, totaly, I]=LoadDataSetNiceContour(filename,nBetween,verbose)
% 功能：对训练的数据进行重新组合，根据当前决定骨架的特征点（landmark）以及之前定义的nBetween
%       进行数据进行重新等距离采样分析，将最后的数据保存在totalx totaly中。然后进行分析

% LoadDataSetNiceContour, Load the ContourPoints and Photo of a dataset
% and will interpolate a number of evenly spaced contour points between
% the poinst marked as major landmark point.
%
% [totalx, totaly, I]=LoadDataSetNiceContour(filename,nBetween,verbose)
%
% The dataset .mat file must contain a structure "p"
%  p.n : Number of contour points clicked
%  p.x, p.y : The location of the contour poinst
%  p.I : The image
%  p.t : same length as the coordinates, with "0" a major landmark point
%        and "2" only a simple point on the contour.
%        当前的训练数据中存在11个决定骨架的特征点，剩下的89个点只是普通的点
%   
% Function written by D.Kroon University of Twente (February 2010)

load(filename);

% 通过插值的方式获取更多的点，由于最后的4个点是通过外插的方式产生，这里不需要，
% 现在一共存在了496个点
r=5;
pointsx=interp(p.x,r); pointsx=pointsx(1:end-r+1);
pointsy=interp(p.y,r); pointsy=pointsy(1:end-r+1);

% Mark Landmark points with 1, other poinst zero
%利用pointst来进行标志,特征点标注为1，其他的点标注为0
i=find(p.t==0); pointst=0; pointst((i-1)*r+1)=1;

%将插值得到的点在图像中显示
if(verbose), imshow(p.I), hold on; plot(pointsy,pointsx,'b'); end

% Find the Landmark point locations
%寻找特征点在插值后所有点中对应的位置
i=find(pointst);

totalx=[]; totaly=[];
% Loop to make points evenly spaced on line pieces between landmark points
%对每两个特征点之间进行处理分析
for j=1:length(i)-1
    
    % One line piece，第一个线段
    linex=pointsx(i(j):i(j+1)); liney=pointsy(i(j):i(j+1));
    
    % Lenght on line through the points
    % 两点之间的距离
    dx=[0 linex(2:end)-linex(1:end-1)];    dy=[0 liney(2:end)-liney(1:end-1)];
    % 距离之和
    dist=cumsum(sqrt(dx.^2+dy.^2));
    
    % Interpolate new points evenly spaced on the line piece
    % 在[0,最大距离]进行等距离划分
    dist2=linspace(0,max(dist),nBetween);
    
    %按照距离的信息，等距的划分，得到nBetween个离散的数据点
    linex=interp1(dist,linex,dist2);
    liney=interp1(dist,liney,dist2);
    
    % Display the line piece，显示这些点和线
    if(verbose),
        plot(liney,linex,'g*');
        plot(liney(1),linex(1),'r*');
        plot(liney(end),linex(end),'r*'); 
    end
    
    % Remove Point because it is also in the next line piece
    % 删除最后的点，因为这些点也在下一条线段中
    if(j<length(i)-1)
        linex(end)=[]; 
        liney(end)=[];
    end
    
    % Add the evenly spaced line piece to the total line
    % 将所有的点的数据进行保存
    totalx=[totalx linex];
    totaly=[totaly liney];
end

% Also store the image 进行图像数据信息保存
if(size(p.I,3)==3)
    I=double(p.I);
else
    I=p.I; 
end

if(verbose)
    drawnow('expose');
end
