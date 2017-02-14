package com.example.wengdada.timemachine2;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.Socket;
import java.net.SocketAddress;

/**
 * Created by Wengdada on 2016/9/6.
 */
public class MySocket extends Thread{

    protected String ip;
    private int port;
    private String uploadfilepath;
    private String savepath;
    private Socket socket = null;
    private DataOutputStream out = null;
    private DataInputStream getMessageStream = null;
    private File file = null;
    private FileOutputStream fops = null;
    private FileInputStream fips = null;
    private String TAG = "MySocket";
    private int percent = 0;
    public static boolean TASKFINISH ;



    //Socket线程，传入ip和端口号
    public MySocket(String ip, int port,String uploadfilepath,String savepath) {
        this.ip = ip;
        this.port = port;
        this.uploadfilepath = uploadfilepath;
        this.savepath = savepath;
        //Log.i(TAG,"INITIAL");
    }




    /**
     * 创建socket连接
     */

    public void CreateConnection() throws Exception {
        try {

            socket = new Socket(ip, port);
            //socket = new Socket("timemachine.nat123.net",20106);
        } catch (Exception e) {
            throw e;
        }
      if(socket.isConnected()){
            Log.i(TAG,"SOCKET SUCCESS");
        }
        else
            Log.i(TAG,"SOCKET FAIL");

    }


    //将待处理的图像发送给服务器端
    public void sendFile(String filepath) throws Exception {
        Log.i(TAG,"sendFile");
        file = new File(filepath);

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
                    break;
                }

                filewriteout.write(buffer, 0, read);

            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {

        }

    }

    //从服务器获取处理后的文件并保存在相应的文件夹
    public void getMessageStream(String savepath){
        Log.i(TAG,"getMessageStream");

        try {
            //利用Socket从服务器得到输入流DataInputStream
            //getMessageStream = new DataInputStream(new BufferedInputStream(socket.getInputStream()));

            //本地保存路径，文件名会自动从服务器端继承而来。
            String savePath = savepath;
            int passedlen = 0;
            try {

                DataInputStream dataInput = new DataInputStream(socket.getInputStream());
                int size = dataInput.readInt();
                byte[] data = new byte[size];
                int len = 0;
                while (len < size) {
                    len += dataInput.read(data, len, size - len);

                    percent = (int) (len * 100/ size);
                    if (percent == 100) {
                        Log.i(TAG,"recieve percent = 100");
                        break;
                    }
                }

                FileOutputStream m_fileOutPutStream = null;
                try {
                    m_fileOutPutStream= new FileOutputStream(savePath);
                }
                catch (FileNotFoundException e) {
                    e.printStackTrace();
                }

                Bitmap bmp = BitmapFactory.decodeByteArray(data, 0, data.length);
                bmp.compress(Bitmap.CompressFormat.PNG, 100, m_fileOutPutStream);

                try {
                    m_fileOutPutStream.flush();
                    m_fileOutPutStream.close();
                    Log.i(TAG,"save recieve_file done!");
                }

                catch (IOException e) {
                    e.printStackTrace();
                }
                //imageView.setImageBitmap(bmp);

                //Bitmap bitmap = BitmapFactory.decodeStream(dataInput);
                //myHandler.obtainMessage().sendToTarget();
            } catch (IOException e) {
                e.printStackTrace();
            }


           /* while (true) {
                int read = 0;
                if (getMessageStream != null) {
                    read = getMessageStream.read(buf);
                }


                //下面进度条本为图形界面的prograssBar做的，这里如果是打文件，可能会重复打印出一些相同的百分比
                //ClientTest.showinfomation("从服务器接收了" +  percent + "%\n");

                //将字节流存储到相应的文件
                fileOut.write(buf, 0, read);


            }*/

           // fileOut.close();
        } catch (Exception e) {
        }

    }



    //断开与服务器的连接
    public void shutDownConnection() {
        Log.i(TAG,"shutDownConnection");
        try {
            if (socket != null)
                socket.close();
        } catch (Exception e) {

        }
    }


    @Override
    public void run() {

        Log.i(TAG,"RUN");
        try {
            TASKFINISH = false;
            CreateConnection();
            sendFile(uploadfilepath);
            getMessageStream(savepath);
            shutDownConnection();
            TASKFINISH =true;

        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public Bitmap getBitmapFromByte(byte[] temp){
        if(temp != null){
            Bitmap bitmap = BitmapFactory.decodeByteArray(temp, 0, temp.length);
            return bitmap;
        }else{
            return null;
        }
    }

    //只能够在同一个类中有用
/*    public Handler handler =new Handler(){
       public void handleMessage(Message msg){
        switch (msg.what){
            case UpLoad.SOCKETDONE:
                //只要执行到这里就关闭对话框
               Log.i(TAG,"thread handler");
                break;

        }
    }
};*/



}
