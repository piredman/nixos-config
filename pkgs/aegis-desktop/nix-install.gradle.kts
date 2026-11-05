// Appended to desktop/build.gradle.kts by the aegis-desktop Nix package.
// Serves the exact set of runtime JARs that the launcher puts on the
// classpath, keeping dependency JARs intact: flattening a signed dependency
// such as Bouncy Castle into an uber-JAR invalidates its signature metadata.
tasks.register<Sync>("nixInstall") {
    from(tasks.named("jar"))
    from(configurations.named("runtimeClasspath"))
    into(layout.buildDirectory.dir("nix/lib"))
}
