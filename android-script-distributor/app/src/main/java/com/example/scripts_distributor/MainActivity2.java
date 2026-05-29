package com.example.scripts_distributor;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.util.Log;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.Gson;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.List;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.stream.Collectors;

public class MainActivity2 extends AppCompatActivity {
    private static final String JSON_DIR = "Scripts/"; // 剧本json文件地址:直接在assets根目录下
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main2);
        RecyclerView recyclerView = findViewById(R.id.recyclerView);
        // 从assets目录读取要录入的剧本及其相关简介
        List<Script> scripts = loadScriptsFromAssets(this, JSON_DIR);
        //添加剧本条目
        ScriptAdapter adapter = new ScriptAdapter(this, scripts);
        recyclerView.setAdapter(adapter);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
    }

    public interface OnItemClickListener {
        void onItemClick(Script script);
    }

    // 从assets目录读取所有JSON文件
    public static List<Script> loadScriptsFromAssets(Context context, String dirPath) {
        List<Script> scripts = new ArrayList<>();
        try {
            String[] files = context.getAssets().list(dirPath);
            if (files != null) {
                for (String fileName : files) {
                    if (fileName.endsWith(".json")) {
                        InputStream is = context.getAssets().open(dirPath  + fileName);
                        Script fileScripts = parseJsonFile(is);
                        //Log.d("JSON_DEBUG", "Parsed from " + fileName + ": " + fileScripts);
                        if (fileScripts!=null) {
                            fileScripts.resolveResources(context); // 解析资源 ID 和类对象
                            //Log.d("SCRIPT_RESOLVED", fileScripts.toString());
                            scripts.add(fileScripts);
                        }

                    }
                }
            }
        } catch (IOException e) {
            Log.e("LOAD_SCRIPTS", "Error loading scripts", e);
        }
        return scripts;
    }
    //根据script的属性来抓取json文件中的对应内容
    private static Script parseJsonFile(InputStream inputStream) {
        try  {
            BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
            // 打印原始 JSON 内容
            String json = reader.lines().collect(Collectors.joining("\n"));
            //Log.d("JSON_RAW", "Raw JSON:\n" + json);

            // 重置读取器（因为上面已经消费了流）
            reader = new BufferedReader(new InputStreamReader(new ByteArrayInputStream(json.getBytes())));

            // 使用 TypeToken<Script> 来解析单个对象
            return new Gson().fromJson(reader, Script.class); // 解析为 Script 对象
        } catch (Exception e) {
            Log.e("JSON_PARSE", "Error parsing JSON", e);
            return null;
        }
    }

    //定义每个剧本，直接从json文件中拉取所有属性及相关信息，需要在Json文件中定义title,tags,rating,imageResName和targetActivityName的值
    public class Script {
        private String name;
        private String tags;
        private String rating;
        private String imageResName;  // 剧本所用的poster文件名称，字符串形式
        private String targetActivityName;  // 剧本所处的Activity名称，字符串形式
        private int imageResource;// 剧本所用的poster文件名称
        private Class<?> targetActivity;  // 用于存储目标剧本的Activity的类

        public Script(String name, String tags, String rating, String imageResName,String targetActivityName) {
            this.name = name;
            this.tags = tags;
            this.rating = rating;
            this.imageResName = imageResName;
            this.targetActivityName = targetActivityName;
        }

        // 添加资源解析方法（需在运行时调用）
        public void resolveResources(Context context) {
            // 解析图片资源 ID
            this.imageResource = context.getResources().getIdentifier(
                    imageResName, "drawable", context.getPackageName()
            );
            //this.imageResource = (resId != 0) ? resId : R.drawable.default_image; // 兜底默认图
            // 解析目标 Activity 类
            try {
                this.targetActivity = Class.forName("com.example.scripts_distributor." + targetActivityName);
            } catch (ClassNotFoundException e) {
                throw new RuntimeException("Activity class not found: " + targetActivityName, e);
            }
        }

        public String getTitle() { return name; }
        public String getTags() { return tags; }
        public String getRating() { return rating; }
        public int getImageResource() { return imageResource; }
        public Class<?> getTargetActivity() { return targetActivity; }  // 获取目标Activity类

        @Override
        public String toString() {
            return "Script{" +
                    "name='" + name + '\'' +
                    ", tags='" + tags + '\'' +
                    ", rating='" + rating + '\'' +
                    ", imageResName='" + imageResName + '\'' +
                    ", targetActivityName='" + targetActivityName + '\'' +
                    ", imageResource=" + imageResource +
                    ", targetActivity=" + (targetActivity != null ? targetActivity.getSimpleName() : "null") +
                    '}';
        }
    }

    public class ScriptAdapter extends RecyclerView.Adapter<ScriptAdapter.ScriptViewHolder> {
        private List<Script> scriptList;
        private Context context;

        public ScriptAdapter(Context context, List<Script> scriptList) {
            this.scriptList = scriptList;
            this.context = context;
        }

        @NonNull
        @Override
        public ScriptViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.script_layout, parent, false);
            return new ScriptViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ScriptViewHolder holder, int position) {
            Script script = scriptList.get(position);

            // 确保图片资源有效
            if (script.getImageResource() != 0) {
                // 使用 BitmapFactory 加载图片
                Bitmap bitmap = BitmapFactory.decodeResource(context.getResources(), script.getImageResource());
                // 你可以调整图片尺寸
                if (bitmap != null) {
                    holder.imageView.setImageBitmap(Bitmap.createScaledBitmap(bitmap, 100, 100, false));
                } else {
                    // 如果图片加载失败，可以设置一个默认图片
                    holder.imageView.setImageResource(R.drawable.default_image);
                }
            } else {
                // 如果图片资源无效，设置默认图片
                holder.imageView.setImageResource(R.drawable.default_image);
            }

            //文本
            holder.titleText.setText(script.getTitle());
            holder.tagsText.setText(script.getTags());
            holder.ratingText.setText(script.getRating());

            // 设置点击事件，根据targetActivity启动不同的Activity
            holder.itemView.setOnClickListener(v -> {
                Intent intent = new Intent(context, script.getTargetActivity());
                intent.putExtra("script_title", script.getTitle());  // 可选，传递额外数据
                context.startActivity(intent);
            });
        }

        @Override
        public int getItemCount() {
            return scriptList.size();
        }

        class ScriptViewHolder extends RecyclerView.ViewHolder {
            ImageView imageView;
            TextView titleText, tagsText, ratingText;

            ScriptViewHolder(View itemView) {
                super(itemView);
                imageView = itemView.findViewById(R.id.coverImage);
                titleText = itemView.findViewById(R.id.titleText);
                tagsText = itemView.findViewById(R.id.tagsText);
                ratingText = itemView.findViewById(R.id.ratingText);
            }
        }
    }

}
