function [totalx, totaly, I]=LoadDataSetNiceContour(filename,nBetween,verbose)
% ���ܣ���ѵ�������ݽ���������ϣ����ݵ�ǰ�����Ǽܵ������㣨landmark���Լ�֮ǰ�����nBetween
%       �������ݽ������µȾ���������������������ݱ�����totalx totaly�С�Ȼ����з���

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
%        ��ǰ��ѵ�������д���11�������Ǽܵ������㣬ʣ�µ�89����ֻ����ͨ�ĵ�
%   
% Function written by D.Kroon University of Twente (February 2010)

load(filename);

% ͨ����ֵ�ķ�ʽ��ȡ����ĵ㣬��������4������ͨ�����ķ�ʽ���������ﲻ��Ҫ��
% ����һ��������496����
r=5;
pointsx=interp(p.x,r); pointsx=pointsx(1:end-r+1);
pointsy=interp(p.y,r); pointsy=pointsy(1:end-r+1);

% Mark Landmark points with 1, other poinst zero
%����pointst�����б�־,�������עΪ1�������ĵ��עΪ0
i=find(p.t==0); pointst=0; pointst((i-1)*r+1)=1;

%����ֵ�õ��ĵ���ͼ������ʾ
if(verbose), imshow(p.I), hold on; plot(pointsy,pointsx,'b'); end

% Find the Landmark point locations
%Ѱ���������ڲ�ֵ�����е��ж�Ӧ��λ��
i=find(pointst);

totalx=[]; totaly=[];
% Loop to make points evenly spaced on line pieces between landmark points
%��ÿ����������֮����д������
for j=1:length(i)-1
    
    % One line piece����һ���߶�
    linex=pointsx(i(j):i(j+1)); liney=pointsy(i(j):i(j+1));
    
    % Lenght on line through the points
    % ����֮��ľ���
    dx=[0 linex(2:end)-linex(1:end-1)];    dy=[0 liney(2:end)-liney(1:end-1)];
    % ����֮��
    dist=cumsum(sqrt(dx.^2+dy.^2));
    
    % Interpolate new points evenly spaced on the line piece
    % ��[0,������]���еȾ��뻮��
    dist2=linspace(0,max(dist),nBetween);
    
    %���վ������Ϣ���Ⱦ�Ļ��֣��õ�nBetween����ɢ�����ݵ�
    linex=interp1(dist,linex,dist2);
    liney=interp1(dist,liney,dist2);
    
    % Display the line piece����ʾ��Щ�����
    if(verbose),
        plot(liney,linex,'g*');
        plot(liney(1),linex(1),'r*');
        plot(liney(end),linex(end),'r*'); 
    end
    
    % Remove Point because it is also in the next line piece
    % ɾ�����ĵ㣬��Ϊ��Щ��Ҳ����һ���߶���
    if(j<length(i)-1)
        linex(end)=[]; 
        liney(end)=[];
    end
    
    % Add the evenly spaced line piece to the total line
    % �����еĵ�����ݽ��б���
    totalx=[totalx linex];
    totaly=[totaly liney];
end

% Also store the image ����ͼ��������Ϣ����
if(size(p.I,3)==3)
    I=double(p.I);
else
    I=p.I; 
end

if(verbose)
    drawnow('expose');
end
