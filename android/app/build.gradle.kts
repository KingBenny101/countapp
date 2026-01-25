import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
// Check both the app folder and the android root for key.properties
val keystorePropertiesFile = listOf(
    rootProject.file("app/key.properties"),
    rootProject.file("key.properties")
).firstOrNull { it.exists() }

if (keystorePropertiesFile != null) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.kingbenny101.countapp"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.kingbenny101.countapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        val alias = keystoreProperties["keyAlias"] as? String ?: System.getenv("ANDROID_KEY_ALIAS")
        val keyPass = keystoreProperties["keyPassword"] as? String ?: System.getenv("ANDROID_KEY_PASSWORD")
        val storePass = keystoreProperties["storePassword"] as? String ?: System.getenv("ANDROID_STORE_PASSWORD")
        val storeFileProp = keystoreProperties["storeFile"] as? String ?: System.getenv("ANDROID_STORE_FILE")

        if (alias != null && keyPass != null && storePass != null && storeFileProp != null) {
            create("release") {
                keyAlias = alias
                keyPassword = keyPass
                storeFile = file(storeFileProp)
                storePassword = storePass
            }
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now if release keys are missing, so `flutter run --release` works.
            signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")

            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
