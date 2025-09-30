allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
            authentication {
                create<BasicAuthentication>("basic")
            }
            credentials {
                username = "mapbox"
                    // Read token from gradle properties or environment variables to avoid hardcoding
                    val mapboxTokenFromProps: String? = try {
                        rootProject.extra.properties["MAPBOX_SDK_REGISTRY_TOKEN"] as? String
                    } catch (e: Exception) {
                        null
                    }
                    val mapboxTokenFromEnv: String? = System.getenv("MAPBOX_SDK_REGISTRY_TOKEN")
                    val mapboxTokenFromDownloads: String? = try {
                        rootProject.extra.properties["MAPBOX_DOWNLOADS_TOKEN"] as? String
                    } catch (e: Exception) {
                        null
                    }
                    password = mapboxTokenFromProps ?: mapboxTokenFromEnv ?: mapboxTokenFromDownloads ?: ""
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
