plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    
    // PERBAIKAN 1: Tambahkan tanda kurung dan kutip (Kotlin DSL Syntax)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.rh_chat_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.rh_chat_app"
        
        // PERBAIKAN 2: Ubah minSdk jadi 21 (Wajib untuk Firebase terbaru)
        // Jangan pakai flutter.minSdkVersion jika nilainya di bawah 21
        minSdk = flutter.minSdkVersion 
        
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")

            // --- TAMBAHKAN DUA BARIS INI ---
            isMinifyEnabled = true // Mengaktifkan R8 (biasanya default true di flutter build apk)
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
            // -------------------------------
        }
    }
}

flutter {
    source = "../.."
}

// ... kode atas biarkan sama ...

dependencies {
    // PERBAIKAN: Ganti 2.0.4 menjadi 2.1.4 (atau lebih baru)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}