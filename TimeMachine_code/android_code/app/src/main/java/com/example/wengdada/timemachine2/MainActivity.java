package com.example.wengdada.timemachine2;
import android.content.DialogInterface;
import android.content.Intent;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.widget.Button;

public class MainActivity extends AppCompatActivity {

    private Button btnupload_layout;
    private Button btntemplate_layout;
    private ButtonListener mListener;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mListener=new ButtonListener();//一定要记住
        findbyID();
        OnClick();
    }

    private void findbyID() {
        btnupload_layout=(Button)findViewById(R.id.btnupload_layout);
        btntemplate_layout=(Button)findViewById(R.id.btntemplate_layout);
    }
    private void OnClick(){
        btnupload_layout.setOnClickListener(mListener);
        btntemplate_layout.setOnClickListener(mListener);
    }
    private class ButtonListener implements View.OnClickListener{
        @Override
        public void onClick(View v) {
            switch (v.getId()){
                case R.id.btnupload_layout:
                    // 跳转到上传的窗口
                    Intent upload_intent=new Intent(MainActivity.this,UpLoad.class);
                    startActivity(upload_intent);
                    break;
                case R.id.btntemplate_layout:
                    // 跳转到模板的窗口
                    Intent template_intent=new Intent(MainActivity.this,Template.class);
                    startActivity(template_intent);
                    break;
            }
        }
    }

    //退出的方式1
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            AlertDialog.Builder alertdialog = new AlertDialog.Builder(this);
            alertdialog.setTitle("提示");
            alertdialog.setMessage("确定退出时光机？");
            alertdialog.setPositiveButton("残忍退出", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    finish();
                }
            });
            alertdialog.setNegativeButton("再看看吧", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {

                }
            });
            alertdialog.show();
        }
        return super.onKeyDown(keyCode,event);
    }

/*
//退出的方式2
    private long exittime = 0;

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if(keyCode==KeyEvent.KEYCODE_BACK && event.getAction()==KeyEvent.ACTION_DOWN){
			if(System.currentTimeMillis()-exittime>2000){
				AlertDialog.Builder alertdialog = new AlertDialog.Builder(this);
				alertdialog.setTitle("提示");
				alertdialog.setMessage("再按一次退出时光机");
				alertdialog.show();
				exittime=System.currentTimeMillis();
			}
			else{
				finish();
				System.exit(0);
			}
		}
		return super.onKeyDown(keyCode, event);
	}*/
}

