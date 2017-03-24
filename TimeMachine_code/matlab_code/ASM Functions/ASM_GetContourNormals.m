function [nx,ny]=ASM_GetContourNormals(xt,yt)
%功能：对于每个样本图像，对应于每个特征点以前后的特征点做为参考点，计算x与y方向上的
%      导数，并进行归一化处理
% This function calculates the normals, of the contour points
% using the neighbouring points of each contour point, and 
% forward an backward differences on the end points
%
% [nx,ny]=GetContourNormals(xt,yt)

% Derivatives of contour
dx=[xt(2)-xt(1) (xt(3:end)-xt(1:end-2))/2 xt(end)-xt(end-1)];
dy=[yt(2)-yt(1) (yt(3:end)-yt(1:end-2))/2 yt(end)-yt(end-1)];
% Normals of contourpoints
l=sqrt(dx.^2+dy.^2);
nx = -dy./l; 
ny =  dx./l;
