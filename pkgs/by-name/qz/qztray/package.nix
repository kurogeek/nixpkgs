{ lib
, stdenv
, fetchFromGitHub
, jdk11
, ant
, openjfx11
, makeWrapper
, copyDesktopItems
, makeDesktopItem
, imagemagick
, libusb1
, hidapi
}:

let
  # JavaFX modules needed by QZ Tray
  jfxModules = [
    "javafx.base"
    "javafx.controls"
    "javafx.fxml"
    "javafx.graphics"
    "javafx.media"
    "javafx.swing"
    "javafx.web"
  ];

  desktopItem = makeDesktopItem {
    name = "qz-tray";
    exec = "qz-tray";
    icon = "qz-tray";
    desktopName = "QZ Tray";
    comment = "Browser plugin for sending documents and raw commands to a printer or attached device";
    categories = [ "Utility" ];
    startupNotify = false;
  };

in stdenv.mkDerivation rec {
  pname = "qz-tray";
  version = "2.2.6";

  src = fetchFromGitHub {
    owner = "qzind";
    repo = "tray";
    rev = "v${version}";
    # Replace with the real hash after running:
    #   nix-prefetch-url --unpack https://github.com/qzind/tray/archive/refs/tags/v2.2.6.tar.gz
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [
    jdk11
    ant
    makeWrapper
    imagemagick   # for icon conversion (optional)
  ] ++ lib.optional copyDesktopItems.meta.available copyDesktopItems;

  buildInputs = [
    jdk11
    openjfx11
    libusb1
    hidapi
  ];

  # QZ Tray uses an Ant build system and expects to download JavaFX during
  # the build.  We skip that step by pointing ant at the nixpkgs openjfx11
  # package instead, and disable the platform-installer targets (nsis/makeself)
  # so only the JAR + demo assets are produced.
  antFlags = [
    # Tell the build which JavaFX directory to use (skips the download)
    "-Dtarget.fx.dir=${openjfx11}/lib"
    # Prevent ant from trying to download JavaFX from the internet
    "-Djavafx.skip=true"
    # Skip creating the self-extracting Linux installer
    "-Djre.skip=true"
    # Suppress signing (no cert available in the sandbox)
    "-Dstorepass="
    "-Dkeypass="
    # Target OS for native-lib selection
    "-Dtarget.os=linux"
    "-Dtarget.arch=${if stdenv.isAarch64 then "aarch64" else "x64"}"
    # Keep the build minimal (no whitelist/authcert)
    "-Ddist.minimal=true"
  ];

  antTarget = "distribute";

  # The build writes output into dist/ relative to the source root
  buildPhase = ''
    runHook preBuild

    # Expose JDK for the build
    export JAVA_HOME="${jdk11}"

    ant ${antTarget} ${lib.concatStringsSep " " antFlags}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/share/qz-tray"
    install -d "$out/bin"
    install -d "$out/share/pixmaps"

    # Install the main JAR and any support files produced under dist/
    cp -r dist/* "$out/share/qz-tray/"

    # Install icon (convert SVG/PNG from assets if present)
    if [ -f assets/branding/qz-tray.png ]; then
      install -m644 assets/branding/qz-tray.png "$out/share/pixmaps/qz-tray.png"
    elif [ -f assets/qz-tray.png ]; then
      install -m644 assets/qz-tray.png "$out/share/pixmaps/qz-tray.png"
    fi

    # Build the module-path string for JavaFX
    local jfxPath="${openjfx11}/lib"

    # Wrapper script
    makeWrapper "${jdk11}/bin/java" "$out/bin/qz-tray" \
      --add-flags "--module-path $jfxPath" \
      --add-flags "--add-modules ${lib.concatStringsSep "," jfxModules}" \
      --add-flags "-Djava.library.path=${libusb1}/lib:${hidapi}/lib" \
      --add-flags "-jar $out/share/qz-tray/qz-tray.jar" \
      --set JAVA_HOME "${jdk11}"

    runHook postInstall
  '';

  # Copy the desktop entry if copyDesktopItems is available
  desktopItems = [ desktopItem ];

  meta = with lib; {
    description = "Browser plugin for sending documents and raw commands to a printer or attached device";
    longDescription = ''
      QZ Tray is a desktop middleware that acts as a bridge between a web
      browser and local or network printers, label makers, cash drawers, and
      other hardware.  It exposes a WebSocket API so web applications can send
      raw ESC/POS, ZPL, EPL, Star, and other command languages directly to the
      device—without any browser extension.
    '';
    homepage = "https://qz.io";
    license = licenses.lgpl21Plus;
    maintainers = [];
    platforms = platforms.linux;
    mainProgram = "qz-tray";
  };
}
