package com.example.scripts_distributor;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.pdf.PdfRenderer;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.ParcelFileDescriptor;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.SimpleTarget;
import com.bumptech.glide.request.target.Target;
import com.bumptech.glide.request.transition.Transition;
import com.google.firebase.FirebaseApp;
import com.google.firebase.database.*;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import android.content.Intent;

import java.io.IOException;
import java.util.Map;
import java.util.Objects;

import android.widget.LinearLayout;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


public class Chat_room extends AppCompatActivity {
    private RecyclerView recyclerView_public,recyclerView_script,recyclerView_clue;
    private EditText messageInput;
    private Button sendButton,btnScript,btnClue,tabPublicChat,exitButton,btnPrepareNextAct;

    private List<ChatMessage> botmessages,publicmessages;
    private DatabaseReference publicChatReference,rolesRef;
    private DatabaseReference botChatReference;
    private ChatMessageAdapter publicmessageAdapter,botmessageAdapter;
    private boolean isPublicChat = false; //默认在机器人聊天室
    private String roomId,currentUserRoleId,deviceId;
    private String playerName,ScriptName;
    private PdfPageAdapter pdfPageAdapter_script,pdfPageAdapter_clue;
    private List<Bitmap> pdfPages_script,pdfPages_clue,publicImageList,privateImageList; // 存储 PDF 的每一页
    private int currentChapterIndex = 1; //当前章节幕数
    private int actnumber = 1;//用于转换对应章节
    private JSONArray actsArray; //从json文件中提取到的关于章节的信息
    private LinearLayout chapterContainer; // 新的容器
    private Map<Integer, Integer> chapterStartPositions = new HashMap<>();
    // 用于存储 JSON 中的章节信息
    private List<Act> actsList;
    // 标记每章 script 是否已加载
    private Map<Integer, Boolean> isScriptLoadedMap;
    // 标记每章 clue 是否已加载
    private Map<Integer, Boolean> isClueLoadedMap;
    // 私人线索 RecyclerView
    private ImageAdapter privateImageAdapter;
    private ImageAdapter publicImageAdapter;
    private TextView selectedRoleTextView;



    @SuppressLint("MissingInflatedId")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // 获取传递的房间ID和玩家名称以及剧本名称
        Intent intent = getIntent();
        roomId = intent.getStringExtra("ROOM_ID");
        ScriptName=intent.getStringExtra("Script_Name");
        this.playerName = intent.getStringExtra("PLAYER_NAME");
        currentUserRoleId=intent.getStringExtra("ROLE_ID");
        deviceId=intent.getStringExtra("DEVICE_ID");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat_room);
        // 初始化Firebase
        //FirebaseDatabase.getInstance().setPersistenceEnabled(true);
        recyclerView_public= findViewById(R.id.recyclerView_public);recyclerView_script=findViewById(R.id.recyclerView_script);
        recyclerView_clue=findViewById(R.id.recyclerView_clue);
//        messageInput = findViewById(R.id.messageInput);
//        sendButton = findViewById(R.id.sendButton);
        exitButton = findViewById(R.id.exit);
        selectedRoleTextView = findViewById(R.id.tv_selected_role);
        tabPublicChat = findViewById(R.id.tabPublicChat);

        botmessages = new ArrayList<>();
        publicmessages=new ArrayList<>();
        pdfPages_script = new ArrayList<>();
        pdfPages_clue = new ArrayList<>();
        publicImageList=new ArrayList<>();
        privateImageList=new ArrayList<>();
        actsList = new ArrayList<>();
        chapterStartPositions = new HashMap<>();
        isScriptLoadedMap = new HashMap<>();
        isClueLoadedMap = new HashMap<>();
        pdfPageAdapter_script = new PdfPageAdapter(pdfPages_script);
        pdfPageAdapter_clue = new PdfPageAdapter(pdfPages_clue);

        // 3. 读取 JSON 文件中的章节列表
        try {
            InputStream inputStream = getAssets().open("Scripts/"+ScriptName + ".json");
            byte[] buffer = new byte[inputStream.available()];
            inputStream.read(buffer);
            inputStream.close();
            String jsonStr = new String(buffer, StandardCharsets.UTF_8);
            JSONObject json = new JSONObject(jsonStr);
            actsArray = json.getJSONArray("acts");

            for (int i = 0; i < actsArray.length(); i++) {
                JSONObject actObj = actsArray.getJSONObject(i);
                int number = actObj.getInt("number");
                String name = actObj.getString("name");
                actsList.add(new Act(number, name));
            }
        } catch (IOException | JSONException e) {
            e.printStackTrace();
        }

        //用于显示章节按钮以及私人剧本线索的容器
        chapterContainer = findViewById(R.id.chapterContainer);
        btnPrepareNextAct = findViewById(R.id.btnPrepareNextAct);
        selectedRoleTextView.setText(ScriptName+":"+playerName);

        // 初始化 Firebase 实时数据库的不同引用
        publicChatReference = FirebaseDatabase.getInstance("https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com")
                .getReference("rooms").child(roomId).child("public_message");
        botChatReference = FirebaseDatabase.getInstance("https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com")
                .getReference("rooms").child(roomId).child("bot_message").child(playerName);
        rolesRef=FirebaseDatabase.getInstance("https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com")
                .getReference("rooms").child(roomId);

        // 初始化RecyclerView和消息适配器
        botmessageAdapter = new ChatMessageAdapter(botmessages, playerName);
        publicmessageAdapter = new ChatMessageAdapter(publicmessages, playerName);
        recyclerView_script.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false));
        recyclerView_clue.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false));
        recyclerView_public.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false));
        recyclerView_script.setAdapter(pdfPageAdapter_script);

        // 公共线索 RecyclerView
        publicImageAdapter = new ImageAdapter(publicImageList);
        recyclerView_public.setAdapter(publicImageAdapter);

        privateImageAdapter = new ImageAdapter(privateImageList);
        recyclerView_clue.setAdapter(privateImageAdapter);


        // 初始化 Firebase
        FirebaseApp.initializeApp(this);
        // 初始化 App Check

        // 清空上一次的记录
        clearChatHistory();
        //setUserInGameStatus(true);
        Readyto_continue(false);

        // 检查所有用户是否都已准备好
        checkAllUsersReady();

        //发送第一幕线索
        //loadPublicClueImages(1,publicImageList,ScriptName,publicImageAdapter);

        // 7. 初始化第1章
        if (!actsList.isEmpty()) {
            Act firstAct = actsList.get(0);
            actnumber = 1;
            addChapterBlock(firstAct.getNumber(), firstAct.getName());
            loadPublicClueImages(1, publicImageList, ScriptName, (ImageAdapter) recyclerView_public.getAdapter());
        }

        // 设置消息发送按钮的点击事件监听
//        sendButton.setOnClickListener(v -> {
//            String messageText = messageInput.getText().toString().trim();
//            if (!messageText.isEmpty()) {
//                // 判断当前显示的是哪个聊天室
//                isPublicChat = recyclerView_public.getVisibility() == View.VISIBLE;
//                sendMessage(playerName, messageText, isPublicChat);
//                messageInput.setText("");
//            }
//        });

        //退出
        exitButton.setOnClickListener(v -> {
            //setUserInGameStatus(false);
            rolesRef.child("inRoom").child(playerName).removeValue(); // 在 Activity删除角色选择记录
            //rolesRef.child("players").child(String.valueOf(playerId)).removeValue();
            rolesRef.child("readyStatus").child(deviceId).removeValue();
            finish();
        });


        //准备进入下一幕-------------------------------------------------------------------------------
        btnPrepareNextAct.setEnabled(true);
        btnPrepareNextAct.setOnClickListener(v -> {
//            if (currentChapterIndex < actsArray.length()) {
//                try {
//                    JSONObject act = actsArray.getJSONObject(currentChapterIndex);
//                    int actNumber = act.getInt("number");
//                    String actName = act.getString("name");
                    // 将“准备进入下一幕”按钮变为不可点击
                    btnPrepareNextAct.setEnabled(false);
                    btnPrepareNextAct.setBackgroundColor(getResources().getColor(android.R.color.darker_gray)); // 设置为灰色
//
//                    // 记录用户已准备状态（可以通过Firebase等同步到云端）
                    Readyto_continue(true);
//                    addChapterBlock(actNumber, actName);
//                    currentChapterIndex++;
//
                    if (currentChapterIndex <= actsArray.length()) {
                        btnPrepareNextAct.setEnabled(false);
                        btnPrepareNextAct.setBackgroundColor(getResources().getColor(android.R.color.darker_gray));
                    }
//
//                } catch (JSONException e) {
//                    e.printStackTrace();
//                }
//            }

        });


        //切换界面------------------------------------------------------------------------------------
        tabPublicChat.setOnClickListener(v -> {
            recyclerView_public.setVisibility(View.VISIBLE);
            recyclerView_script.setVisibility(View.GONE);
            recyclerView_clue.setVisibility(View.GONE);
            isPublicChat = true;  // 切换到公共聊天室
            Log.d("room_change", "切换到公共聊天室");
        });
        // 添加消息监听
        //addMessageListener(roomId);
    }
    //----------------------------------------------------------------------------------------------

    @Override
    protected void onDestroy() {
        super.onDestroy();

        // 设置用户为已退出游戏
        //setUserInGameStatus(false);
    }

//    private void sendMessage(String senderId, String messageText,boolean isPublicChat) {
//        long timestamp = new Date().getTime();
//        ChatMessage message = new ChatMessage(senderId, messageText, timestamp);
//        // 根据当前选择的聊天室发送消息
//        if (isPublicChat) {
//            publicChatReference.push().setValue(message);
//        } else {
//            botChatReference.push().setValue(message);
//        }
//    }

    //抓取PDF文件-------------------------------------------------------------------------------------
    private void sendUserRoleScript(String playerName, int actNumber, String type, String ScriptName) {
        Log.d("UserRoleScript", "查找剧本方法被调用");
            try {
                // 加载 JSON 数据
                String ScriptFile="Scripts/"+ScriptName+".json";
                Log.d("pdf链接", "剧本pdf："+ScriptFile);
                InputStream inputStream = getAssets().open(ScriptFile);
                byte[] buffer = new byte[inputStream.available()];
                inputStream.read(buffer);
                inputStream.close();
                String jsonString = new String(buffer, StandardCharsets.UTF_8);
                JSONObject jsonData = new JSONObject(jsonString);

                // 获取 PDF 链接
                String pdfUrl = getRoleScriptUrl(playerName, actNumber, jsonData);
                Log.d("pdf链接", "剧本pdf链接："+pdfUrl);
                if (pdfUrl != null) {
                    // 下载 PDF 文件
                    downloadPdf(pdfUrl, "tempPdf.pdf", new DownloadCallback() {
                        @Override
                        public void onSuccess(File file) {
                            Log.d("PDF_DOWNLOAD", "渲染开始" );
                            validatePdf(file);//验证pdf文件
                            // 渲染 PDF 文件
                            downloadAndRenderPdfFromFile(file,type,actNumber);
                        }

                        @Override
                        public void onError(Exception e) {
                            Log.e("PDF_DOWNLOAD", "下载失败：" + e.getMessage());
                        }
                    });
                } else {
                    Log.e("PDF_LINK", "未找到角色剧本链接");
                }
            } catch (IOException | JSONException e) {
                e.printStackTrace();
            }
    }
//下载线索图片----------------------------------------------------------------------------------------
    private void loadPrivateClueImages(int actNumber, String roleName, String ScriptName,
                                          List<Bitmap> privateImageList, RecyclerView.Adapter privateImageAdapter) {
        try {
            // 加载 JSON 文件
            InputStream inputStream = getAssets().open("Scripts/"+ScriptName+".json");
            byte[] buffer = new byte[inputStream.available()];
            inputStream.read(buffer);
            inputStream.close();
            String jsonString = new String(buffer, StandardCharsets.UTF_8);
            JSONObject jsonData = new JSONObject(jsonString);

            // 获取私人线索图片链接
            List<String> privateClueUrls = getPrivateClueUrls(roleName, actNumber, jsonData);

            // 下载并显示私人线索图片
            for (String url : privateClueUrls) {
                addImageToRecyclerView(url, privateImageList, privateImageAdapter);
            }
        } catch (IOException | JSONException e) {
            Log.e("LOAD_CLUE_IMAGES", "加载线索图片时出错：" + e.getMessage());
        }
    }

    private void loadPublicClueImages(int actNumber, List<Bitmap> publicImageList,String ScriptName, RecyclerView.Adapter publicImageAdapter) {
        try {
            // 加载 JSON 文件
            InputStream inputStream = getAssets().open("Scripts/"+ScriptName+".json");
            byte[] buffer = new byte[inputStream.available()];
            inputStream.read(buffer);
            inputStream.close();
            String jsonString = new String(buffer, StandardCharsets.UTF_8);
            JSONObject jsonData = new JSONObject(jsonString);

            // 获取公共线索图片链接
            List<String> publicClueUrls = getPublicClueUrls(actNumber, jsonData);

            // 下载并显示公共线索图片
            for (String url : publicClueUrls) {
                Log.d("IMAGE_URL", "尝试加载图片: " + url); // 打印出每个 URL 以便调试
                addImageToRecyclerView(url, publicImageList, publicImageAdapter);
            }
        } catch (IOException | JSONException e) {
            Log.e("LOAD_CLUE_IMAGES", "加载线索图片时出错：" + e.getMessage());
        }
    }

    //----------------------------------------------------------------------------------------------

    private void clearChatHistory() {
        // 清空公共聊天室的消息
        publicChatReference.removeValue().addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                Log.d("ChatHistory", "公共聊天室记录已清空");
            } else {
                //sendMessage("System", "无法清空公共聊天室记录: " + task.getException().getMessage(),false);
            }
        });

        // 清空机器人聊天室的消息
        botChatReference.removeValue().addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                Log.d("ChatHistory", "机器人聊天室记录已清空");
            } else {
                //sendMessage("System", "无法清空机器人聊天室记录: " + task.getException().getMessage(),false);
            }
        });

        // 清空本地消息列表并更新适配器
        botmessages.clear();
        botmessageAdapter.notifyDataSetChanged();
    }


    private void addMessageListener(String roomId) {
         publicChatReference.addChildEventListener(new ChildEventListener() {
            @Override
            public void onChildAdded(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
                ChatMessage message = snapshot.getValue(ChatMessage.class);
                publicmessages.add(message);
                publicmessageAdapter.notifyDataSetChanged();
                recyclerView_public.scrollToPosition(publicmessages.size() - 1);
            }

            @Override
            public void onChildChanged(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
            }

            @Override
            public void onChildRemoved(@NonNull DataSnapshot snapshot) {
            }

            @Override
            public void onChildMoved(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
            }
        });

        botChatReference.addChildEventListener(new ChildEventListener() {
            @Override
            public void onChildAdded(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
                ChatMessage message = snapshot.getValue(ChatMessage.class);
                botmessages.add(message);
                botmessageAdapter.notifyDataSetChanged();
                recyclerView_script.scrollToPosition(botmessages.size() - 1);
            }

            @Override
            public void onChildChanged(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
            }

            @Override
            public void onChildRemoved(@NonNull DataSnapshot snapshot) {
            }

            @Override
            public void onChildMoved(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
            }

        });
    }
    private void Readyto_continue(boolean if_ready) {
        rolesRef.child("playerReadyStatus").child(deviceId).setValue(if_ready);
    }
//将pdf渲染成图片显示在对应的界面-------------------------------------------------------------------------
    private void downloadAndRenderPdfFromFile(File pdfFile, String type,int chapterNumber) {
        try {
            // 使用 PdfRenderer 渲染 PDF 文件
            ParcelFileDescriptor fileDescriptor = ParcelFileDescriptor.open(pdfFile, ParcelFileDescriptor.MODE_READ_ONLY);
            PdfRenderer pdfRenderer = new PdfRenderer(fileDescriptor);

            int startPosition = pdfPages_script.size(); // 当前章节的起始位置
            chapterStartPositions.put(chapterNumber, startPosition); // 记录章节起始位置

            // 遍历 PDF 页面并将其渲染为 Bitmap
            for (int i = 0; i < pdfRenderer.getPageCount(); i++) {
                PdfRenderer.Page page = pdfRenderer.openPage(i);
                Bitmap bitmap = Bitmap.createBitmap(page.getWidth(), page.getHeight(), Bitmap.Config.ARGB_8888);
                page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY);
                page.close();

                Log.d("PDF_RENDER", "已渲染第 " + (i + 1) + " 页");

                // 将渲染的 Bitmap 添加到数据源并更新 RecyclerView
                if(Objects.equals(type, "roleScripts")) {
                    int finalIndex = i;
                    runOnUiThread(() -> {
                        pdfPages_script.add(bitmap);
                        pdfPageAdapter_script.notifyItemInserted(finalIndex);
                    });
                }
            }
            // 关闭 PdfRenderer
            pdfRenderer.close();
        } catch (IOException e) {
            Log.e("PDF_RENDER", "PDF 渲染失败：" + e.getMessage());
        }
    }

    //查询所有角色是否已准备进入下一幕---------------------------------------------------------------------
    private void checkAllUsersReady() {
        DatabaseReference readyStatus = rolesRef.child("playerReadyStatus");
        ImageAdapter publicImageAdapter = new ImageAdapter(publicImageList);

        readyStatus.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                boolean allUsersReady = true;

                for (DataSnapshot userSnapshot : snapshot.getChildren()) {
                    Boolean isReady = userSnapshot.getValue(Boolean.class);
                    if (isReady == null || !isReady) {
                        allUsersReady = false;
                        break;
                    }
                }

                if (allUsersReady) {
                    runOnUiThread(() -> {
                        Log.d("当前章节", "当前章节：" + currentChapterIndex+"；"+"总章节："+actsList.size());
                        if (currentChapterIndex < actsList.size()) { // actsList 为从 JSON 中读取的章节列表
                            currentChapterIndex++; // 下一章编号
                            String nextActName = actsList.get(currentChapterIndex - 1).getName(); // 获取下一章名字
                            addChapterBlock(currentChapterIndex, nextActName);
                            loadPublicClueImages(currentChapterIndex, publicImageList, ScriptName, publicImageAdapter);
                            // 恢复准备按钮状态
                            new Handler(Looper.getMainLooper()).postDelayed(() -> {
                                btnPrepareNextAct.setEnabled(true);
                                btnPrepareNextAct.setBackgroundColor(getResources().getColor(android.R.color.holo_purple));
                                Readyto_continue(false);
                            }, 1000);
                        } else {
                            // 所有章节都加载完成后禁用按钮
                            btnPrepareNextAct.setEnabled(false);
                            btnPrepareNextAct.setBackgroundColor(getResources().getColor(android.R.color.darker_gray));
                        }
                    });
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Log.e("ReadyStateListener", "监听失败：" + error.getMessage());
            }
        });
    }

    private void addChapterBlock(int actNumber, String actName) {
        // 获取容器 layout
        LinearLayout chapterContainer = findViewById(R.id.chapterContainer); // 你需要在 XML 中添加这个容器

        // 创建章节按钮（下拉切换）
        Button chapterButton = new Button(this);
        chapterButton.setText("Chapter " + actNumber + " ：" + actName);
        chapterButton.setAllCaps(false);
        chapterButton.setBackgroundColor(ContextCompat.getColor(this, R.color.white));

        // 创建下拉内容容器
        LinearLayout dropdownLayout = new LinearLayout(this);
        dropdownLayout.setOrientation(LinearLayout.VERTICAL);
        dropdownLayout.setVisibility(View.GONE);
        dropdownLayout.setPadding(20, 10, 20, 10);

        // 创建 “剧本” 按钮
        Button btnScript = new Button(this);
        btnScript.setText("script");
        btnScript.setAllCaps(false);

        // 创建 “线索” 按钮
        Button btnClue = new Button(this);
        btnClue.setText("clue");
        btnClue.setAllCaps(false);

        // 添加两个按钮到下拉容器
        dropdownLayout.addView(btnScript);
        dropdownLayout.addView(btnClue);

        // 添加章节按钮和下拉容器到主容器
        chapterContainer.addView(chapterButton);
        chapterContainer.addView(dropdownLayout);

        // 设置点击章节按钮显示/隐藏下拉区域
        chapterButton.setOnClickListener(v -> {
            dropdownLayout.setVisibility(dropdownLayout.getVisibility() == View.GONE ? View.VISIBLE : View.GONE);
        });

        // 设置剧本按钮事件
        btnScript.setOnClickListener(v -> {
            pdfPageAdapter_script.notifyDataSetChanged();
            recyclerView_public.setVisibility(View.GONE);
            recyclerView_clue.setVisibility(View.GONE);
            recyclerView_script.setVisibility(View.VISIBLE);
            if (!isScriptLoadedMap.getOrDefault(actNumber, false)) {
                sendUserRoleScript(playerName, actNumber, "roleScripts", ScriptName);
                isScriptLoadedMap.put(actNumber, true);
            } else {
                Integer startPosition = chapterStartPositions.get(actnumber);
                if (startPosition != null) {
                    recyclerView_script.scrollToPosition(startPosition);
                }
            }
            isPublicChat =false;
        });

        // 设置线索按钮事件
        btnClue.setOnClickListener(v -> {
            recyclerView_clue.setVisibility(View.VISIBLE);
            recyclerView_public.setVisibility(View.GONE);
            recyclerView_script.setVisibility(View.GONE);
            if (!isClueLoadedMap.getOrDefault(actNumber, false)) {
                loadPrivateClueImages(actNumber, playerName, ScriptName, privateImageList, privateImageAdapter);
                isClueLoadedMap.put(actNumber, true);
            }
            isPublicChat =false;
        });
    }

    //解析JSON文件查找角色剧本----------------------------------------------------------------------
    private String getRoleScriptUrl(String userId, int actNumber, JSONObject jsonData) {
        try {
            JSONObject roleScripts = jsonData.getJSONObject("roleScripts");
            if (roleScripts.has(userId)) {
                JSONObject userScripts = roleScripts.getJSONObject(userId);
                String actKey = String.valueOf(actNumber);
                if (userScripts.has(actKey)) {
                    return userScripts.getString(actKey);
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null; // 返回 null 表示未找到链接
    }
    //根据网址下载pdf文件------------------------------------------------------------------------------
    private void downloadPdf(String url, String fileName, DownloadCallback callback) {
        new Thread(() -> {
            try {
                URL fileUrl = new URL(url);
                HttpURLConnection connection = (HttpURLConnection) fileUrl.openConnection();
                connection.setConnectTimeout(10000); // 连接超时时间
                connection.setReadTimeout(15000);   // 读取超时时间
                connection.connect();
                Log.d("PDF_DOWNLOAD", "HTTP 响应码：" + connection.getResponseCode());

                File pdfFile = new File(getCacheDir(), fileName);
                try (InputStream input = connection.getInputStream();
                     FileOutputStream output = new FileOutputStream(pdfFile)) {
                    byte[] buffer = new byte[1024];
                    int length;
                    while ((length = input.read(buffer)) > 0) {
                        output.write(buffer, 0, length);
                    }
                }
                // 检查文件是否存在
                if (pdfFile.exists() && pdfFile.length() > 0) {
                    Log.d("PDF_DOWNLOAD", "文件已成功下载到: " + pdfFile.getAbsolutePath());
                } else {
                    Log.e("PDF_DOWNLOAD", "文件下载失败: 文件不存在或大小为0");
                }

                runOnUiThread(() -> callback.onSuccess(pdfFile));
            } catch (Exception e) {
                runOnUiThread(() -> callback.onError(e));
            }
        }).start();
    }

    interface DownloadCallback {
        void onSuccess(File file);

        void onError(Exception e);
    }
//检验文件是否被下载-----------------------------------------------------------------------------------
    private void validatePdf(File pdfFile) {
        try {
            ParcelFileDescriptor fileDescriptor = ParcelFileDescriptor.open(pdfFile, ParcelFileDescriptor.MODE_READ_ONLY);
            PdfRenderer pdfRenderer = new PdfRenderer(fileDescriptor);

            if (pdfRenderer.getPageCount() > 0) {
                Log.d("PDF_VALIDATE", "PDF 文件可用，共 " + pdfRenderer.getPageCount() + " 页");
            } else {
                Log.e("PDF_VALIDATE", "PDF 文件不可用或无内容");
            }

            pdfRenderer.close();
        } catch (IOException e) {
            Log.e("PDF_VALIDATE", "验证 PDF 文件时出错: " + e.getMessage());
        }
    }
//下载图片版线索--------------------------------------------------------------------------------------
private List<String> getPublicClueUrls(int actNumber, JSONObject jsonData) {
    List<String> urls = new ArrayList<>();
    try {
        JSONObject publicClues = jsonData.getJSONObject("publicClueImageURLsDict");
        String actKey = String.valueOf(actNumber);
        if (publicClues.has(actKey)) {
            JSONArray actUrls = publicClues.getJSONArray(actKey);
            Log.d("total public clue", "剧本总数：" +actUrls.length());
            for (int i = 0; i < actUrls.length(); i++) {
                urls.add(actUrls.getString(i));
            }
        }
    } catch (JSONException e) {
        e.printStackTrace();
    }
    return urls;
}
    private List<String> getPrivateClueUrls(String roleName, int actNumber, JSONObject jsonData) {
        List<String> urls = new ArrayList<>();
        try {
            JSONObject privateClues = jsonData.getJSONObject("privateClueImageURLsDict");
            if (privateClues.has(roleName)) {
                JSONObject roleClues = privateClues.getJSONObject(roleName);
                String actKey = String.valueOf(actNumber);
                if (roleClues.has(actKey)) {
                    JSONArray actUrls = roleClues.getJSONArray(actKey);
                    for (int i = 0; i < actUrls.length(); i++) {
                        urls.add(actUrls.getString(i));
                    }
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return urls;
    }

    //下载图片文件并渲染到视图上-------------------------------------------------------------------------
    private void addImageToRecyclerView(String imageUrl, List<Bitmap> imageList, RecyclerView.Adapter adapter) {
        // 使用 BitmapFactory.Options 压缩图片
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inSampleSize = 4; // 压缩比例，值越大图片越小（2 表示宽高各减半）
        //String encodedUrl = Uri.encode(imageUrl, ":/-._~!$&'()*+,;=");
        String encodedUrl = imageUrl;
        Glide.with(this)
                .asBitmap()
                .load(encodedUrl)
                .override(800, 800)
                .diskCacheStrategy(DiskCacheStrategy.ALL)
                .skipMemoryCache(false)
                .error(android.R.drawable.ic_dialog_alert) // 错误占位符
                .addListener(new RequestListener<Bitmap>() {
                    @Override
                    public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Bitmap> target, boolean isFirstResource) {
                        if (e != null) {
                            e.logRootCauses("GLIDE_ERROR");
                            Log.e("IMAGE_RENDER", "图片加载失败"+imageUrl);
                        }
                        return false;
                    }

                    @Override
                    public boolean onResourceReady(Bitmap resource, Object model, Target<Bitmap> target, DataSource dataSource, boolean isFirstResource) {
                        Log.d("IMAGE_RENDER", "图片加载成功");
                        return false;
                    }
                })
                .into(new SimpleTarget<Bitmap>() {
                    @Override
                    public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                        runOnUiThread(() -> {
                            imageList.add(resource);
                            //adapter.notifyItemInserted(imageList.size() - 1);
                            adapter.notifyDataSetChanged();
                            Log.d("IMAGE_RENDER", "图片已添加到 RecyclerView，总数：" + imageList.size());
                        });
                    }
                });
    }

    public static class Act {
        private int number;
        private String name;

        public Act(int number, String name) {
            this.number = number;
            this.name = name;
        }

        public int getNumber() {
            return number;
        }

        public String getName() {
            return name;
        }
    }

}
