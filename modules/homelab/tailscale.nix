{ config, pkgs, ... }:
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

    virtualHosts."jellyfin.gege.xyz.br".extraConfig = ''
      tls {
        dns cloudflare "**REDACTED**"
      }
      # Aponta para a porta do Jellyfin definida no seu módulo arr-stack.nix
      reverse_proxy localhost:8096
    '';
  };
}
