{
  services.cockpit.enable = true;
  imports = [
    ./arr-stack.nix
    ./volume-seeder.nix
    ./tailscale.nix
    {
      services.homelab.migration.enableRestore =
        if (builtins.getEnv "MIGRATE") == "1" then true else false;

      services.homelab.migration.forceOverwrite =
        if (builtins.getEnv "FORCE_RESTORE") == "1" then true else false;
    }
  ];
}
