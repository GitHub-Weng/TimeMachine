function train(train_set_size)
num = train_set_size;
for i = 1:num
    p = struct;
    p.n = 68;
    is=num2str(i); number = '000'; number(end-length(is)+1:end)=is; 
    filename=['Fotos\train' number '.lmk'];
    outputname =['Fotos\train' number '.mat'];
    picname =['Fotos\train' number '.JPG'];
    apoints = load(filename);
    p.x = apoints(:,2)';
    p.y = apoints(:,1)';
    p.I = imread(picname);
    p.t = zeros(1,68);
%     p.t = p.t+2;
%     for j = 28:38
%         p.t(j)=0;
%     end
%     for j = 43:47
%         p.t(j)=0;
%     end
%     for j = 64:68
%         p.t(j)=0;
%     end
    save(outputname,'p');
end
