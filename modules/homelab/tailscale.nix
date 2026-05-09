{ config, pkgs, ... }:
let
  virtualHostConfig = port: {
    extraConfig = ''
      tls {
        dns cloudflare {env.CLOUDFLARE_TOKEN}
      }
      reverse_proxy localhost:${port}
    '';
  };
in
{
  # ... outras configurações

  # Habilita o serviço do Tailscale
  services.tailscale.enable = true;

  # Pacotes necessários
  environment.systemPackages = with pkgs; [
    tailscale
    caddy # Adicionando o Caddy aqui também
  ];

  # Permite o tráfego do Tailscale no firewall
  networking.firewall.checkReversePath = "loose";
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services.caddy = {
    enable = true;
    # Usamos o pacote com suporte a DNS Cloudflare
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.3" ];
      hash = "sha256-+htYZclHv9qI0TeHcBFvPkWzJVAZ5jqzTODrh4YmqXY=";
    };

    virtualHosts = {
      "sonarr.gege.xyz.br" = (virtualHostConfig "8989");
      "radarr.gege.xyz.br" = (virtualHostConfig "7878");
      "bazarr.gege.xyz.br" = (virtualHostConfig "6767");
      "flaresolverr.gege.xyz.br" = (virtualHostConfig "8191");
      "jellyfin.gege.xyz.br" = (virtualHostConfig "8096");
      "jellyseer.gege.xyz.br" = (virtualHostConfig "5055");
      "prowlarr.gege.xyz.br" = (virtualHostConfig "9696");
      "torrent.gege.xyz.br" = (virtualHostConfig "8080");
      "cockpit.gege.xyz.br" = (virtualHostConfig "9090");
      "wallabag.gege.xyz.br" = (virtualHostConfig "8181");
      "archiveteam-warrior.gege.xyz.br" = (virtualHostConfig "8001");
    };
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates."caddy.env".path;
}
