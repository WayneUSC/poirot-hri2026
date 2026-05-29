package com.example.scripts_distributor;

public class Role {
    private String name;
    private String status; // "available" or "unavailable"
    private String selectedBy; // 设备 ID

    public Role() {}

    public Role(String name, String status, String selectedBy) {
        this.name = name;
        this.status = status;
        this.selectedBy = selectedBy;
    }

    public String getName() {
        return name;
    }

    public String getStatus() {
        return status;
    }

    public String getSelectedBy() {
        return selectedBy;
    }
}
