// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    alias(libs.plugins.android.application) apply false
    // Add the dependency for the Googleb services Gradle plugin
    id("com.google.gms.google-services") version "4.4.3" apply false
    //alias(libs.plugins.jetbrains.kotlin.android) apply false
    kotlin("android") version "1.9.0" apply false
}