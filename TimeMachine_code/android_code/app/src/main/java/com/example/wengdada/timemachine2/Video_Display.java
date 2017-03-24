package com.example.wengdada.timemachine2;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.ImageButton;

public class Video_Display extends AppCompatActivity {
    private ImageButton mImageButton_play;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_video__display);
		mImageButton_play=(ImageButton)findViewById(R.id.play);
		mImageButton_play.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO: 2016/5/15  打开视频所在地，播放视频
			}
		});
	}
}
