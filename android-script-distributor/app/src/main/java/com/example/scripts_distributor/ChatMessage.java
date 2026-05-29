package com.example.scripts_distributor;

public class ChatMessage {
    private String senderId;
    private String message;
    private long timestamp;
    // 无参构造函数
    public ChatMessage() {
        // 这个构造函数什么都不做，但Firebase需要它来反序列化数据
    }
    // 必须的无参构造函数用于 Firebase 数据

    public ChatMessage(String senderId, String message, long timestamp) {
        this.senderId = senderId;
        this.message = message;
        this.timestamp = timestamp;
    }



    // Getter 和 Setter 方法
    public String getSenderId() {
        return senderId;
    }

    public void setSenderId(String senderId) {
        this.senderId = senderId;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }
}

