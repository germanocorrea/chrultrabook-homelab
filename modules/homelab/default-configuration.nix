{ lib, ... }:
{
  services.cockpit = {
    enable = true;
    settings = {
      WebService = {
        Origins = lib.mkForce "https://cockpit.gege.xyz.br http://localhost:9090";
        ProtocolHeader = "X-Forwarded-Proto";
      };
    };
  };
  imports = [
    ./arr-stack.nix
    ./volume-seeder.nix
    ./tailscale.nix
    ./health.nix
    {
      services.homelab.migration.enableRestore =
        if (builtins.getEnv "MIGRATE") == "1" then true else false;

      services.homelab.migration.forceOverwrite =
        if (builtins.getEnv "FORCE_RESTORE") == "1" then true else false;
    }
  ];
}
