{
  description = "GLF OS Welcome Screen using Flutter 3.2.7";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            # Overlay to expose flutter327
            (final: prev: {
              flutter327 = prev.callPackage "${nixpkgs}/pkgs/development/compilers/flutter/versions/flutter_3_2_7" {};
            })
          ];
        };

        flutter327 = pkgs.flutter327;
      in {
        packages.default = flutter327.buildFlutterApplication {
           pname = "glfos_welcome_screen";
    version = "main";  
    
    src = fetchFromGitHub {
      owner = "Gaming-Linux-FR";
      repo = "glfos-welcome-screen";
      rev = "main"; 
      sha256 = lib.fakeSha256;  
    };

          flutterBuildArgs = [ "linux" ];

          nativeBuildInputs = with pkgs; [
            pkg-config
            libadwaita
            glib
            gtk3
          ];

          meta = with pkgs.lib; {
            description = "GLF OS Welcome screen built with Flutter 3.2.7";
            homepage = "https://github.com/imikado/glfos-welcome-screen";
            license = licenses.mit;
            platforms = platforms.linux;
          };
        };
      });
}
