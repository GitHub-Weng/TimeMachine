  CG = rgb2gray(C);
[CC,CS] = wavedec2(CG,2,'sym4');
 FG= rgb2gray(F);
[FC,FS] = wavedec2(FG,2,'sym4');
for i =1:CS(1,1)*CS(1,2)
    FC(i)=CC(i);
end
RC = waverec2(FC,CS,'sym4');
imshow(RC/256);
figure;
imshow(F);

