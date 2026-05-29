package com.example.scripts_distributor;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Priority;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.data.DataFetcher;

import java.io.BufferedInputStream;
import java.io.InputStream;

public class BufferedFetcher implements DataFetcher<InputStream> {
    private final DataFetcher<InputStream> originalFetcher;

    public BufferedFetcher(DataFetcher<InputStream> originalFetcher) {
        this.originalFetcher = originalFetcher;
    }

    @Override
    public void loadData(@NonNull Priority priority, @NonNull DataCallback<? super InputStream> callback) {
        originalFetcher.loadData(priority, new DataCallback<InputStream>() {
            @Override
            public void onDataReady(@Nullable InputStream data) {
                if (data != null) {
                    // 包装原始 InputStream 为 BufferedInputStream
                    callback.onDataReady(new BufferedInputStream(data, 10 * 1024 * 1024)); // 10MB 缓冲区
                } else {
                    callback.onDataReady(null);
                }
            }

            @Override
            public void onLoadFailed(@NonNull Exception e) {
                callback.onLoadFailed(e);
            }
        });
    }

    @Override
    public void cleanup() {
        originalFetcher.cleanup();
    }

    @Override
    public void cancel() {
        originalFetcher.cancel();
    }

    @NonNull
    @Override
    public Class<InputStream> getDataClass() {
        return InputStream.class;
    }

    @NonNull
    @Override
    public DataSource getDataSource() {
        return originalFetcher.getDataSource();
    }
}

