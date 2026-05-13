import com.android.build.gradle.internal.api.ApkVariantOutputImpl

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

val fisioSportBaseUrl = (project.findProperty("FISIO_SPORT_BASE_URL") as String?)
    ?: "http://31.70.74.92:8080/Fisio-e-Sport-webapp"
val fisioSportTestOverlayEnabled = ((project.findProperty("FISIO_SPORT_TEST_OVERLAY") as String?)
    ?: "false").toBoolean()
val fisioSportTestApp = ((project.findProperty("FISIO_SPORT_TEST_APP") as String?)
    ?: "false").toBoolean()

android {
    namespace = "it.simosw.fisioesport"
    compileSdk = 35

    defaultConfig {
        applicationId = "it.simosw.fisioesport"
        manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher"
        manifestPlaceholders["appRoundIcon"] = "@mipmap/ic_launcher_round"
        if (fisioSportTestApp) {
            applicationIdSuffix = ".test"
            resValue("string", "app_name", "Fisio e Sports Test")
            manifestPlaceholders["appIcon"] = "@drawable/ic_launcher_test"
            manifestPlaceholders["appRoundIcon"] = "@drawable/ic_launcher_test_round"
        }
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        buildConfigField("String", "FISIO_SPORT_BASE_URL", "\"$fisioSportBaseUrl\"")
        buildConfigField("boolean", "TEST_OVERLAY_ENABLED", fisioSportTestOverlayEnabled.toString())
    }

    buildTypes {
        debug {
            isMinifyEnabled = false
        }
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        buildConfig = true
    }
}

android.applicationVariants.configureEach {
    outputs.configureEach {
        (this as ApkVariantOutputImpl).outputFileName = "FisioESport.apk"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.swiperefreshlayout:swiperefreshlayout:1.1.0")
}
