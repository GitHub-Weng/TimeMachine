function [ output_args ] = Socket( input_args )
%SOCKET �˴���ʾ�йش˺�����ժҪ
%%
% 
%  PREFORMATTED
%  TEXT
% 
%   �˴���ʾ��ϸ˵��
while(true)
    t = tcpip('192.168.43.225', 50000, 'NetworkRole', 'server');
    %Open a connection. This will not return until a connection is received.
    
    fopen(t);
    data='SUCCESS';
    %data=rgbtogray('D:\matlab_java_result\')
    %Read the waveform and confirm it visually by plotting it.
    fwrite(t, data);
    fclose(t);
    status=main();
    fprintf('%s status:\n',status);% ��ʾͼ������
end    
    
    

end

