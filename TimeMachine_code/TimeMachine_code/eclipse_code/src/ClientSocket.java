import java.net.*;
import java.io.*;

public class ClientSocket {
    private String ip;
    private int port;
    private Socket socket = null;
    private DataOutputStream out = null;
    private DataInputStream getMessageStream = null;
    private File file = null;
    private FileOutputStream fops = null;
    private FileInputStream fips = null;
    
    public ClientSocket(String ip, int port) {
        this.ip = ip;
        this.port = port;
    }

    /**
     * 创建socket连接
     */
    public void CreateConnection() throws Exception {
        try {
        	 //socket = new Socket("timemachine.nat123.net",20106);
           socket = new Socket(ip, port);
        } catch (Exception e) {
            throw e;
        } finally {
        }
    }
 
    //将待处理的图像发送给服务器端
    public void sendFile(String filepath) throws Exception {
    	file = new File(filepath);
    	ClientTest.showinfomation("传送给服务器的文件的名称："+"\n"+file.toString()+"\n");
    	ClientTest.showinfomation("传送的文件大小为:" + file.length()+"Bytes"+"\n");
    	DataOutputStream filewriteout = null;
    	DataInputStream filereadin = null;
        try {
            filereadin = new DataInputStream(new BufferedInputStream(new FileInputStream(filepath)));
            filewriteout= new DataOutputStream(socket.getOutputStream());
            
            //将待发送的文件的文件名和大小发送给服务器          
            filewriteout.writeUTF(file.getName());//知识将图像的名字写进去，没有包括目录
            filewriteout.flush();
            filewriteout.writeLong(file.length());
            filewriteout.flush();
            
            //将待发送的文件读到buffer中，并将buffer发送到服务器
            byte buffer[]=new byte[8192];
            while(true){
            	
            	int read = -1 ;
            	if(filereadin!=null){
            		read = filereadin.read(buffer);
            		
            	}
            	
            	if(read == -1){//if(read ==-1)
            		filereadin.close();
            		ClientTest.showinfomation("客户端传输文件给服务器完成！"+"\n"+"\n");
            		break;
            	}
            	
            	filewriteout.write(buffer, 0, read);
            
            }
            
        } catch (Exception e) {
            e.printStackTrace();       
        } finally {
    	
        }
        
    }

    
    
    public DataInputStream getMessageStream(){
        try {
            getMessageStream = new DataInputStream(new BufferedInputStream(socket.getInputStream()));
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
        }
		return getMessageStream;
    }

    public void shutDownConnection() {
        try {
        
            if (socket != null)
                socket.close();
            ClientTest.showinfomation("已经与服务器断开连接！");
        } catch (Exception e) {

        }
    }
}