sudo nix --extra-experimental-features 'nix-command flakes' run nixpkgs#nixos-rebuild -- switch \
    --flake .#chrultrabook-homelab \
    --target-host gege@ssh.gege.xyz.br \
    --sudo \
    --ask-sudo-password
