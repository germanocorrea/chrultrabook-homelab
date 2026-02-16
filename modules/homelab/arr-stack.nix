{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.homelab;
  # brokerBotImage = pkgs.dockerTools.buildImage {
  #   name = "brokerbot";
  #   tag = "latest";
  #   # copyToRoot = [ pkgs.myBrokerBotPackage ];
  #   config = {
  #     Cmd = [ "brokerbot" ];
  #     WorkingDir = "/";
  #   };
  # };
  # connectiontesterImage = pkgs.dockerTools.buildImage {
  #   name = "connectiontester";
  #   tag = "latest";
  #   config = {
  #     Cmd = [ "connectiontester" ];
  #     WorkingDir = "/";
  #   };
  # };
in
{
  options.services.homelab = {
    storage = mkOption {
      type = types.path;
      description = "Default storage for all bind mounts";
    };
    # brokerbotSocket = mkOption {
    #   type = types.path;
    #   description = "Default path of brokerbot socket";
    # };
  };

  config = {
    systemd.tmpfiles.rules = [
      # "d /run/user/1000/brokerbot 0755 gege users - -"
      # "d /home/gege/.config/brokerbot/ 0755 gege users - -"
      # "d ${toString cfg.storage} 0755 gege users - -"
      # "d ${toString cfg.storage}/Media 0755 gege users - -"
      # "d ${toString cfg.storage}/Media/torrents 0755 gege users - -"
      # "d ${toString cfg.storage}/socket-sender 0755 gege users - -"
      # "f ${toString cfg.storage}/prestart-brokerbot.sh 0755 gege users - -"
    ];
    environment.systemPackages = with pkgs; [
      dive
      podman-tui
      podman-compose
    ];
    virtualisation = {
      containers = {
        enable = true;
        storage.settings = {
          storage = {
            driver = "overlay";
            graphroot = "${toString cfg.storage}/container-images";
          };
        };
      };
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      oci-containers.backend = "podman";
      oci-containers.containers = {
        sonarr = {
          autoStart = true;
          image = "lscr.io/linuxserver/sonarr:latest";
          ports = [ "8989:8989/tcp" ];
          environment = {
            PUID = toString config.users.users.gege.uid;
            PGID = toString config.users.groups.users.gid;
            UMASK = "002";
            TZ = "America/Sao_Paulo";
          };
          volumes = [
            "${toString cfg.storage}/Media:/data:Z"
            "sonarr-config:/config:Z"
          ];
          extraOptions = [
            "--network=media-download.network"
          ];
        };

        radarr = {
          autoStart = true;
          image = "lscr.io/linuxserver/radarr:latest";
          ports = [ "7878:7878/tcp" ];
          environment = {
            PUID = toString config.users.users.gege.uid;
            PGID = toString config.users.groups.users.gid;
            UMASK = "002";
            TZ = "America/Sao_Paulo";
          };
          volumes = [
            "${toString cfg.storage}/Media:/data:Z"
            "radarr-config:/config:Z"
          ];
          extraOptions = [
            "--network=media-download.network"
          ];
        };

        bazarr = {
          autoStart = true;
          image = "lscr.io/linuxserver/bazarr:latest";
          ports = [ "6767:6767/tcp" ];
          environment = {
            PUID = toString config.users.users.gege.uid;
            PGID = toString config.users.groups.users.gid;
            UMASK = "002";
            TZ = "America/Sao_Paulo";
            WEBUI_PORTS = "6767/tcp,6767/udp";
          };
          volumes = [
            "${toString cfg.storage}/Media:/data:Z"
            "bazarr-config:/config:Z"
          ];
          extraOptions = [
            "--network=media-download.network"
          ];
        };

        # brokerbot = {
        #   autoStart = true;
        #   image = "brokerbot:latest";
        #   imageStream = brokerBotImage;
        #   environment = {
        #     NGROK_AUTHTOKEN = "**REDACTED**";
        #   };
        #   volumes = [ "${toString cfg.brokerbotSocket}:${toString cfg.brokerbotSocket}" ];
        #   cmd = [
        #     "-ngrok"
        #     "-token=**REDACTED**"
        #     "-password=**REDACTED**"
        #     "-socket=${toString cfg.brokerbotSocket}brokerbot.sock"
        #     "-webhook-secret-token=**REDACTED**"
        #   ];
        # };

        # connectiontester = {
        #   image = "connectiontester:latest";
        #   imageStream = connectiontesterImage;
        #   volumes = [ "${toString cfg.brokerbotSocket}:${toString cfg.brokerbotSocket}" ];
        #   cmd = [
        #     "-socket=${toString cfg.brokerbotSocket}brokerbot.sock"
        #     "-address=google.com:80"
        #   ];
        #   dependsOn = [ "brokerbot" ];
        # };

        flaresolverr = {
          autoStart = true;
          image = "ghcr.io/flaresolverr/flaresolverr:latest";
          ports = [ "8191:8191/tcp" ];
          environment = {
            LOG_LEVEL = "debug";
          };
          extraOptions = [
            "--network=media-download.network"
          ];
        };

        jellyfin = {
          autoStart = true;
          image = "docker.io/jellyfin/jellyfin:latest";
          ports = [ "8096:8096/tcp" ];
          environment = {
            PUID = toString config.users.users.gege.uid;
            PGID = toString config.users.groups.users.gid;
          };
          volumes = [
            "jellyfin-config:/config:Z"
            "jellyfin-cache:/cache:Z"
            "${toString cfg.storage}/Media:/data/Media:Z"
          ];
          extraOptions = [
            "--network=media-download.network"
            "--no-healthcheck"
          ];
        };

        jellyseerr = {
          autoStart = true;
          image = "docker.io/fallenbagel/jellyseerr";
          ports = [ "5055:5055/tcp" ];
          environment = {
            TZ = "America/Sao_Paulo";
            PORT = "5055";
            PUID = toString config.users.users.gege.uid;
            PGID = toString config.users.groups.users.gid;
          };
          volumes = [ "jellyseer-config:/app/config" ];
          extraOptions = [ "--network=media-download.network" ];
        };

        prowlarr = {
          autoStart = true;
          image = "lscr.io/linuxserver/prowlarr:latest";
          ports = [ "9696:9696/tcp" ];
          environment = {
            PUID = toString config.users.users.gege.uid;
            PGID = toString config.users.groups.users.gid;
            UMASK = "002";
            TZ = "America/Sao_Paulo";
          };
          volumes = [ "prowlarr-config:/config:Z" ];
          extraOptions = [
            "--network=media-download.network"
          ];
        };

        qbittorrent = {
          autoStart = true;
          image = "lscr.io/linuxserver/qbittorrent:latest";
          ports = [
            "8080:8080/tcp"
            "6881:6881/tcp"
            "6881:6881/udp"
          ];
          environment = {
            PUID = toString config.users.users.gege.uid;
            PGID = toString config.users.groups.users.gid;
            UMASK = "022";
            TZ = "America/Sao_Paulo";
            WEBUI_PORT = "8080";
            TORRENTING_PORT = "6881";
          };
          volumes = [
            "${toString cfg.storage}/Media/torrents:/data/torrents:Z"
            "qbittorrent-config:/config:Z"
            # "${toString cfg.brokerbotSocket}:${toString cfg.brokerbotSocket}"
            # "${toString cfg.storage}/socket-sender/:/run/user/1000/socket-sender/"
          ];
          extraOptions = [
            "--network=media-download.network"
          ];
        };

        wallabag = {
          autoStart = true;
          image = "docker.io/wallabag/wallabag:latest";
          ports = [
            "8083:8080/tcp" # revisar a porta de saida
          ];
          environment = {
            PUID = toString config.users.users.gege.uid;
            PGID = toString config.users.groups.users.gid;
            SYMFONY__ENV__DOMAIN_NAME = "https://wallabag.gege.xyz.br";
          };
          volumes = [
            "${toString cfg.storage}/Wallabag/data:/var/www/wallabag/data:Z"
            "${toString cfg.storage}/Wallabag/images:/var/www/wallabag/web/assets/images:Z"
          ];
        };
      };
    };

    systemd.services.init-podman-network = {
      description = "Cria a rede podman media-download";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.podman}/bin/podman network inspect media-download.network || \
        ${pkgs.podman}/bin/podman network create media-download.network \
            --subnet 192.168.30.0/24 \
            --gateway 192.168.30.1 \
            --label media-download
      '';
    };

    # Configurações de serviço adicionais (ExecStartPre e SuccessExitStatus) [cite: 3, 6]
    # systemd.services.podman-brokerbot.serviceConfig.ExecStartPre =
    #   "${toString cfg.storage}/prestart-brokerbot.sh";
    # systemd.services.podman-jellyfin.serviceConfig.SuccessExitStatus = [
    #   0
    #   143
    # ];
  };
}
