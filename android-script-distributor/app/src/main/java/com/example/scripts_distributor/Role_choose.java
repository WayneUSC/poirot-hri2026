package com.example.scripts_distributor;

import com.google.firebase.FirebaseApp;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.GenericTypeIndicator;
import com.google.firebase.database.MutableData;
import com.google.firebase.database.ServerValue;
import com.google.firebase.database.Transaction;
import com.google.firebase.database.ValueEventListener;

import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONObject;

public class Role_choose extends AppCompatActivity implements RoleAdapter.OnRoleClickListener{
    private String playerName;
    private String roomId,ScriptName;
    private RecyclerView recyclerView;
    private List<String> roleList = new ArrayList<>(); // 初始化为一个空的 ArrayList
    private DatabaseReference ref;
    private Button startGameButton;
    private TextView selectedRoleTextView, ConnectionLabel;
    private Button exitButton;
    //private ValueEventListener rolesValueEventListener; // 用于管理 ValueEventListener
    private String currentUserRoleId = null; // 当前用户选择的角色 ID
    private RoleAdapter adapter;
    int playerId;//用户在数据库中的编号
    boolean ifJoinRoom = false;
    // 定义数据源

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //FirebaseDatabase.getInstance("https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com").setPersistenceEnabled(false);
        //FirebaseDatabase.getInstance("https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com").setLogLevel(Logger.Level.DEBUG);
        FirebaseApp.initializeApp(this);
        if (FirebaseApp.getApps(this).isEmpty()) {
            Log.e("Firebase", "Firebase 未初始化！");
        } else {
            Log.d("Firebase", "Firebase 初始化成功！");
        }

        ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        boolean isConnected = activeNetwork != null && activeNetwork.isConnectedOrConnecting();
        Log.d("Network", "当前网络连接状态：" + isConnected);

        String deviceId = Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);//用户设备ID
        Intent intent = getIntent();
        roomId = intent.getStringExtra("ROOM_ID");
        Log.d("roomId",  "传递房间号：" +roomId);
        ScriptName=intent.getStringExtra("Script_Name");
        Log.d("ScriptName",  "传递剧本名：" +ScriptName);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_role_choose);
        startGameButton = findViewById(R.id.btn_ready);
        selectedRoleTextView = findViewById(R.id.tv_selected_role);
        ConnectionLabel=findViewById(R.id.connection_label);
        exitButton = findViewById(R.id.exitButton);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        recyclerView = findViewById(R.id.recyclerView);
        Log.d("Check", "准备使用 roomId: " + roomId);
        ref=FirebaseDatabase.getInstance("https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com").getReference("rooms").child(roomId);
        ref.keepSynced(true);

        // 显式创建房间节点
        Map<String, Object> initialRoomData = new HashMap<>();
        initialRoomData.put("createdAt", ServerValue.TIMESTAMP);
        initialRoomData.put("creator", deviceId);
        Log.d("Check", "准备调用 setValue...");
        ref.updateChildren(initialRoomData).addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                Log.d("Firebase", "房间创建成功");
        ref.child("readyStatus").child(deviceId).setValue(false)
                .addOnCompleteListener(readyTask -> {
                    if (readyTask.isSuccessful()) {
                        Log.d("Firebase", "readyStatus 写入成功");
                        ConnectionLabel.setText("roomId:"+roomId+"——"+"Connected！");
                    } else {
                        Log.e("Firebase", "readyStatus 写入失败", readyTask.getException());
                        readyTask.getException().printStackTrace();
                    }
                });
            addPlayerToRoom(deviceId);
//            ref.child("players");
//            ref.child("playerRoles");
//            ref.child("selectedRoles");
            checkAllRolesSelected();
            } else {
                Log.e("Firebase", "房间创建失败", task.getException());
                task.getException().printStackTrace();
            }
        });

        // 初始化适配器并传递角色列表
        adapter = new RoleAdapter(this, roleList,roomId,deviceId,playerId);
        adapter.setOnRoleClickListener(this);  // 设置监听器
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        recyclerView.setAdapter(adapter);
        loadRolesFromJson(adapter);

        exitButton.setOnClickListener(v -> {
            ref.child("playerRoles").child(deviceId).removeValue(); // 在 Activity删除角色选择记录
            ref.child("players").child(String.valueOf(playerId)).removeValue();
            ref.child("selectedRoles").child(String.valueOf(playerId)).removeValue();
            ref.child("readyStatus").child(deviceId).removeValue();
            finish();
        });

        startGameButton.setOnClickListener(v ->{
            if(startGameButton.isEnabled()==true){
                // 将“准备”按钮变为不可点击
                startGameButton.setEnabled(false);
                startGameButton.setBackgroundColor(getResources().getColor(android.R.color.darker_gray)); // 设置为灰色
                ref.child("readyStatus").child(deviceId).setValue(true);
            }else{
                startGameButton.setEnabled(true);
                startGameButton.setBackgroundColor(getResources().getColor(android.R.color.black)); // 设置为灰色
                ref.child("readyStatus").child(deviceId).setValue(false);
            }
        });
    }

    // 实现 OnRoleClickListener 接口方法
    @Override
    public void onRoleClick(int position) {
        String deviceId = Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);//用户设备ID
        playerName = roleList.get(position); // ← 直接从 roleList 获取角色名称
        Log.d("RoleClick", "选择: " + playerName);

        DatabaseReference roomRef = FirebaseDatabase.getInstance().getReference("rooms").child(roomId);
        final List<String> players = new ArrayList<>();

        // **1. 获取玩家列表**
        roomRef.child("players").get().addOnSuccessListener(playersSnapshot -> {
            players.clear(); // 清空并重新填充
            if (playersSnapshot.exists()) {
                players.addAll(playersSnapshot.getValue(new GenericTypeIndicator<List<String>>() {}));
            }

            int playerIndex = players.indexOf(String.valueOf(deviceId));
            Log.d("Firebase", "当前玩家ID: " + deviceId);
            Log.d("Firebase", "当前玩家索引: " + playerIndex);
            if (playerIndex == -1) {
                Log.e("Firebase", "当前玩家不在 players 数组中");
                return;
            }

            // **2. 更新 selectedRoles 数组**
            roomRef.child("selectedRoles").runTransaction(new Transaction.Handler() {
                @Override
                public Transaction.Result doTransaction(@NonNull MutableData currentData) {
                    List<String> selectedRolesList = currentData.getValue(new GenericTypeIndicator<List<String>>() {});
                    if (selectedRolesList == null) selectedRolesList = new ArrayList<>();

                    while (selectedRolesList.size() < players.size()) {
                        selectedRolesList.add("");
                    }

                    selectedRolesList.set(playerIndex, playerName); // ← 用本地获取的角色名
                    currentData.setValue(selectedRolesList);
                    return Transaction.success(currentData);
                }

                @Override
                public void onComplete(DatabaseError error, boolean committed, DataSnapshot currentData) {
                    if (error == null && committed) {
                        // **3. 更新 playerRoles**
                        roomRef.child("playerRoles").child(deviceId).setValue(playerName);
                        selectedRoleTextView.setText("your character：" + playerName);
                        if (startGameButton.getVisibility() == View.GONE) {
                            startGameButton.setVisibility(View.VISIBLE);
                        }
                    } else {
                        Log.e("Firebase", "角色选择更新失败: " + (error != null ? error.getMessage() : "Unknown error"));
                    }
                }
            });
        });
    }

    // 加载角色数据的方法
    public void loadRolesFromJson(RoleAdapter adapter) {
        roleList.clear(); // 清空旧数据

        try {
            // 构造 JSON 文件路径（按 ScriptName）
            String filename = "Scripts/" + ScriptName + ".json";
            InputStream is = getAssets().open(filename);
            BufferedReader reader = new BufferedReader(new InputStreamReader(is));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            JSONObject json = new JSONObject(sb.toString());

            // 读取 roles 数组
            JSONArray rolesArray = json.getJSONArray("roles");
            for (int i = 0; i < rolesArray.length(); i++) {
                roleList.add(rolesArray.getString(i));
            }

            // 更新适配器
            adapter.setRoleList(roleList);

        } catch (Exception e) {
            Log.e("LoadJSON", "Error reading roles from JSON", e);
            Toast.makeText(this, "加载角色失败", Toast.LENGTH_SHORT).show();
        }
    }

    private void checkAllRolesSelected() {
        DatabaseReference playerReadyStatusRef=FirebaseDatabase.getInstance("https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com")
                .getReference("rooms").child(roomId).child("readyStatus");
        // 监听 playerReadyStatus 分支的数据变化
        playerReadyStatusRef.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                boolean allReady = true;

                // 如果分支本身不存在或为空，直接设置 allReady 为 false
                if (!dataSnapshot.exists() || dataSnapshot.getChildrenCount() == 0) {
                    allReady = false;
                } else {
                    // 遍历 playerReadyStatus 的每个子节点
                    for (DataSnapshot childSnapshot : dataSnapshot.getChildren()) {
                        Boolean isReady = childSnapshot.getValue(Boolean.class);

                        // 如果有任何一个值不是 true，则设置 allReady 为 false
                        if (isReady == null || !isReady) {
                            allReady = false;
                            break;
                        }
                    }
                }
                // 如果所有玩家都准备好了，进入下一个房间
                if (allReady && !ifJoinRoom) {
                    ifJoinRoom = true;
                    joinRoom(roomId, playerName);
                    // 可根据需要结束当前 Activity
                    finish();
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {
                // 处理错误
                Log.e("FirebaseError", "Error: " + databaseError.getMessage());
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        String deviceId = Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);//用户设备ID
        ref.child("playerRoles").child(deviceId).removeValue(); // 在 Activity删除角色选择记录
        ref.child("players").child(String.valueOf(playerId)).removeValue();
        ref.child("selectedRoles").child(String.valueOf(playerId)).removeValue();
        ref.child("readyStatus").child(deviceId).removeValue();
        Log.d("destroy", "清除代码已执行");
    }

    private void joinRoom(String roomId, String userName) {
        DatabaseReference database = FirebaseDatabase.getInstance("https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com").getReference("rooms").child(roomId);

        database.child("inRoom").child(userName).setValue(true)
                .addOnSuccessListener(aVoid -> {
                    Log.d("TAG", userName + "进入房间");
                    // 跳转到聊天室界面并传递房间ID
                    //Intent intent = new Intent(this, Role_choose.class);
                    String deviceId = Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);//用户设备ID
                    Intent intent=new Intent(Role_choose.this, Chat_room.class);
                    intent.putExtra("ROOM_ID", roomId);//传递房间ID
                    intent.putExtra("PLAYER_NAME", playerName); // 传递玩家名称
                    intent.putExtra("Script_Name", ScriptName);//传递剧本名
                    intent.putExtra("ROLE_ID",currentUserRoleId);
                    intent.putExtra("DEVICE_ID",deviceId);
                    startActivity(intent);
                })
                .addOnFailureListener(e -> {
                    Log.e("TAG", "进入房间失败: " + e.getMessage());
                });
    }

    private void addPlayerToRoom(String deviceId) {
        // 获取房间的 players 节点
        DatabaseReference roomRef = ref.child("players");

        // 获取当前房间玩家的数量
        roomRef.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                // 计算下一个玩家的编号
                playerId = (int) dataSnapshot.getChildrenCount();  // 获取当前节点下的子节点数量

                // 在玩家节点中存储设备 ID，并使用玩家编号
                roomRef.child(String.valueOf(playerId)).setValue(deviceId)
                        .addOnCompleteListener(task -> {
                            if (task.isSuccessful()) {
                                // 玩家成功加入
                                System.out.println("Player added with ID: " + playerId);
                            } else {
                                // 处理失败的情况
                                System.out.println("Failed to add player.");
                            }
                        });
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                // 处理错误
                System.out.println("Error: " + databaseError.getMessage());
            }
        });
    }


}





