package com.example.scripts_distributor;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.load.Options;
import com.bumptech.glide.load.model.GlideUrl;
import com.bumptech.glide.load.model.ModelLoader;
import com.bumptech.glide.load.model.ModelLoaderFactory;
import com.bumptech.glide.load.model.MultiModelLoaderFactory;

import java.io.InputStream;

public class CustomHttpUrlLoader implements ModelLoader<GlideUrl, InputStream> {
    private final ModelLoader<GlideUrl, InputStream> concreteLoader;

    public CustomHttpUrlLoader(ModelLoader<GlideUrl, InputStream> concreteLoader) {
        this.concreteLoader = concreteLoader;
    }

    @Nullable
    @Override
    public LoadData<InputStream> buildLoadData(@NonNull GlideUrl model, int width, int height, @NonNull Options options) {
        // 获取原始的 LoadData
        LoadData<InputStream> originalLoadData = concreteLoader.buildLoadData(model, width, height, options);
        if (originalLoadData == null || originalLoadData.fetcher == null) {
            return null;
        }

        // 包装原始 Fetcher 为自定义的 BufferedFetcher
        return new LoadData<>(originalLoadData.sourceKey, new BufferedFetcher(originalLoadData.fetcher));
    }

    @Override
    public boolean handles(@NonNull GlideUrl model) {
        return concreteLoader.handles(model);
    }

    public static class Factory implements ModelLoaderFactory<GlideUrl, InputStream> {
        @Override
        public ModelLoader<GlideUrl, InputStream> build(MultiModelLoaderFactory multiFactory) {
            return new CustomHttpUrlLoader(multiFactory.build(GlideUrl.class, InputStream.class));
        }

        @Override
        public void teardown() {
            // 不需要清理资源
        }
    }
}

