import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

fun Project.forceAndroidCompat() {
    extensions.findByName("android")?.let { androidExt ->
        // Force compileSdk 36 for old plugins still pinned to 31 (AAR metadata checks).
        val compileSdkCandidates = listOf(
            "setCompileSdkVersion",
            "setCompileSdk",
        )
        for (methodName in compileSdkCandidates) {
            val method = androidExt.javaClass.methods.firstOrNull {
                it.name == methodName && it.parameterTypes.size == 1
            } ?: continue
            val param = method.parameterTypes[0]
            try {
                when {
                    param == Int::class.javaPrimitiveType -> method.invoke(androidExt, 36)
                    param == Int::class.javaObjectType || param == Integer::class.java ->
                        method.invoke(androidExt, Integer.valueOf(36))
                    param == String::class.java -> method.invoke(androidExt, "android-36")
                    else -> continue
                }
                break
            } catch (_: Throwable) {
                // Try next setter signature.
            }
        }

        // Groovy plugins often expose compileSdkVersion as a bean property.
        try {
            val meta = androidExt.javaClass.methods.firstOrNull {
                it.name == "setProperty" && it.parameterTypes.size == 2
            }
            meta?.invoke(androidExt, "compileSdkVersion", 36)
            meta?.invoke(androidExt, "compileSdk", 36)
        } catch (_: Throwable) {
            // Ignore.
        }

        try {
            val compileOptions = androidExt.javaClass.methods
                .firstOrNull { it.name == "getCompileOptions" && it.parameterCount == 0 }
                ?.invoke(androidExt)
            if (compileOptions != null) {
                compileOptions.javaClass.methods
                    .firstOrNull { it.name == "setSourceCompatibility" && it.parameterTypes.size == 1 }
                    ?.invoke(compileOptions, JavaVersion.VERSION_17)
                compileOptions.javaClass.methods
                    .firstOrNull { it.name == "setTargetCompatibility" && it.parameterTypes.size == 1 }
                    ?.invoke(compileOptions, JavaVersion.VERSION_17)
            }
        } catch (_: Throwable) {
            // Ignore plugins without compileOptions.
        }
    }

    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
    }

    tasks.withType<KotlinCompile>().configureEach {
        compilerOptions.jvmTarget.set(JvmTarget.JVM_17)
    }
}

// Align compileSdk + JVM for every Flutter plugin module.
subprojects {
    pluginManager.withPlugin("com.android.library") {
        forceAndroidCompat()
    }
    pluginManager.withPlugin("com.android.application") {
        forceAndroidCompat()
    }

    if (state.executed) {
        forceAndroidCompat()
    } else {
        afterEvaluate { forceAndroidCompat() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
