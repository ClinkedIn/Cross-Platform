buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0") // Adjust version as needed
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0") // Adjust version as needed
        classpath("com.google.gms:google-services:4.4.1") // Firebase classpath
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory configuration
rootProject.layout.buildDirectory.set(file("../build"))

subprojects {
    project.layout.buildDirectory.set(file("${rootProject.layout.buildDirectory.get()}/${project.name}"))
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}