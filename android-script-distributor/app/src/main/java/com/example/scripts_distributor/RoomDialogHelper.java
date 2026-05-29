package com.example.scripts_distributor;

import android.content.Context;
import android.content.Intent;

import android.widget.EditText;

import androidx.appcompat.app.AlertDialog;

public class RoomDialogHelper {
    private Context context;

    public RoomDialogHelper(Context context) {
        this.context = context;
    }

    public void showCreateRoomDialog(String ScriptName) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle("Create a Room");

        EditText roomIDInput = new EditText(context);
        builder.setView(roomIDInput);

        builder.setPositiveButton("Create", (dialog, which) -> {
            String roomId = roomIDInput.getText().toString().trim();
            Intent intent = new Intent(context, Role_choose.class);
            intent.putExtra("ROOM_ID", roomId);
            intent.putExtra("Script_Name", ScriptName);
            context.startActivity(intent);
        });

        builder.setNegativeButton("Exit", (dialog, which) -> dialog.cancel());

        builder.show();
    }

    public void showJoinRoomDialog(String ScriptName) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle("Join a Room");

        EditText roomIdInput = new EditText(context);
        builder.setView(roomIdInput);

        builder.setPositiveButton("Join", (dialog, which) -> {
            String roomId = roomIdInput.getText().toString().trim();
            Intent intent = new Intent(context, Role_choose.class);
            intent.putExtra("ROOM_ID", roomId);
            intent.putExtra("Script_Name", ScriptName);
            context.startActivity(intent);
        });

        builder.setNegativeButton("Exit", (dialog, which) -> dialog.cancel());

        builder.show();
    }

}
