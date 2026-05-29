package com.example.scripts_distributor;
import android.graphics.Color;
import android.net.Uri;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import android.content.Intent;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class ChatMessageAdapter extends RecyclerView.Adapter<ChatMessageAdapter.MessageViewHolder> {
    private List<ChatMessage> messages;
    private String currentUserId;

    public ChatMessageAdapter(List<ChatMessage> messages, String currentUserId) {
        this.messages = messages;
        this.currentUserId = currentUserId;
    }

    @NonNull
    @Override
    public MessageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_chat_message, parent, false);
        return new MessageViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull MessageViewHolder holder, int position) {
        ChatMessage message = messages.get(position);

        holder.messageText.setText(message.getMessage());

        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm", Locale.getDefault());
        String timestamp = sdf.format(new Date(message.getTimestamp()));
        holder.timestampText.setText(timestamp);

        if (message.getSenderId().equals(currentUserId)||message.getSenderId()=="System") {
            holder.messageText.setBackgroundResource(R.drawable.chat_message_outgoing_bg);
            holder.messageText.setTextColor(Color.BLACK); // 设置当前用户消息的字体颜色
            holder.messageText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16); // 设置字体大小
        } else {
            holder.messageText.setBackgroundResource(R.drawable.chat_message_incoming_bg);
            holder.messageText.setTextColor(Color.BLACK); // 设置当前用户消息的字体颜色
            holder.messageText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16); // 设置字体大小
        }

        // 如果消息是PDF链接，设置点击事件打开PDF
        if (message.getMessage().startsWith("角色剧本: ")) {
            holder.messageText.setOnClickListener(v -> {
                String pdfUrl = message.getMessage().substring("角色剧本: ".length());
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setDataAndType(Uri.parse(pdfUrl), "application/pdf");
                intent.setFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
                v.getContext().startActivity(intent);
            });
        }
    }

    @Override
    public int getItemCount() {
        return messages.size();
    }

    static class MessageViewHolder extends RecyclerView.ViewHolder {
        TextView messageText;
        TextView timestampText;

        public MessageViewHolder(@NonNull View itemView) {
            super(itemView);
            messageText = itemView.findViewById(R.id.messageText);
            timestampText = itemView.findViewById(R.id.timestampText);
        }
    }
}