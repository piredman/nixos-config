{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  gradle-packages,
  jdk21,
  jre_minimal,
  makeWrapper,
  runCommand,
  glib,
  polkit,
  libsecret,
  libGL,
  freetype,
  fontconfig,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxrandr,
  libxrender,
  libxtst,
}:

let
  # Match upstream's wrapper instead of whichever Gradle nixpkgs defaults to.
  gradle =
    (gradle-packages.mkGradle {
      version = "9.8.2";
      hash = "sha256-Ib1dot5JtkKQQHfzjA79x3eOkrPtCIk5LcphuX44lgc=";
      defaultJava = jdk21;
    }).wrapped;

  # Upstream's Maven protoc is a statically linked x86_64 Linux executable.
  # Fetch it explicitly so Gradle does not download/execute undeclared tools.
  protoc =
    runCommand "aegis-protoc-4.36.2"
      {
        src = fetchurl {
          url = "https://repo.maven.apache.org/maven2/com/google/protobuf/protoc/4.36.2/protoc-4.36.2-linux-x86_64.exe";
          hash = "sha256-9u4i1lNhM4RZII2ov/gBycpol0HLqRh7NJkN1FGY+GQ=";
        };
      }
      ''
        install -Dm755 "$src" "$out/bin/protoc"
      '';

  runtime = jre_minimal.override {
    jdk = jdk21;
    jdkOnBuild = jdk21;
    modules = [
      "java.desktop"
      "java.instrument"
      "java.logging"
      "java.management"
      "java.naming"
      "java.prefs"
      "java.sql"
      "jdk.unsupported"
    ];
  };

  runtimeLibs = [
    glib
    libsecret
    libGL
    freetype
    fontconfig
    libx11
    libxcursor
    libxext
    libxi
    libxrandr
    libxrender
    libxtst
  ];
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "aegis-desktop";
  # Untagged upstream merge commit; use an unstable suffix per nixpkgs convention.
  version = "0.1.1-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "Kryptos-s";
    repo = "aegis-desktop";
    # desktop 0.1.1 (upstream supersets Android Aegis v3.4.3)
    rev = "becb136dbf65273fc85f4ef7118cc8f9c9881944";
    # NAR hash of the unpacked tree; unlike archive/<rev>.tar.gz URLs, this
    # stays valid if upstream regenerates tarballs.
    hash = "sha256-/F/P5y/H/5AvPXVEIZqFO9JU5cIyv0iL+PAlCc8A36w=";
  };

  nativeBuildInputs = [
    gradle
    jdk21
    makeWrapper
  ];

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  env.JAVA_HOME = "${jdk21}";
  gradleFlags = [
    "-Dorg.gradle.java.installations.auto-download=false"
    "-Dorg.gradle.java.installations.paths=${jdk21}"
    "-Pkotlin.compiler.execution.strategy=in-process"
  ];
  gradleBuildTask = ":desktop:nixInstall";
  gradleCheckTask = ":core:test :platform:test :desktop:test";
  gradleUpdateTask = "${finalAttrs.gradleBuildTask} ${finalAttrs.gradleCheckTask}";
  doCheck = true;

  postPatch = ''
    substituteInPlace core/build.gradle.kts \
        --replace-fail 'artifact = libs.protobuf.protoc.get().toString()' \
            'path = "${protoc}/bin/protoc"'

    substituteInPlace platform/src/main/kotlin/com/beemdevelopment/aegis/desktop/platform/linux/DBusSessionMonitor.kt \
        --replace-fail 'listOf("/usr/bin/gdbus", "/bin/gdbus", "/usr/local/bin/gdbus")' \
            'listOf("${lib.getExe' glib "gdbus"}")'

    substituteInPlace platform/src/main/kotlin/com/beemdevelopment/aegis/desktop/platform/linux/PolkitUserPresence.kt \
        --replace-fail 'listOf("/usr/bin/pkcheck", "/bin/pkcheck", "/usr/local/bin/pkcheck")' \
            'listOf("${lib.getExe' polkit "pkcheck"}")'

    substituteInPlace packaging/linux/com.beemdevelopment.aegis.desktop \
        --replace-fail 'Exec=aegis %f' 'Exec=aegis %u'

    # Register the copy task upstream's uber-JAR path would bypass. The task
    # keeps dependency JARs intact (flattening a signed dependency such as
    # Bouncy Castle into an uber-JAR invalidates its signature metadata).
    cat "${./nix-install.gradle.kts}" >> desktop/build.gradle.kts
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/aegis-desktop"
    cp desktop/build/nix/lib/*.jar "$out/share/aegis-desktop/"

    # Java AWT needs this hint on non-reparenting tiling WMs such as Hyprland.
    # Set it here so launcher and terminal rendering do not depend on session env.
    makeWrapper ${runtime}/bin/java "$out/bin/aegis" \
        --run 'ulimit -c 0 2>/dev/null || true' \
        --set JAVA_HOME "${runtime}" \
        --set _JAVA_AWT_WM_NONREPARENTING 1 \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}" \
        --add-flag '-XX:-HeapDumpOnOutOfMemoryError' \
        --add-flag '-XX:+DisableAttachMechanism' \
        --add-flag '-XX:-UsePerfData' \
        --add-flag '-cp' \
        --add-flag "$out/share/aegis-desktop/*" \
        --add-flag 'com.beemdevelopment.aegis.desktop.MainKt'

    install -Dm644 packaging/linux/com.beemdevelopment.aegis.desktop \
        "$out/share/applications/com.beemdevelopment.aegis.desktop"
    install -Dm644 desktop/src/main/resources/icons/aegis.png \
        "$out/share/icons/hicolor/512x512/apps/com.beemdevelopment.aegis.png"
    install -Dm644 LICENSE "$out/share/licenses/aegis-desktop/LICENSE"

    runHook postInstall
  '';

  # Polkit reads the system profile, not Home Manager's user profile. Keep
  # its policy in a small separate output package for the NixOS module.
  passthru.polkitPolicy = stdenvNoCC.mkDerivation {
    pname = "aegis-desktop-polkit-policy";
    inherit (finalAttrs) version src;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm644 packaging/linux/com.beemdevelopment.aegis.policy \
          "$out/share/polkit-1/actions/com.beemdevelopment.aegis.policy"
      runHook postInstall
    '';
  };

  meta = {
    description = "Unofficial desktop port of Aegis Authenticator";
    homepage = "https://github.com/Kryptos-s/aegis-desktop";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "aegis";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
      binaryNativeCode
    ];
  };
})
