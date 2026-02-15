{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.homelab.migration;

  # Obtém todos os containers definidos em oci-containers
  allContainers = config.virtualisation.oci-containers.containers;

  # Função para extrair volumes nomeados de um container
  getNamedVolumes =
    container:
    let
      volumeNames = map (v: lib.head (lib.splitString ":" v)) container.volumes or [ ];
    in
    lib.filter (v: !lib.hasPrefix "/" v && !lib.hasPrefix "." v) volumeNames;

  volumeToContainerMap = lib.flatten (
    lib.mapAttrsToList (
      containerName: container:
      map (volumeName: {
        volume = volumeName;
        container = containerName;
      }) (getNamedVolumes container)
    ) allContainers
  );

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
    systemd.services = lib.listToAttrs (
      map (
        mapping:
        let
          name = mapping.volume;
          containerName = mapping.container;
        in
        {
          name = "seed-volume-${name}";
          value = {
            description = "Restore volume ${name} for container ${containerName}";
            wantedBy = [ "multi-user.target" ];
            before = [ "podman-${containerName}.service" ];
            script = ''
              ${pkgs.podman}/bin/podman volume create ${name} || true
              MOUNTPOINT=$(${pkgs.podman}/bin/podman volume inspect ${name} --format '{{.Mountpoint}}')

              if ${if cfg.forceOverwrite then "true" else "[ -z \"$(ls -A $MOUNTPOINT)\" ]"}; then
                if [ -f "${cfg.backupPath}/${name}.tar" ]; then
                  echo "Limpando e restaurando ${name}..."
                  rm -rf "$MOUNTPOINT"/*
                  ${pkgs.podman}/bin/podman volume import ${name} "${cfg.backupPath}/${name}.tar"
                fi
              fi

              # Garante que o gege (1000) seja o dono para que o PUID funcione
              chown -R 1000:100 "$MOUNTPOINT"
            '';
            serviceConfig.Type = "oneshot";
          };
        }
      ) volumeToContainerMap
    );
  };
}
