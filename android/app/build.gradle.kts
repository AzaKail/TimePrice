import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

android {
    namespace = "com.timeprice.time_price"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.timeprice.time_price"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName

        manifestPlaceholders["applicationName"] = "android.app.Application"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    applicationVariants.all {
        outputs.all {
            val output = this as com.android.build.gradle.internal.api.ApkVariantOutputImpl
            val abi = output.getFilter(com.android.build.OutputFile.ABI)
            val baseName = "time_price_v0.1"
            if (abi != null) {
                output.outputFileName = "${baseName}_${abi}.apk"
            } else {
                output.outputFileName = "${baseName}.apk"
            }
        }
    }
}

flutter {
    source = "../.."
}
