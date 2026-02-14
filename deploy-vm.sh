sudo nix run nixpkgs#nixos-rebuild -- switch \
  --flake .#vm-homelab \
  --target-host gege@192.168.122.112 \
  --sudo \
  --ask-sudo-password
