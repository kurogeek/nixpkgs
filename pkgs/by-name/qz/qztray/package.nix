{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  unzip,
  jdk11,
  ant,
  openjfx17,
  makeWrapper,
  libusb1,
  hidapi,
  copyDesktopItems,
  makeDesktopItem,
}:

# ---------------------------------------------------------------------------
# QZ Tray 2.2.6 — the ant build (ant/javafx.xml) downloads two JavaFX zips:
#   1. Regular SDK  → extracted into lib/javafx/linux/javafx-sdk-19/
#   2. Monocle SDK  → saved as out/javafx-linux-x86_64-19_monocle.zip
#
# We pre-fetch both as fixed-output derivations and place them before ant
# runs, so the build sandbox never needs network access.
#
# Hashes: run these and paste the output into the hash= fields below:
#   nix-prefetch-url \
#     https://download2.gluonhq.com/openjfx/19/openjfx-19_linux-x64_bin-sdk.zip
#   nix-prefetch-url \
#     https://download2.gluonhq.com/openjfx/19/openjfx-19_monocle-linux-x64_bin-sdk.zip
#   nix-prefetch-url --unpack \
#     https://github.com/qzind/tray/archive/refs/tags/v2.2.6.tar.gz
# ---------------------------------------------------------------------------
let
  jfxVersion = "19";

  jfxSdk = fetchurl {
    url = "https://download2.gluonhq.com/openjfx/${jfxVersion}/openjfx-${jfxVersion}_linux-x64_bin-sdk.zip";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  jfxMonocle = fetchurl {
    url = "https://download2.gluonhq.com/openjfx/${jfxVersion}/openjfx-${jfxVersion}_monocle-linux-x64_bin-sdk.zip";
    hash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
  };

  desktopItem = makeDesktopItem {
    name = "qz-tray";
    exec = "qz-tray";
    icon = "qz-tray";
    desktopName = "QZ Tray";
    comment = "Browser plugin for sending documents and raw commands to a printer or attached device";
    categories = [ "Utility" ];
    startupNotify = false;
  };

  jfxModules = lib.concatStringsSep "," [
    "javafx.base"
    "javafx.controls"
    "javafx.fxml"
    "javafx.graphics"
    "javafx.media"
    "javafx.swing"
    "javafx.web"
  ];

in
stdenv.mkDerivation rec {
  pname = "qz-tray";
  version = "2.2.6";

  src = fetchFromGitHub {
    owner = "qzind";
    repo = "tray";
    rev = "v${version}";
    hash = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=";
  };

  nativeBuildInputs = [
    jdk11
    ant
    unzip
    makeWrapper
    copyDesktopItems
  ];
  buildInputs = [
    jdk11
    openjfx17
    libusb1
    hidapi
  ];

  preBuild = ''
    export JAVA_HOME="${jdk11}"

    # ------------------------------------------------------------------
    # 1. Regular SDK — extracted into the path ant's check-javafx-found
    #    looks for, so it skips the <get> download task.
    # ------------------------------------------------------------------
    mkdir -p lib/javafx/linux
    unzip -q "${jfxSdk}" -d lib/javafx/linux
    echo "Regular SDK: $(ls lib/javafx/linux/)"

    # ------------------------------------------------------------------
    # 2. Monocle SDK — the build downloads it unconditionally to a
    #    hard-coded path under out/. Pre-place the file there so the
    #    <get> task either finds it (if skipexisting="true") or we patch
    #    the xml below to skip the task entirely.
    # ------------------------------------------------------------------
    mkdir -p out
    cp "${jfxMonocle}" "out/javafx-linux-x86_64-${jfxVersion}_monocle.zip"

    # ------------------------------------------------------------------
    # 3. Patch javafx.xml to skip downloading when the destination file
    #    already exists. We replace the bare <get> with one that has
    #    skipexisting="true" so ant won't attempt the network call.
    # ------------------------------------------------------------------
    substituteInPlace ant/javafx.xml \
      --replace-warn \
        'taskdefs.Get$GetThread' \
        'taskdefs.Get$GetThread' \
      --replace-warn \
        '<get src=' \
        '<get skipexisting="true" src='
  '';

  buildPhase = ''
    runHook preBuild

    ant distribute \
      -Dtarget.os=linux \
      -Dtarget.arch=${if stdenv.isAarch64 then "aarch64" else "x64"} \
      -Djre.skip=true \
      -Ddist.minimal=true \
      -Dstorepass= \
      -Dkeypass=

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/share/qz-tray"
    install -d "$out/bin"
    install -d "$out/share/pixmaps"

    cp -r dist/. "$out/share/qz-tray/"

    for icon in assets/branding/qz-tray.png assets/qz-tray.png; do
      [ -f "$icon" ] && install -m644 "$icon" "$out/share/pixmaps/qz-tray.png" && break
    done

    makeWrapper "${jdk11}/bin/java" "$out/bin/qz-tray" \
      --add-flags "--module-path ${openjfx17}/lib" \
      --add-flags "--add-modules ${jfxModules}" \
      --add-flags "-Djava.library.path=${libusb1}/lib:${hidapi}/lib" \
      --add-flags "-jar $out/share/qz-tray/qz-tray.jar" \
      --set JAVA_HOME "${jdk11}"

    runHook postInstall
  '';

  desktopItems = [ desktopItem ];

  meta = with lib; {
    description = "Browser plugin for sending documents and raw commands to a printer or attached device";
    homepage = "https://qz.io";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
    mainProgram = "qz-tray";
  };
}
