package com.example.scripts_distributor;

import android.app.Dialog;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Iterator;

public class Sript_detail extends AppCompatActivity {
    private HorizontalScrollView characterContainer;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_script_detail);

        String scriptName = getIntent().getStringExtra("script_title");
        if (scriptName == null) {
            Toast.makeText(this, "No script selected!", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        // 构建 JSON 文件路径（你可以根据需要统一格式，比如替换空格）
        String filename = "Scripts/" + scriptName + ".json";
        //从json文件中读取需要显示在界面中的信息

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
        RoomDialogHelper dialogHelper = new RoomDialogHelper(this);
        Button button1 = findViewById(R.id.back_button);
        Button button_create = findViewById(R.id.create_room_button);
        Button button_join = findViewById(R.id.join_room_button);

        JSONObject json = loadJsonFromAssets(filename);
        if (json == null) return;

        try {
            // 读取基本文本信息
            ((TextView) findViewById(R.id.title)).setText(json.getString("name"));
            ((TextView) findViewById(R.id.tags)).setText(json.getString("tags"));
            ((TextView) findViewById(R.id.PlayerInfo)).setText(json.getString("playerInfo"));
            ((TextView) findViewById(R.id.description2)).setText(json.getString("intro"));

            // 加载海报图
            String posterPath = json.getString("poster");
            ImageView posterView = findViewById(R.id.cover_image);
            loadImageFromAssets(posterView, posterPath);
            posterView.setOnClickListener(v -> showImageDialog(posterPath));

            // 读取角色头像
            LinearLayout container = findViewById(R.id.characterContainer);
            JSONObject characters = json.getJSONObject("character_posters");
            Iterator<String> keys = characters.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                String imagePath = characters.getString(key);

                ImageView iv = new ImageView(this);
                LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(300, 400);
                params.setMargins(10, 10, 10, 10);
                iv.setLayoutParams(params);
                iv.setScaleType(ImageView.ScaleType.CENTER_CROP);
                loadImageFromAssets(iv, imagePath);

                iv.setOnClickListener(v -> showImageDialog(imagePath));
                container.addView(iv);
            }

        } catch (JSONException e) {
            e.printStackTrace();
        }

        button1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });

        button_create.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                dialogHelper.showCreateRoomDialog(scriptName);
            }
        });

        button_join.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                dialogHelper.showJoinRoomDialog(scriptName);
            }
        });
    }
    //从json文件中加载信息,包括文本信息和图片路径
    private JSONObject loadJsonFromAssets(String path) {
        try {
            InputStream is = getAssets().open(path);
            BufferedReader reader = new BufferedReader(new InputStreamReader(is));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            return new JSONObject(sb.toString());
        } catch (IOException | JSONException e) {
            e.printStackTrace();
            return null;
        }
    }

    private void loadImageFromAssets(ImageView iv, String path) {
        try {
            InputStream is = getAssets().open(path);
            Bitmap bitmap = BitmapFactory.decodeStream(is);
            iv.setImageBitmap(bitmap);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    //附加功能：点击图像会在屏幕中放大
    private void showImageDialog(String imagePath) {
        Dialog dialog = new Dialog(this, android.R.style.Theme_Black_NoTitleBar_Fullscreen);
        dialog.setContentView(R.layout.dialog_image);
        ImageView iv = dialog.findViewById(R.id.dialogImageView);
        loadImageFromAssets(iv, imagePath);
        iv.setOnClickListener(v -> dialog.dismiss());
        dialog.show();
    }
}