function train(train_set_size)
num = train_set_size;
for i = 1:num
    p = struct;
    p.n = 68;
    is=num2str(i); number = '00000'; number(end-length(is)+1:end)=is; 
    filename=['Fotos\train' number '.pts'];
    [x,y]=loadpts(filename);
    outputname =['Fotos\train' number '.mat'];
    picname =['Fotos\train' number '.JPG'];
    p.x = y';
    p.y = x';
    p.I = imread(picname);
    p.t = zeros(1,68);
%     p.t = p.t+2;
    for j = 1:16
        p.t(j)=2;
    end
%     for j = 43:47
%         p.t(j)=0;
%     end
%     for j = 64:68
%         p.t(j)=0;
%     end
    save(outputname,'p');
end
