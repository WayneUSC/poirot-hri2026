package com.example.scripts_distributor;

import java.util.List;

public class Room {
    private String roomId;      // 房间ID
    private List<String> players; // 玩家列表

    // 默认构造函数（Firebase 需要）
    public Room() {
    }

    // 带参数的构造函数
    public Room(String roomId, List<String> players) {
        this.roomId = roomId;
        this.players = players;
    }

    // Getter 和 Setter 方法
    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public List<String> getPlayers() {
        return players;
    }

    public void setPlayers(List<String> players) {
        this.players = players;
    }
}