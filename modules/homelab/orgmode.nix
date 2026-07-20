{ config, lib, pkgs, doomConfigDir, ... }:
let
  user = "gege";

  timerBasedAction = parameters: {
    systemd.user.services.${parameters.slug} = {
      description = parameters.slug;
      after = [ "emacs.service" ];
      wants = [ "emacs.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.emacs}/bin/emacsclient --eval '(${parameters.command})'";
      };
    };

    systemd.user.timers.${parameters.slug} = {
      description = "Run ${parameters.slug} periodically";
      timerConfig = {
        OnBootSec = "30s";
        OnUnitActiveSec = "30s";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
in
lib.mkMerge [
  {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      guiAddress = "127.0.0.1:8384";
      settings.gui = {
        insecureSkipHostcheck = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ 8384 ];

    environment.systemPackages = with pkgs; [
      syncthing
      emacs
      ripgrep
      fd
      symbola
    ];

    fonts.packages = with pkgs; [
      symbola
    ];

    services.emacs.enable = true;

    system.activationScripts.doomSync = {
      text = ''
        ${pkgs.util-linux}/bin/runuser - ${user} -c '
          set -e

          if [ ! -d /home/${user}/.config/emacs ]; then
            ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs \
              /home/${user}/.config/emacs
          fi

          mkdir -p /home/${user}/.config/doom
          cp -rL --no-preserve=mode ${doomConfigDir}/. /home/${user}/.config/doom/
          chmod -R u+w /home/${user}/.config/doom

          if [ ! -d /home/${user}/.config/emacs/.local ]; then
            /home/${user}/.config/emacs/bin/doom install --force
          else
            /home/${user}/.config/emacs/bin/doom sync
          fi
        '
      '';
      deps = [];
    };
  }

  (lib.mkMerge (map timerBasedAction [
    { slug = "org-roam-sync"; command = "org-roam-db-sync"; }
    { slug = "org-calendar-sync"; command = "org-icalendar-combine-agenda-files"; }
  ]))
]
