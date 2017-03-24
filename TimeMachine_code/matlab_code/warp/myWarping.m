
function [] = myWarping(sourceImage, targetImage, source_lmk,target_lmk, num_points, alpha,times)
% warp the source image to a target using a mesh-based warping method.
% sourceImage: RGB format input source image
% targetImage: RGB format input target image which has the same size with source image
% num_points: number of feature points
% alpha: coefficient 
%        alpha = 1 --> output = target image laoren
%        alpha = 0 --> output = spurce image nianqing
%        times:´ÎÊý£»


height = size(sourceImage,1);
width = size(sourceImage,2);
alpha = 1-alpha;
height2 = size(targetImage,1);
width2 = size(targetImage,2);
sourceImage = imresize(sourceImage,[height2 width2]);
 if(height~=height2 || width~=width2)       
     sourceImage=imresize(sourceImage,[size(targetImage,1),size(targetImage,2)]);
 end
if(num_points <= 0)
    error('Invalid input.')
end

% mark feature points on source image  nianqing
apoints = load(source_lmk);
xA = apoints(:,1);
yA = apoints(:,2);
xA = [xA;1;width;width;1];
yA = [yA;1;1;height;height];
% mark feature points on target image
bpoints = load(target_lmk');
xB = bpoints(:,1);
yB = bpoints(:,2);
xB = [xB;1;width;width;1];
yB = [yB;1;1;height;height];

% create a intermediate grid
C = zeros(height,width,3);
xC = alpha*xA + (1-alpha)*xB;
yC = alpha*yA + (1-alpha)*yB;
triC = delaunay(xC,yC);
ntri = size(triC,1);

% allocate memory for x, y coordinators
xCA = zeros(height,width);
yCA = zeros(height,width);
xCB = zeros(height,width);
yCB = zeros(height,width);
[X,Y] = meshgrid(1:width,1:height);

% warp the intermediate grid to source and target grid
for k = 1:ntri
	[w1,w2,w3,r] = inTri(X, Y, xC(triC(k,1)), yC(triC(k,1)), xC(triC(k,2)), yC(triC(k,2)), xC(triC(k,3)), yC(triC(k,3)));
	w1(~r)=0;
	w2(~r)=0;
	w3(~r)=0;
	xCA = xCA + w1.*xA(triC(k,1)) + w2.*xA(triC(k,2)) + w3.*xA(triC(k,3));
	yCA = yCA + w1.*yA(triC(k,1)) + w2.*yA(triC(k,2)) + w3.*yA(triC(k,3));
	xCB = xCB + w1.*xB(triC(k,1)) + w2.*xB(triC(k,2)) + w3.*xB(triC(k,3));
	yCB = yCB + w1.*yB(triC(k,1)) + w2.*yB(triC(k,2)) + w3.*yB(triC(k,3));
end

% interpolate each point by using 'interp2' function 
VCA(:,:,1) = interp2(X,Y,double(sourceImage(:,:,1)),xCA,yCA);
VCA(:,:,2) = interp2(X,Y,double(sourceImage(:,:,2)),xCA,yCA);
VCA(:,:,3) = interp2(X,Y,double(sourceImage(:,:,3)),xCA,yCA);

VCB(:,:,1) = interp2(X,Y,double(targetImage(:,:,1)),xCB,yCB);
VCB(:,:,2) = interp2(X,Y,double(targetImage(:,:,2)),xCB,yCB);
VCB(:,:,3) = interp2(X,Y,double(targetImage(:,:,3)),xCB,yCB);

% cross-dissolve 
C = alpha*VCA + (1-alpha)*VCB;

% convert double to uint8 format and display
% imshow(uint8(C));
% imwrite(uint8(C),strcat('results\result',num2str(times),'.jpg'));
imwrite(uint8(C),strcat('D:\matlab_java_test\','result',num2str(times),'.jpg'));
end

function [w1,w2,w3,r] = inTri(vx, vy, v0x, v0y, v1x, v1y, v2x, v2y)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inTri checks whether input points (vx, vy) are in a triangle whose
% vertices are (v0x, v0y), (v1x, v1y) and (v2x, v2y) and returns the linear
% combination weight, i.e., vx = w1*v0x + w2*v1x + w3*v2x and
% vy = w1*v0y + w2*v1y + w3*v2y. If a point is in the triangle, the
% corresponding r will be 1 and otherwise 0.
%
% This function accepts multiple point inputs, e.g., for two points (1,2),
% (20,30), vx = (1, 20) and vy = (2, 30). In this case, w1, w2, w3 and r will
% be vectors. The function only accepts the vertices of one triangle.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v0x = repmat(v0x, size(vx,1), size(vx,2));
    v0y = repmat(v0y, size(vx,1), size(vx,2));
    v1x = repmat(v1x, size(vx,1), size(vx,2));
    v1y = repmat(v1y, size(vx,1), size(vx,2));
    v2x = repmat(v2x, size(vx,1), size(vx,2));
    v2y = repmat(v2y, size(vx,1), size(vx,2));
    w1 = ((vx-v2x).*(v1y-v2y) - (vy-v2y).*(v1x-v2x))./...
    ((v0x-v2x).*(v1y-v2y) - (v0y-v2y).*(v1x-v2x)+eps);
    w2 = ((vx-v2x).*(v0y-v2y) - (vy-v2y).*(v0x-v2x))./...
    ((v1x-v2x).*(v0y-v2y) - (v1y-v2y).*(v0x-v2x)+eps);
    w3 = 1 - w1 - w2;
    r = (w1>=0) & (w2>=0) & (w3>=0) & (w1<=1) & (w2<=1) & (w3<=1);
end
