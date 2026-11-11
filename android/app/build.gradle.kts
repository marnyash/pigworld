import java.io.FileInputStream
import java.security.KeyStore
import java.security.MessageDigest
import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}
val isReleaseBuildRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
if (isReleaseBuildRequested && keystorePropertiesFile.exists()) {
    val requiredProperties = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
    val missingProperties = requiredProperties.filter {
        keystoreProperties.getProperty(it).isNullOrBlank()
    }
    if (missingProperties.isNotEmpty()) {
        throw GradleException(
            "Release signing configuration is incomplete. Missing: ${missingProperties.joinToString()}."
        )
    }
    val placeholderProperties = requiredProperties.filter {
        keystoreProperties.getProperty(it).contains("REPLACE_WITH", ignoreCase = true)
    }
    if (placeholderProperties.isNotEmpty()) {
        throw GradleException(
            "Release signing configuration still contains placeholder values for: " +
                "${placeholderProperties.joinToString()}. Replace them in android/key.properties with the original keystore credentials."
        )
    }

    val keystoreFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
    if (!keystoreFile.isFile) {
        throw GradleException("Release keystore file does not exist: ${keystoreFile.path}")
    }

    val keystoreType = if (keystoreFile.extension.lowercase() in setOf("p12", "pfx")) {
        "PKCS12"
    } else {
        "JKS"
    }
    val keystore = KeyStore.getInstance(keystoreType)
    FileInputStream(keystoreFile).use {
        keystore.load(it, keystoreProperties.getProperty("storePassword").toCharArray())
    }
    val certificate = keystore.getCertificate(keystoreProperties.getProperty("keyAlias"))
        ?: throw GradleException("The configured signing key alias was not found in the keystore.")
    val actualSha1 = MessageDigest.getInstance("SHA-1")
        .digest(certificate.encoded)
        .joinToString(":") { "%02X".format(it.toInt() and 0xFF) }
    val actualSha256 = MessageDigest.getInstance("SHA-256")
        .digest(certificate.encoded)
        .joinToString(":") { "%02X".format(it.toInt() and 0xFF) }
    val expectedSha1 = "C4:CB:DE:41:61:71:DA:50:45:68:24:35:43:14:77:C7:C6:8E:C3:1B"
    val expectedSha256 =
        "BE:53:AE:13:48:72:C0:23:96:73:82:E8:6E:79:09:33:7B:7B:E6:26:84:26:34:58:9D:D8:4A:A9:9B:AD:63:AE"
    if (!actualSha1.equals(expectedSha1, ignoreCase = true) ||
        !actualSha256.equals(expectedSha256, ignoreCase = true)
    ) {
        throw GradleException(
            "Wrong release signing certificate. Expected SHA-1 $expectedSha1 and " +
                "SHA-256 $expectedSha256 but found SHA-1 $actualSha1 and SHA-256 $actualSha256."
        )
    }
}

android {
    namespace = "com.pigworld"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.pigworld"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
            )
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.create("release") {
                    storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                    storePassword = keystoreProperties["storePassword"] as String
                    keyAlias = keystoreProperties["keyAlias"] as String
                    keyPassword = keystoreProperties["keyPassword"] as String
                }
            } else if (isReleaseBuildRequested) {
                throw GradleException(
                    "Release signing is not configured. Add android/key.properties and the original upload keystore; " +
                        "the expected upload certificate SHA-1 is " +
                            "C4:CB:DE:41:61:71:DA:50:45:68:24:35:43:14:77:C7:C6:8E:C3:1B and " +
                            "SHA-256 is " +
                            "BE:53:AE:13:48:72:C0:23:96:73:82:E8:6E:79:09:33:7B:7B:E6:26:84:26:34:58:9D:D8:4A:A9:9B:AD:63:AE."
                )
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
