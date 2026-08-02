import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { reader ->
        localProperties.load(reader)
    }
}

val flutterRoot: String = localProperties.getProperty("flutter.sdk")
    ?: error("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"
val adMobAppId = localProperties.getProperty("AdMobAppId") ?: "ca-app-pub-3940256099942544~3347511713"

android {
    namespace = "com.appsbay.mechanical_engineering_toolkit"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.appsbay.mechanical_engineering_toolkit"
        // Android 7.0. Pinned explicitly: it was raised to 36 by accident in
        // aacfe4c alongside the targetSdk bump, which made v1.6.0 uninstallable
        // on virtually every device. Do not raise without a deliberate decision.
        minSdk = 24
        targetSdk = 36
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
        multiDexEnabled = true
        manifestPlaceholders["AdMobAppId"] = adMobAppId
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { storeFilePath -> file(storeFilePath.toString()) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.2.20")
    implementation("androidx.multidex:multidex:2.0.1")
} 
