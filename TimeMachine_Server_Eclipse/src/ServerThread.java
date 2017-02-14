import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.Vector;



class DealMatlab implements Runnable{
	public final static String SAVEPATH = "D:\\matlab_java_result/";
	public final static String GiveClientPATH="D:\\matlab_java_test/";
	public final static int bufferSize= 8192;
    private String recifilename;
    private int image_num;
    DealMatlab(String s,int num){
    	recifilename = s;
    	image_num = num;
    }
    
    

	@Override
	public void run() {
		
        Java_matlab_comm callmatlab = new Java_matlab_comm();
        callmatlab.communication();
        while(true){
    		
    		//System.out.println("waiting,dealing picture...");
    		try {
				Thread.sleep(500);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
    		//不加这句输出会有问题，虽然getfinish()得到true,但一直不会执行
    		
    		
    		
    		boolean aaa=false;
    		aaa=callmatlab.getfinish();
    		if(aaa==true){
    			System.out.println("task finish");
    		    break;
    		}
    	}
    	System.out.println("everything is ok");
    	
		// 调用matlab jar包
    	/*Matlab matlab = null;
		try {
			matlab = new Matlab();
			matlab.rgbtogray(recifilename,image_num);
		} catch (MWException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}          	*/
		
	}
	
}
class ServerRecieveThread extends Thread{
	public static boolean readytosend = false;
	private  Socket s=null;
	
	public static int image_num=0;
    public ServerRecieveThread(Socket s){
       this.s = s;
       image_num++;
    }
    
    public String[] getRecieveImageName(String savepath){
    	File mFile = new File(savepath);
        File [] files = mFile.listFiles();
        Vector<String> imagefile = new Vector<String>();
        
        for (File file : files) {
        	String fileName=file.getName();
        if (fileName.endsWith(".jpg") || fileName.endsWith(".png")
                || fileName.endsWith(".gif"))
        	imagefile.addElement(savepath+fileName);
        }
        
        int num=imagefile.size();
        String imagefilename[]=new String[num];
        for(int i=0;i<num;i++){
        	imagefilename[i]=imagefile.get(i);
        	
        }
        
       
        
        
        return imagefilename;
    	
    }

    //服务器端用于发送多张图片给客户端
    public  void sendFile(String filepath[]) throws Exception {
    	int sendfilenumber = filepath.length;
    	
    	for (String string : filepath) {
			System.out.println(string);
		}
    	
    	for(int k=0;k<filepath.length;k++){
    	File file = new File(filepath[k]);
    	System.out.println("传送给客户端的文件的名称："+file.toString());
    	System.out.println("待传文件长度:" + file.length());
    	DataOutputStream filewriteout = null;
    	DataInputStream filereadin = null;
    	
        try {
            filereadin = new DataInputStream(new BufferedInputStream(new FileInputStream(file)));
            filewriteout= new DataOutputStream(s.getOutputStream());
            
            filewriteout.writeInt((int) --sendfilenumber);
            filewriteout.writeInt((int) file.length());
            System.out.println("file.length()"+file.length());
            filewriteout.flush();
            
            //将待发送的文件读到buffer中，并将buffer发送到服务器
            byte buffer[]=new byte[DealMatlab.bufferSize];
            //byte buffer[]=new byte[20000];
            while(true){
            	
            	int read = -1 ;
            	if(filereadin!=null){
            		read = filereadin.read(buffer);
            		
            	}
    
            	if(read == -1){//if(read ==-1)
            		filereadin.close();
            		System.out.println("服务器传输给客户端文件完成！");
            		break;
            	}
            	
            	filewriteout.write(buffer, 0, read);
            
            }
            
        } catch (Exception e) {
            //e.printStackTrace();       
        } finally {
    	
        }
      }
    }
    
    
    
    
    ////////////////////////////////服务器接收来自客户端的文件并将其存储
	public void run() {
		DataInputStream inputStream = null;  
		DataOutputStream fileOut =null;
		int percent = 0;
		int starttask=0;
		// TODO Auto-generated method stub
        try {
        	 	
            //本地保存路径，文件名会自动从服务器端继承而来。
            String savePath = DealMatlab.SAVEPATH;
            
           
            String recifilename = null;
            byte[] buf = new byte[DealMatlab.bufferSize];
            int passedlen = 0;
            long len=0;
          
               
            inputStream = new DataInputStream(s.getInputStream());
 
            recifilename = savePath + inputStream.readUTF();
            String saveasname=savePath+"temp.jpg";
            len = inputStream.readLong();
            System.out.println(recifilename);

            fileOut = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(saveasname)));

            System.out.println("文件的长度为:" + len + "\n");
            System.out.println("开始接收文件!" + "\n");
                    
            while (true) {
            	
            	/////服务器接受客户端的图片
                int read = -1;
                
                if (percent == 100) {
                	starttask=1;
                    break;
                }
                
                if (inputStream != null) {
                    read = inputStream.read(buf);
                }
                if(read == -1){
                	break;//不知道为什么总是不会read==-1;和流有什么关系么，这里暂且用偷懒的方法判断percent == 100
                }
                passedlen += read;
              
                //下面进度条本为图形界面的prograssBar做的，这里如果是打文件，可能会重复打印出一些相同的百分比
                fileOut.write(buf, 0, read);
                percent = (int) (passedlen * 100/ len);
                System.out.println("文件接收了" + percent+"%\n");
                
                
            }
            fileOut.close();
            System.out.println("从客户端接收图片成功，文件存为:" + recifilename);
            

            
            /////////////////////服务端将图像处理之后重新发给客户端
        	//Matlab matlab = new Matlab();          	
			//matlab.rgbtogray(recifilename,image_num);
            
        	
        	
        	
            if(starttask == 1){
            	System.out.println("start to deal");
            	//不能用start（）这一步是要根据下一步完成之后才可以进行的
                new DealMatlab(recifilename, image_num).run();
            }
            
            
            
        	String sendfilename = "D:\\matlab_java_test/"+"newtemp"+".png";
        	System.out.println("the file want to send is "+sendfilename);
        	//String savePath = "D:\\matlab_java_result/";
    		sendFile(getRecieveImageName(DealMatlab.GiveClientPATH));
            


            
        } catch (Exception e) {
        	e.printStackTrace();
            
            return;
        }
        
      }
 }
