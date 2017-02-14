package com.example.wengdada.timemachine2;

import android.app.ProgressDialog;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.ImageView;
import android.widget.Toast;

public class Template extends AppCompatActivity {

	private ImageView mImageView8;
	private ImageView mImageView3;
	private ImageView mImageView4;
	private ImageView mImageView5;
	private ImageView mImageView6;
	private ImageView mImageView7;
	private ProgressDialog mProgressDialog;
    private ButtonListener imagebuttonlistener;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_template);
		imagebuttonlistener=new ButtonListener();
		findbyID();
		OnClick();

	}

	private void OnClick(){
		mImageView8.setOnClickListener(imagebuttonlistener);
		mImageView7.setOnClickListener(imagebuttonlistener);
		mImageView6.setOnClickListener(imagebuttonlistener);
		mImageView5.setOnClickListener(imagebuttonlistener);
		mImageView4.setOnClickListener(imagebuttonlistener);
		mImageView3.setOnClickListener(imagebuttonlistener);

	}

	private void findbyID() {
		mImageView8=(ImageView)findViewById(R.id.imageView_cloth8);
		mImageView7=(ImageView)findViewById(R.id.imageView_cloth7);
		mImageView6=(ImageView)findViewById(R.id.imageView_cloth6);
		mImageView5=(ImageView)findViewById(R.id.imageView_cloth5);
		mImageView4=(ImageView)findViewById(R.id.imageView_cloth4);
		mImageView3=(ImageView)findViewById(R.id.imageView_cloth3);
	}

	private Handler handler =new Handler(){

		//当有消息发送出来的时候就执行Handler的这个方法
		public void handleMessage(Message msg){
			super.handleMessage(msg);
			//只要执行到这里就关闭对话框
			mProgressDialog.dismiss();
			Toast.makeText(Template.this,"成功应用", Toast.LENGTH_SHORT);
		}
	};

	private class ButtonListener implements View.OnClickListener{

		@Override
		public void onClick(View v) {
			mProgressDialog = new ProgressDialog(Template.this);
			mProgressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
			mProgressDialog.setMessage("正在应用所选模板");
			mProgressDialog.show();
			Thread thread=new Thread(new Runnable() {
				@Override
				public void run() {
					try {
						Thread.sleep(4000);
						//执行完毕后给handler发送一个消息

					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					handler.sendEmptyMessage(0);
				}
			});
			thread.start();


		}
	}


}
