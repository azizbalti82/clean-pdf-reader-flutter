import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.baltcode.pdf_reader"
    compileSdk = 36
    ndkVersion = "29.0.14033849"  // Latest NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Updated to Java 17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()  // Updated to Java 17
    }

    defaultConfig {
        applicationId = "com.baltcode.pdf_reader"
        minSdk = flutter.minSdkVersion  // Keep this for wider device support
        targetSdk = 35  // Latest Android 15
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // NDK configuration for 16KB page size support
        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86_64"))
        }
    }

    signingConfigs {
        create("release"){
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

flutter {
    source = "../.."
}
