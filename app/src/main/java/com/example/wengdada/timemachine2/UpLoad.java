package com.example.wengdada.timemachine2;

import android.app.ProgressDialog;
import android.content.ContentResolver;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.icu.text.IDNA;
import android.net.Uri;
import android.nfc.Tag;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UpLoad extends AppCompatActivity implements AdapterView.OnItemClickListener ,View.OnClickListener{
	private TextView tvupload;
	private ImageView mImageView;
	private ImageView mImageButton2;
	private ImageView mImageButton3;
	private ProgressDialog mProgressDialog;
	private static final int FILE_FLAG = 100;
	private static final int CAMERA_FLAG = 200;
	private String dirString;
	private String Tag = "upload";
	private String savepath;


	private GridView gridView;
	private SimpleAdapter adapter;
	private List<Map<String, Object>> dataList;


	public static final int RECIEVEDONE = 1;
	public Handler handler = new Handler() {

		//当有消息发送出来的时候就执行Handler的这个方法
		public void handleMessage(Message msg) {

			switch (msg.what) {
				case RECIEVEDONE:
					Log.i(Tag, "recieve handler");
					//只要执行到这里就关闭对话框
					mProgressDialog.dismiss();
					dialog();


					String myJpgPath = savepath;
					BitmapFactory.Options options = new BitmapFactory.Options();
					options.inSampleSize = 2;
					Bitmap bm = BitmapFactory.decodeFile(myJpgPath, options);
					mImageView.setImageBitmap(bm);

					break;

			}


		}
	};

	private List<Map<String, Object>> getData() {
		int[] drawable = {R.drawable.loacalweng, R.drawable.cameraweng, R.drawable.choiceweng, R.drawable.shareweng};

		String[] iconName = {"本地", "拍照", "处理", "分享"};
		for (int i = 0; i < drawable.length; i++) {
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("pic", drawable[i]);
			map.put("name", iconName[i]);
			dataList.add(map);
		}
		Log.i("Main", "size=" + dataList.size());
		return dataList;
	}


	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_up_load);


		//requestWindowFeature(Window.FEATURE_NO_TITLE);
		dirString = Environment.getExternalStorageDirectory() + File.separator + "TimeMachine";
		final File dirfile = new File(dirString);
		if (!dirfile.exists())
			dirfile.mkdir();


		gridView = (GridView) findViewById(R.id.gridView);
		dataList = new ArrayList<Map<String, Object>>();
		adapter = new SimpleAdapter(this, getData(), R.layout.item, new String[]{"pic", "name"}, new int[]{R.id.pic, R.id.name});
		gridView.setAdapter(adapter);


		gridView.setOnItemClickListener(this);


		findbyID();


	}


	private void findbyID() {
		mImageView = (ImageView) findViewById(R.id.imageView);
	}

	//打开相册或者摄像头
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == FILE_FLAG) {
			if (resultCode == RESULT_OK) {
				Uri uri = data.getData();
				Log.e("uri", uri.toString());
				ContentResolver cr = this.getContentResolver();
				try {
					Bitmap bitmap = BitmapFactory.decodeStream(cr.openInputStream(uri));
				/* 将Bitmap设定到ImageView */
					mImageView.setImageBitmap(bitmap);
				} catch (FileNotFoundException e) {
					Log.e("Exception", e.getMessage(), e);
				}
			} else if (resultCode == RESULT_CANCELED) {
				Toast.makeText(UpLoad.this, "打开照片未成功", Toast.LENGTH_SHORT).show();
			}
		} else if (requestCode == CAMERA_FLAG) {
			if (resultCode == RESULT_OK) {
				Bitmap bitmap = (Bitmap) data.getExtras().get("data");
				mImageView.setImageBitmap(bitmap);
			} else if (resultCode == RESULT_CANCELED) {
				Toast.makeText(UpLoad.this, "拍照片未成功", Toast.LENGTH_SHORT).show();
			}

		}
		super.onActivityResult(requestCode, resultCode, data);
	}

	protected void dialog() {
		AlertDialog.Builder builder = new AlertDialog.Builder(UpLoad.this);
		builder.setMessage("播放生成的视频么？");
		builder.setTitle("提示");
		builder.setPositiveButton("先睹为快", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
				Intent intent = new Intent(UpLoad.this, Video_Display.class);
				startActivity(intent);
			}
		});
		builder.setNegativeButton("来日方长", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});
		builder.create().show();
	}


	Thread mThread = new Thread(new Runnable() {
		@Override
		public void run() {
			while (true) {
				if (MySocket.TASKFINISH) {
					Message message = new Message();
					message.what = RECIEVEDONE;
					handler.sendMessage(message);
					break;

				}
			}
		}
	});


	@Override
	public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
		switch (i) {
			case 0: {
				Intent intent = new Intent();
		        /* 开启Pictures画面Type设定为image */
				intent.setType("image/*");
		        /* 使用Intent.ACTION_GET_CONTENT这个Action */
				intent.setAction(Intent.ACTION_GET_CONTENT);
		        /* 取得相片后返回本画面 */
				startActivityForResult(intent, FILE_FLAG);
				break;

			}
			case 1: {
				Intent capIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
				startActivityForResult(capIntent, CAMERA_FLAG);
				break;
			}
			case 2: {
				if (mImageView.getDrawable() != null) {


					mProgressDialog = new ProgressDialog(UpLoad.this);
					mProgressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
					mProgressDialog.setMessage("处理图片中，请稍后...");
					mProgressDialog.show();

					mImageView.setDrawingCacheEnabled(true);
					Bitmap bitmap = Bitmap.createBitmap(mImageView.getDrawingCache());
					FileOutputStream m_fileOutPutStream = null;

					SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
					String date = simpleDateFormat.format(new java.util.Date());
					String filepath = dirString + File.separator + "temp" + ".png";
					savepath = dirString + File.separator + "result" + ".png";

					try {
						m_fileOutPutStream = new FileOutputStream(filepath);
					} catch (FileNotFoundException e) {
						e.printStackTrace();
					}
					bitmap.compress(Bitmap.CompressFormat.PNG, 100, m_fileOutPutStream);

					try {
						m_fileOutPutStream.flush();
						m_fileOutPutStream.close();
					} catch (IOException e) {
						e.printStackTrace();
					}

					//new MySocket("timemachine.nat123.net",20106,filepath,savepath).start();//nat123
					new MySocket("172.29.48.1", 8821, filepath, savepath).start();//Inside internet
					mThread.start();
					Log.i(Tag, "do newMySocket");
					//handler.sendEmptyMessage(0);
				} else {
					Toast.makeText(UpLoad.this, "上传内容为空", Toast.LENGTH_SHORT).show();
				}
				break;
			}
			case 3: {
				showShareDialog();
			}
		}
	}

	public void shareMultipleImage() {
		ArrayList<Uri> uriList = new ArrayList<>();

		String path = Environment.getExternalStorageDirectory() + File.separator;
		uriList.add(Uri.fromFile(new File(savepath)));
		//uriList.add(Uri.fromFile(new File(path+"australia_2.jpg")));
		//uriList.add(Uri.fromFile(new File(path+"australia_3.jpg")));

		Intent shareIntent = new Intent();
		shareIntent.setAction(Intent.ACTION_SEND_MULTIPLE);
		shareIntent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, uriList);
		shareIntent.setType("image/*");
		//shareIntent.setType("video/*");
		startActivity(Intent.createChooser(shareIntent, "分享到"));
	}

	private void showShareDialog() {
		LayoutInflater inflater = LayoutInflater.from(this);
		View view = inflater.inflate(R.layout.dialog_layout, null);

		//Creates a builder for an alert dialog that uses the default alert dialog theme.
		AlertDialog.Builder builder = new AlertDialog.Builder(this);

		builder.setTitle("选择分享形式");//设置标题
		builder.setIcon(R.drawable.share1);//设置图标
		builder.setView(view);
		AlertDialog dialog = builder.create();//获取dialog
		dialog.show();//显示对话框


       /*在MainActivity中弹出对话框
		因为对话框是在activity上显示的，
		所以对话框上的按钮不能直接findViewById,这样是找不到的，
		需先获得dialog的window，再通过window去findViewById
		http://blog.csdn.net/jiayite/article/details/51737922
		* */

		Window window = dialog.getWindow();
		mImageButton2 = (ImageButton) window.findViewById(R.id.imageButtongif);
		mImageButton3 = (ImageButton) window.findViewById(R.id.imageButtonpic);

		//这里(this)或者（Upload.this）均可
		mImageButton2.setOnClickListener(this);
		mImageButton3.setOnClickListener(this);
	}


	@Override
	public void onClick(View view) {
		switch (view.getId()) {
			case R.id.imageButtonpic: {
				shareMultipleImage();
				break;
			}
			case R.id.imageButtongif: {
				// TODO: 2016/10/5

				break;
			}

		}
	}
}




