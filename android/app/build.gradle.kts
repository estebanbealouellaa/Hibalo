plugins {
    id("com.android.application")

    id("com.google.gms.google-services")

    id("kotlin-android")

    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.hibalo_app"

    compileSdk = flutter.compileSdkVersion

    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.hibalo_app"

        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode

        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // flutter_onnxruntime 1.9.0 uses ONNX Runtime 1.28.0, which gives different
    // translations from the translation model (46 of 600 reference outputs
    // differ; 1.31.1 matches all 600). Gradle picks the higher version.
    implementation("com.microsoft.onnxruntime:onnxruntime-android:1.31.1")
}
