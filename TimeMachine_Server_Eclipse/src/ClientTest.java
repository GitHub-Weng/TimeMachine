import java.awt.Color;
import java.awt.Container;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.FileOutputStream;

import javax.swing.Box;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.UIManager;

public class ClientTest extends JFrame implements ActionListener,Runnable{
	private JButton connection;
	private JButton uploadfile;
	private JButton stopconnection;
	private JTextField inputip;
	private JTextField input_uploadimagepath;
	private JTextField input_savapath;
	private static JTextArea showinfo;
	public JScrollPane scrollpane;
	
	
    private ClientSocket cs = null;   
    private int port = 8821;

    //设置字体格式
    private static void loadIndyFont()
    {
        UIManager.put("Panel.font", new java.awt.Font("宋体", 1, 15));
        UIManager.put("TextArea.font", new java.awt.Font("宋体", 1, 15));
        UIManager.put("TextField.font", new java.awt.Font("宋体", 1, 15));
        UIManager.put("Button.font", new java.awt.Font("宋体", 1, 15));
        UIManager.put("Label.font", new java.awt.Font("宋体", 1, 15));
        UIManager.put("ScrollPane.font", new java.awt.Font("宋体", 1, 15));
        
    //UIManager.put("CheckBox.font", new java.awt.Font("宋体", 0, 12));
    //UIManager.put("Tree.font", new java.awt.Font("宋体", 0, 12));
    //UIManager.put("Viewport.font", new java.awt.Font("宋体", 0, 12));
    //UIManager.put("ProgressBar.font", new java.awt.Font("宋体", 0, 12));
    //UIManager.put("RadioButtonMenuItem.font", new java.awt.Font("宋体", 0, 12));
    //UIManager.put("FormattedTextField.font", new java.awt.Font("宋体", 0, 12));
    //UIManager.put("ToolBar.font", new java.awt.Font("宋体", 0, 12));
    //UIManager.put("ColorChooser.font", new java.awt.Font("宋体", 0, 12));
    //UIManager.put("ToggleButton.font", new java.awt.Font("宋体", 0, 12));   
    //UIManager.put("Menu.font", new java.awt.Font("宋体", 0, 12));
    //UIManager.put("RadioButtonMenuItem.acceleratorFont", new java.awt.Font("宋体", 0, 12));
    //UIManager.put("Spinner.font", new java.awt.Font("宋体", 0, 12));
    //UIManager.put("Menu.acceleratorFont", new java.awt.Font("宋体", 0, 12));
    //UIManager.put("CheckBoxMenuItem.acceleratorFont", new java.awt.Font("宋体", 0, 12));
    //UIManager.put("TableHeader.font", new java.awt.Font("宋体", 0, 12));   
    // UIManager.put("OptionPane.font", new java.awt.Font("宋体", 0, 12));
    //UIManager.put("MenuBar.font", new java.awt.Font("宋体", 0, 12));

    //UIManager.put("PasswordField.font", new java.awt.Font("宋体", 0, 12));
    /*UIManager.put("InternalFrame.titleFont", new java.awt.Font("宋体", 0, 12));
    UIManager.put("OptionPane.buttonFont", new java.awt.Font("宋体", 0, 12));
    UIManager.put("MenuItem.font", new java.awt.Font("宋体", 0, 12));
    UIManager.put("ToolTip.font", new java.awt.Font("宋体", 0, 12));
    UIManager.put("List.font", new java.awt.Font("宋体", 0, 12));
    UIManager.put("OptionPane.messageFont", new java.awt.Font("宋体", 0, 12));
    UIManager.put("EditorPane.font", new java.awt.Font("宋体", 0, 12));
    UIManager.put("Table.font", new java.awt.Font("宋体", 0, 12));
    UIManager.put("TabbedPane.font", new java.awt.Font("宋体", 0, 12));
    UIManager.put("RadioButton.font", new java.awt.Font("宋体", 0, 12));
    UIManager.put("CheckBoxMenuItem.font", new java.awt.Font("宋体", 0, 12));
    UIManager.put("TextPane.font", new java.awt.Font("宋体", 0, 12));
    UIManager.put("PopupMenu.font", new java.awt.Font("宋体", 0, 12));
    UIManager.put("TitledBorder.font", new java.awt.Font("宋体", 0, 12));
    UIManager.put("ComboBox.font", new java.awt.Font("宋体", 0, 12));*/

    }
    
    //ClientTest构造函数，实现GUI
    public ClientTest(String s) {
    	super(s);
    	loadIndyFont();
    	connection = new JButton("连接服务器");
    	uploadfile = new JButton("上传并处理");
    	uploadfile.setEnabled(false);
    	stopconnection = new JButton("断开连接");
    	stopconnection.setEnabled(false);
    	
    	inputip = new JTextField("172.29.48.1", 1);
    	input_savapath =new JTextField("D:\\matlab_java_test/new1.jpg", 1);
        input_uploadimagepath = new JTextField("D:\\matlab_java_test/1.jpg", 1);
        showinfo = new JTextArea(15, 50);
        scrollpane = new JScrollPane(showinfo);
        
        Box boxv1 = Box.createHorizontalBox();
        Box boxv2 = Box.createHorizontalBox();
        Box boxv3 = Box.createHorizontalBox();
        Box boxv4 = Box.createHorizontalBox();
        Box boxbase = Box.createVerticalBox();
        
        boxv1.add(new JLabel("要连接的服务器的IP:   "));
        boxv1.add(inputip);
        boxv2.add(new JLabel("上传待处理图像:  "));
        boxv2.add(input_uploadimagepath);
        boxv3.add(new JLabel("保存处理后图像:  "));
        boxv3.add(input_savapath);
        boxv4.add(connection);
        boxv4.add(new JLabel("      "));
        boxv4.add(uploadfile);
        boxv4.add(new JLabel("      "));
        boxv4.add(stopconnection);
        boxbase.add(boxv1);
        boxbase.add(new JLabel(" "));
        boxbase.add(boxv2);
        boxbase.add(new JLabel(" "));
        boxbase.add(boxv3);
        
        boxbase.add(new JLabel(" "));
        
        boxbase.add(boxv4);
        boxbase.add(new JLabel(" "));

        Container con =new Container();
        con.setLayout(new FlowLayout());
        con.add(boxbase);       
        con.add(scrollpane);     
        add(con);
        
        
        setVisible(true);
        setSize(550,550);
        setLocationRelativeTo(getOwner());//窗口居中显示
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        showinfo.setCaretPosition(showinfo.getText().length());
        
        
        connection.addActionListener(this);
        uploadfile.addActionListener(this);
        stopconnection.addActionListener(this);
	
	}
    
    //创建Socket连接
	private boolean createConnection(String ip) {
        cs = new ClientSocket(ip, port);//要先运行服务器，不然会有异常出现，java.net.ConnectException

        try {
            cs.CreateConnection(); 
        } catch (Exception e) {
        	showinfo.append("连接服务器失败!" + "\n");
            return false;
        }
        
        showinfo.append("连接服务器成功!" + "\n");
        uploadfile.setEnabled(true);
        stopconnection.setEnabled(true);
        return true;

    }


    //从服务器接受文件
    private void getFilefromServer() {
    	int percent = 0;
        if (cs == null)
            return;
        DataInputStream inputStream = null;
        try {
            inputStream = cs.getMessageStream();
        } catch (Exception e) {
            System.out.print("接收消息缓存错误\n");
            return;
        }

        try {
            //本地保存路径，文件名会自动从服务器端继承而来。
            String savePath = input_savapath.getText().trim();
            int bufferSize = 8192;
            byte[] buf = new byte[bufferSize];
            int passedlen = 0;
            long len=0;
            len = inputStream.readLong();
            
            
            DataOutputStream fileOut = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(savePath)));

            ClientTest.showinfomation("图片经过服务器处理后文件大小为:" + len + "Bytes\n");
            ClientTest.showinfomation("开始接收文件!" + "\n");
                    
            while (true) {
                int read = 0;
                if (inputStream != null) {
                    read = inputStream.read(buf);
                }
                passedlen += read;
                percent = (int) (passedlen * 100/ len);
                if (percent == 100) {
                    break;
                }
                //下面进度条本为图形界面的prograssBar做的，这里如果是打文件，可能会重复打印出一些相同的百分比
                ClientTest.showinfomation("从服务器接收了" +  percent + "%\n");
                fileOut.write(buf, 0, read);
            }
            ClientTest.showinfomation("从服务器接收图片成功!"+ "\n"+"文件存为" + savePath + "\n");

            fileOut.close();
        } catch (Exception e) {
            System.out.println("接收来自服务端的消息发生了错误" + "\n");
            return;
        }
    }

    public static void main(String arg[]) {
    	new ClientTest("图像灰度化");

    
    }
    
    public static void  showinfomation(String s){
    	 showinfo.append(s+"\n");
    }
	@Override
	public void run() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		// TODO Auto-generated method stub
		if(e.getSource()==connection){
			 try {
		          createConnection(inputip.getText().trim());
		          new Thread().start();
		          
		        } catch (Exception ex) {
		            ex.printStackTrace();
		        }
		}
		else if(e.getSource()==stopconnection){
			cs.shutDownConnection();
		}
		else if(e.getSource()==uploadfile){
            //sendMessage();
            //getMessage();
			//发送消息
		  
		    if (cs == null)
		        return;
		    try {  
		           cs.sendFile(input_uploadimagepath.getText().trim());
		           
		        } catch (Exception e_uploadfile) {
		        	e_uploadfile.printStackTrace();
		        	showinfo.append("发送文件失败!" + "\n");
		        	
		        }
		    
		    
		    try {
		    	
		    	getFilefromServer();
		    }catch (Exception e_getfilefromserver) {
		    	e_getfilefromserver.printStackTrace();
	        	showinfo.append("接收文件失败!" + "\n");
	        	
	        }
		   
		}
	}
}