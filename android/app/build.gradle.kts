plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "id.meira.meira"
    // model di APK lengkap tidak dikompresi: ukurannya hampir tidak berkurang, dan penyalinan pertama lebih cepat
    androidResources {
        noCompress += listOf("gguf", "onnx")
    }
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications memakai API java.time yang perlu desugaring di Android lama
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "id.meira.meira"
        // llama.cpp dikompilasi untuk android-28
        minSdk = 28
        ndk {
            // library llama.cpp tersedia untuk ponsel (arm64) dan emulator (x86_64). Saat --split-per-abi,
            // pembagian per arsitektur diatur Flutter, dan filter ini harus dilewati agar tidak bentrok.
            if (!project.hasProperty("split-per-abi")) {
                abiFilters += listOf("arm64-v8a", "x86_64")
            }
        }
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packaging {
        jniLibs {
            // library native diekstrak ke disk agar libllama_server.so bisa dijalankan sebagai proses
            useLegacyPackaging = true
            pickFirsts += "**/libc++_shared.so"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
