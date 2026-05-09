{ config, ... }:
{
  sops = {
    defaultSopsFile = ./../../secrets/tokens.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.generateKey = true;

    secrets = {
      "homelab/tokens/cloudflare" = { };
      "homelab/tokens/ngrok" = { };
      "homelab/tokens/telegram" = { };
    };

    templates."brokerbot.env" = {
      content = ''
        NGROK_AUTHTOKEN=${config.sops.placeholder."homelab/tokens/ngrok"}
        TELEGRAM_TOKEN=${config.sops.placeholder."homelab/tokens/telegram"}
      '';
    };

    templates."caddy.env" = {
      content = ''
        CLOUDFLARE_TOKEN=${config.sops.placeholder."homelab/tokens/cloudflare"}
      '';
    };
  };
}
