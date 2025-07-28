{ pkgs ? import <nixpkgs> {} }:

let
  baseApp = pkgs.flutter.buildFlutterApplication {
 pname = "glfos_welcome_screen";
    version = "main";  # Utilisez la même version que dans le flake.nix
    
    src = fetchFromGitHub {
      owner = "Gaming-Linux-FR";
      repo = "glfos-welcome-screen";
      rev = "main"; 
      sha256 = lib.fakeSha256;  
    };

    flutterChannel = "stable";  # Can be "beta", "master", etc.

    nativeBuildInputs = with pkgs; [
      pkg-config
    ];

    buildInputs = with pkgs; [
      gtk4
      libadwaita
      libepoxy
      libxkbcommon
      glib
      cairo
      pango
      atk
    ];

    buildPhase = ''
      rm -rf build

      # Try to override RPATH in Flutter's cmake phase
    export CMAKE_BUILD_RPATH_USE_ORIGIN=ON
    export CMAKE_SKIP_BUILD_RPATH=OFF
    export CMAKE_INSTALL_RPATH="$out/lib"
    export CMAKE_BUILD_RPATH="$out/lib"
    export CMAKE_INSTALL_RPATH_USE_LINK_PATH=FALSE
    export CMAKE_INSTALL_RPATH_USE_ORIGIN=ON

      flutter build linux --release
    '';

    installPhase = ''
  mkdir -p $out/bin
  cp -r build/linux/x64/release/bundle/* $out/

  ln -s $out/glfos_welcome_screen $out/bin/glfos_welcome_screen

  # Remove bad /build RPATHs in shared libs
  for lib in $out/lib/*.so; do
    if patchelf --print-rpath "$lib" | grep -q "/build"; then
      echo "Fixing RPATH in $lib"
      patchelf --set-rpath "$out/lib" "$lib"
    fi
  done
'';

    strictDeps = true;


    autoPubspecLock = ./pubspec.lock;

    meta = with pkgs.lib; {
      description = "Welcome screen";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };
in
# Override outputs to disable 'debug' output that causes build failure
baseApp.overrideAttrs (_: {
  outputs = [ "out" ];
})
