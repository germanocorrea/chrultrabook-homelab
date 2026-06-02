{ config, pkgs, ... }:
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
}
