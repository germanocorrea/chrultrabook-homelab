sudo nix run nixpkgs#nixos-rebuild -- switch \
    --flake .#chrultrabook-homelab \
    --target-host gege@ssh.gege.xyz.br \
    --sudo \
    --ask-sudo-password
