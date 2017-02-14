import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.ServerSocket;
import java.net.Socket;





public class ServerTest{
    private int port = 8821;
    private Socket s = null;
    
    
    void serverStart() 
    {
       int ii=0;
       while (true) 
       {
           try {
        	   
            	ServerSocket ss = new ServerSocket(port);
            	System.out.println("正在监听：");
            
                s = ss.accept();
                System.out.println("建立socket链接");
                
                
           } catch(Exception eee){}
                
                if(s!=null){
                			
	                  ServerRecieveThread thread=new ServerRecieveThread(s);
	                  
	            	  thread.run();//这里不能用.start(),不然后面的
	            	  continue;
				
                  

            	}
               
        
         }
      }
    
    

    public static void main(String arg[]) {
        new ServerTest().serverStart();
    }
}
    
     

 