import org.gradle.api.tasks.Delete

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

// Correct way to set build directories
rootProject.buildDir = file("../build")
subprojects {
    buildDir = file("${rootProject.buildDir}/${name}")
}

// Ensure correct string formatting
subprojects {
    evaluationDependsOn(":app")
}

// Correct way to register the clean task
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
