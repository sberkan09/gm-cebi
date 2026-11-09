import java.io.FileInputStream
import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// The --dart-define values reach Gradle base64-encoded in the "dart-defines" property.
val dartDefines: Map<String, String> =
    (project.findProperty("dart-defines") as String?)
        ?.split(",")
        ?.filter { it.isNotBlank() }
        ?.map { String(Base64.getDecoder().decode(it), Charsets.UTF_8) }
        ?.associate { it.substringBefore("=") to it.substringAfter("=", "") }
        ?: emptyMap()

// Internal test builds (GMCEBI_INTERNAL=true: the GitHub test APK) install as a separate app,
// "GM Cebi Test" (…gmcebi.test), so they never collide with the Play build's id and signature.
val internalBuild = dartDefines["GMCEBI_INTERNAL"] == "true"

// Upload-key signing for Play builds (docs/release.md). CI passes the values as environment
// variables (no file, so passwords may contain any character); locally android/key.properties
// is used. Neither the file nor the keystore is ever committed (android/.gitignore).
// Without a key, release builds use the debug key: only for test APKs, Play rejects them.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        FileInputStream(keystorePropertiesFile).use { load(it) }
    }
}
fun signingValue(env: String, key: String): String? =
    System.getenv(env)?.takeIf { it.isNotEmpty() } ?: keystoreProperties.getProperty(key)
val uploadStoreFile = signingValue("ANDROID_KEYSTORE_PATH", "storeFile")
val uploadStorePassword = signingValue("ANDROID_KEYSTORE_PASSWORD", "storePassword")
val uploadKeyAlias = signingValue("ANDROID_KEY_ALIAS", "keyAlias")
val uploadKeyPassword = signingValue("ANDROID_KEY_PASSWORD", "keyPassword")
val signingGiven = keystorePropertiesFile.exists() || System.getenv("ANDROID_KEYSTORE_PATH") != null
val hasUploadKey = listOf(uploadStoreFile, uploadStorePassword, uploadKeyAlias, uploadKeyPassword).all { !it.isNullOrBlank() }
if (signingGiven && !hasUploadKey) {
    error("Upload key incomplete: need storeFile, storePassword, keyAlias, keyPassword (android/key.properties or ANDROID_KEYSTORE_PATH, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD)")
}

android {
    namespace = "io.github.sberkan09.gmcebi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Same id as the iOS bundle id. Irreversible after the first Play upload
        // (docs/decisions.md, docs/release.md).
        applicationId = "io.github.sberkan09.gmcebi"
        if (internalBuild) applicationIdSuffix = ".test"
        manifestPlaceholders["appLabel"] = if (internalBuild) "GM Cebi Test" else "GM Cebi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26 // Android 8.0 (brief)
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasUploadKey) {
            create("upload") {
                // storeFile is resolved relative to android/app/ (e.g. "../upload-keystore.jks"
                // for android/upload-keystore.jks), or given as an absolute path.
                storeFile = file(uploadStoreFile!!)
                storePassword = uploadStorePassword
                keyAlias = uploadKeyAlias
                keyPassword = uploadKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasUploadKey) signingConfigs.getByName("upload") else signingConfigs.getByName("debug")
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
