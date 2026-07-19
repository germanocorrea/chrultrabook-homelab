{ config, pkgs, doomConfigDir, ... }:
let
  user = "gege";
in
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
  ];

  services.emacs.enable = true

  system.activationScripts.doomSync = {
    text = ''
      ${pkgs.util-linux}/bin/runuser - ${toString user} -c '
        set -e

        if [ ! -d /home/${toString user}/.config/emacs ]; then
          ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs \
            /home/${toString user}/.config/emacs
        fi

        mkdir -p /home/${toString user}/.config/doom
        cp -rL --no-preserve=mode ${toString doomConfigDir}/. /home/${toString user}/.config/doom/
        chmod -R u+w /home/${toString user}/.config/doom

        if [ ! -d /home/${toString user}/.config/emacs/.local ]; then
          /home/${toString user}/.config/emacs/bin/doom install --force
        else
          /home/${toString user}/.config/emacs/bin/doom sync
        fi
      '
    '';
    deps = [];
  };
}
