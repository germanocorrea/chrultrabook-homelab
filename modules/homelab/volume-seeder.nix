{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.homelab.migration;
in
{
  options.services.homelab.migration = {
    enableRestore = lib.mkEnableOption "Restauração automática de volumes";
    forceOverwrite = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Se verdadeiro, sobrescreve volumes existentes com os tarballs.";
    };
    backupPath = lib.mkOption {
      type = lib.types.path;
      default = ../../volumes;
      description = "Caminho local onde os .tar estão guardados.";
    };
  };

  config = lib.mkIf cfg.enableRestore {
    systemd.services =
      let
        volumes = [
          "bazarr-config"
          "jellyseer-config"
          "qbittorrent-config"
          "radarr-config"
          "sonarr-config"
          "prowlarr-config"
        ];
      in
      lib.listToAttrs (
        map (name: {
          name = "seed-volume-${name}";
          value = {
            description = "Restore volume ${name}";
            wantedBy = [ "multi-user.target" ];
            before = [ "podman-${name}.service" ];
            script = ''
              ${pkgs.podman}/bin/podman volume create ${name} || true
              MOUNTPOINT=$(${pkgs.podman}/bin/podman volume inspect ${name} --format '{{.Mountpoint}}')

              # Se forceOverwrite for true OU o volume estiver vazio, restaura.
              if ${if cfg.forceOverwrite then "true" else "[ -z \"$(ls -A $MOUNTPOINT)\" ]"}; then
                echo "Restaurando volume ${name}..."
                ${pkgs.podman}/bin/podman volume import ${name} ${cfg.backupPath}/${name}.tar
              fi
            '';
            serviceConfig.Type = "oneshot";
          };
        }) volumes
      );
  };
}
