sudo nix run nixpkgs#nixos-rebuild -- switch \
  --flake .#chrultrabook-homelab \
  --target-host gege@192.168.15.5 \
  --sudo \
  --ask-sudo-password
