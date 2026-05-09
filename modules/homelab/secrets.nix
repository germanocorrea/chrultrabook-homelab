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
      "homelab/passwords/brokerbot_password" = { };
      "homelab/passwords/brokerbot_webhook_secret" = { };
    };

    templates."brokerbot.env" = {
      content = ''
        NGROK_AUTHTOKEN=${config.sops.placeholder."homelab/tokens/ngrok"}
        TOKEN=${config.sops.placeholder."homelab/tokens/telegram"}
        BROKERBOT_PASSWORD=${config.sops.placeholder."homelab/passwords/brokerbot_password"}
        BROKERBOT_WEBHOOK_SECRET=${config.sops.placeholder."homelab/passwords/brokerbot_webhook_secret"}
      '';
    };

    templates."caddy.env" = {
      content = ''
        CLOUDFLARE_API_TOKEN=${config.sops.placeholder."homelab/tokens/cloudflare"}
      '';
    };
  };
}
