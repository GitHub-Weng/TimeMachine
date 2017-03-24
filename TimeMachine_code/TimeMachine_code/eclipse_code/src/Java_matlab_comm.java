import java.io.DataInputStream;
import java.io.IOException;
import java.net.Socket;
import java.net.UnknownHostException;

public class Java_matlab_comm {
	
	private Socket socket;
	public  static boolean finish = false;

	public static void changefinish(){
		finish=true;
		System.out.println("change finish success，finish is "+ finish);
		ServerRecieveThread.readytosend = true;
		System.out.println("ready to send  "+ ServerRecieveThread.readytosend);
		

	}
	public boolean getfinish(){
		return finish;
	}
	public void communication(){
    
    
    
	try {
		
		socket = new Socket("192.168.43.225",50000);
		final DataInputStream in = new DataInputStream(socket.getInputStream());
		
	    Thread thread= new Thread(new Runnable() {
			
			@Override
			public void run() {
				int i;
				try {
					i=in.read();
					if( i>0){
						//finish = true;//这里并没有改掉finish
						Java_matlab_comm.changefinish();
						
	                }
	                else{
	        	        System.out.println("null");
	                }
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				// TODO Auto-generated method stub

			}
		});
	    
	    
	    thread.start();
	} catch (UnknownHostException e1) {
		// TODO Auto-generated catch block
		e1.printStackTrace();
	} catch (IOException e1) {
		// TODO Auto-generated catch block
		e1.printStackTrace();
	}   
     
	
    
 } 


}
