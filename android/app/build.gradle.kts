plugins {
    id("com.android.application")
    // EL PLUGIN DE FLUTTER DEBE APLICARSE DESPUES DE LOS PLUGINS DE ANDROID Y KOTLIN
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.nutriscan_express"
    // ASEGURA QUE COMPILESDK SEA AL MENOS 34 PARA COMPATIBILIDAD CON CAMERAX Y ML KIT
    compileSdk = maxOf(flutter.compileSdkVersion, 34)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // IDENTIFICADOR UNICO DE LA APLICACION NUTRISCAN EXPRESS
        applicationId = "com.example.nutriscan_express"
        // ASEGURA QUE MINSDK SEA AL MENOS 21 PARA EL FUNCIONAMIENTO DE MOBILE_SCANNER
        minSdk = maxOf(flutter.minSdkVersion, 21)
        targetSdk = maxOf(flutter.targetSdkVersion, 34)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // FIRMA DE COMPILACION Y DESACTIVACION DE OFUSCACION AGRESIVA PARA EVITAR FALLOS DE CAMARA EN RELEASE
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
