{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

let
  goatcounter = pkgsMusl.buildGo123Module rec {
    pname = "goatcounter";
    version = "git";
    src = fetchFromGitHub {
      owner = "arp242";
      repo = "goatcounter";
      rev = "530ab5edff553923fb04d9e1b1a9771f8a6d0461";
      hash = "sha256-8n6d89pm8Itm9OodF3SdXplOKf3ocxSWgZ+VE7FyX68=";
    };

    vendorHash = "sha256-8W/xQ8jkNjjmaAvdoY/66HCW7dA+pFC4MVc17J/3B5o=";

    subPackages = [
      "cmd/goatcounter"
    ];

    ldflags = [
      "-X zgo.at/goatcounter/v2.Version=${src.rev}"
      "-s"
      "-w"
      "-linkmode 'external'"
      "-extldflags '-static'"
    ];

    tags = [
      "osusergo"
      "netgo"
      "sqlite_omit_load_extension"
    ];
  };

  busybox-static = pkgsMusl.busybox.override {
    enableStatic = true;
  };

  entrypoint = writeScriptBin "entrypoint.sh" ''
    #!/bin/sh

    test -d /data || mkdir -p /data
    chown -R 0:0 /data

    if test ! -e /data/sqlite3.db ; then
      goatcounter db create site \
        -db sqlite3+/data/sqlite3.db -createdb \
        -vhost "''${GOAT_VHOST}" \
        -user.email "''${GOAT_EMAIL}" \
        -user.password "''${GOAT_PASSWORD}"
    fi

    unset GOAT_VHOST
    unset GOAT_EMAIL
    unset GOAT_SECRET

    goatcounter serve \
      -listen 0.0.0.0:9080 \
      -tls proxy \
      -db sqlite3+/data/sqlite3.db \
      -automigrate \
      -websocket \
      -email-from ''${GOAT_EMAIL_FROM}
  '';
in

dockerTools.buildImage rec {
  name = "kalaclista-analytics-v2";
  tag = "latest";

  copyToRoot = pkgsMusl.buildEnv {
    inherit name;

    paths = [
      goatcounter
      entrypoint
      busybox-static
    ];

    pathsToLink = [
      "/bin"
    ];

    postBuild = ''
      mkdir -p $out/var/run/kalaclista
    '';
  };

  config = {
    WorkingDir = "/var/run/kalaclista";
    Entrypoint = [ "entrypoint.sh" ];
  };
}
