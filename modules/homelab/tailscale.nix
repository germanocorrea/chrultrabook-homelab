{ config, pkgs, ... }:
let
  cloudflareToken = "**REDACTED**";
  virtualHostConfig = port: {
    extraConfig = ''
      tls {
        dns cloudflare "**REDACTED**"
      }
      reverse_proxy localhost:${port}
    '';
  };
in
{
  # ... outras configurações

  # Habilita o serviço do Tailscale
  services.tailscale.enable = true;
  # services.homelab.cloudflareDnsToken = "**REDACTED**";

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
      hash = "sha256-bJO2RIa6hYsoVl3y2L86EM34Dfkm2tlcEsXn2+COgzo=";
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
      "wallabag.gege.xyz.br" = (virtualHostConfig "8083");
    };
    # virtualHosts."jellyfin.gege.xyz.br".extraConfig = ''
    #   tls {
    #     dns cloudflare "${cloudflareToken}"
    #   }
    #   # Aponta para a porta do Jellyfin definida no seu módulo arr-stack.nix
    #   reverse_proxy localhost:8096
    # '';
  };
}
