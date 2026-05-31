{ config, pkgs, ... }:
{
  # ... outras configurações

  # Habilita o serviço do Tailscale
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      guiAddress = "0.0.0.0:8384";
    };

  networking.firewall.allowedTCPPorts = [ 8384 ];

  environment.systemPackages = with pkgs; [
    syncthing
  ];
}
