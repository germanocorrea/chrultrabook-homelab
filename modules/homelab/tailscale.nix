{ config, pkgs, ... }:
let
  virtualHostConfig = port: {
    extraConfig = ''
      tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        resolvers 1.1.1.1 8.8.8.8
      }
      reverse_proxy 127.0.0.1:${port}
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
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-J0HWjCPoOoARAxDpG2bS9c0x5Wv4Q23qWZbTjd8nW84=";
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
      "sync.gege.xyz.br" = (virtualHostConfig "8384");
      "public.gege.xyz.br" = {
        extraConfig = ''
          tls {
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
            resolvers 1.1.1.1 8.8.8.8
          }
          root /mnt/Storage/org/public
          file_server browse
        '';
      };
    };
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates."caddy.env".path;
  systemd.services.caddy-api.serviceConfig.EnvironmentFile = config.sops.templates."caddy.env".path;
}
