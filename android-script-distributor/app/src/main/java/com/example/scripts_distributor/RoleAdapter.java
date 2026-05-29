package com.example.scripts_distributor;

import android.content.Context;
import android.graphics.Color;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;


import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RoleAdapter extends RecyclerView.Adapter<RoleAdapter.RoleViewHolder> {

    private Context context;
    private DatabaseReference rolesRef;// 引用 Firebase 数据库的角色节点
    private DatabaseReference selectedRolesRef; // 引用 Firebase 数据库的 selectedRoles 节点
    private OnRoleClickListener onRoleClickListener; // 点击监听器
    private String roomId; // 存储 roomId
    private String deviceId;
    private int playerId;
    private int previouslySelectedPosition = -1; // 默认值为 -1 表示尚未选择任何角色
    private DatabaseReference ref;
    private final Map<String, String> selectedRolesMap = new HashMap<>();
    private List<String> roleList = new ArrayList<>(); // 数据源

    public void setRoleList(List<String> roles) {
        this.roleList = roles;
        notifyDataSetChanged(); // 数据源更新后刷新视图
    }

    public RoleAdapter(Context context, List<String> roleList, String roomId, String deviceId, int playerId) {
        this.context = context;
        this.roleList = roleList;
        //this.selectedRolesRef = selectedRolesRef;
        this.roomId = roomId;
        this.deviceId=deviceId;
        this.playerId=playerId;
        selectedRolesRef=FirebaseDatabase.getInstance("https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com")
                .getReference("rooms").child(roomId).child("selectedRoles");
        selectedRolesRef.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                selectedRolesMap.clear(); // 清空之前的角色映射
                for (DataSnapshot childSnapshot : snapshot.getChildren()) {
                    String selectedRoleName = childSnapshot.getValue(String.class);
                    selectedRolesMap.put(selectedRoleName, String.valueOf(playerId)); // 更新角色映射
                }
                // 遍历所有角色并更新 UI
                for (int i = 0; i < roleList.size(); i++) {
                    String roleName = roleList.get(i);
                    boolean isRoleSelected = selectedRolesMap.containsKey(roleName);

                    // 通过 notifyItemChanged 来更新每个 View
                    notifyItemChanged(i);
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Log.e("FirebaseData", "Failed to listen for changes.", error.toException());
            }
        });
    }

    @NonNull
    @Override
    public RoleViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_role, parent, false);
        return new RoleViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull RoleViewHolder holder, int position) {
        //@Override
        String roleId = String.valueOf(position+1); // 角色 ID 对应 position，从 0 开始
        // 获取角色名称
        String roleName = roleList.get(position); // 从数据源获取名称
        holder.textViewRole.setText(roleName);
        // 直接根据 selectedRolesMap 判断当前角色是否已被选中
        if (selectedRolesMap.containsKey(roleName)) {
            // 已被选中 → 禁用
            holder.itemView.setEnabled(false);
            holder.textViewRole.setTextColor(Color.GRAY);
            holder.radioButton.setChecked(true);
        } else {
            // 可选状态 → 启用
            holder.itemView.setEnabled(true);
            holder.textViewRole.setTextColor(Color.BLACK);
            holder.radioButton.setChecked(false);
        }

            // 点击事件
            holder.itemView.setOnClickListener(v -> {
                if (onRoleClickListener != null) {
                    onRoleClickListener.onRoleClick(position);
                }
            });
            holder.radioButton.setOnClickListener(v -> {
                if (onRoleClickListener != null && holder.itemView.isEnabled()) {
                    onRoleClickListener.onRoleClick(position);
                }
            });
        }

        @Override
        public int getItemCount() {
            return roleList.size(); // 返回数据源大小
        }

        public void setOnRoleClickListener (OnRoleClickListener onRoleClickListener){
            this.onRoleClickListener = onRoleClickListener;
        }

        // ViewHolder 内部类
        public static class RoleViewHolder extends RecyclerView.ViewHolder {
            TextView textViewRole;
            RadioButton radioButton;

            public RoleViewHolder(@NonNull View itemView) {
                super(itemView);
                textViewRole = itemView.findViewById(R.id.tv_role_name);
                radioButton = itemView.findViewById(R.id.radioButton);
            }
        }

        // 点击事件接口
        public interface OnRoleClickListener {
            void onRoleClick(int position);
        }
    }

