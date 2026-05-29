package com.example.scripts_distributor;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import com.bumptech.glide.Glide;
import com.bumptech.glide.GlideBuilder;
import com.bumptech.glide.Registry;
import com.bumptech.glide.annotation.GlideModule;
import com.bumptech.glide.module.AppGlideModule;

@GlideModule
public class MyAppGlideModule extends AppGlideModule {
    @Override
    public void registerComponents(@NonNull Context context, @NonNull Glide glide, @NonNull Registry registry) {
        // 增大 Glide 的缓冲区
        //registry.replace(GlideUrl.class, InputStream.class, new CustomHttpUrlLoader.Factory());
    }
    @Override
    public void applyOptions(@NonNull Context context, @NonNull GlideBuilder builder) {
        // 设置日志等级为 DEBUG
        builder.setLogLevel(Log.VERBOSE);
    }
}

