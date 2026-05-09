{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    # inputs.sops-nix.nixosModules.sops
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    # "ipv6.disable=1"
    "usbcore.autosuspend=-1"
  ];
  boot.blacklistedKernelModules = [ "tpm" "tpm_tis" "tpm_tis_core" "tpm_crb" ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="00e0", ATTR{idProduct}=="8153", ATTR{power/control}="on"
  '';

  networking.hostName = "chrultrabook-homelab";
  # networking.enableIPv6 = false;
  networking.networkmanager.enable = true;
  networking.networkmanager.settings = {
    connection = {
      "wifi.powersave" = 2;
      "ethernet.wake-on-lan" = "ignore";
    };
  };

  # networking.networkmanager.wifi.enable = false;
  networking.networkmanager.unmanaged = [
    "interface-name:wlp2s0"
    "interface-name:p2p-dev-wlp2s0"
  ];

  systemd.services.wpa_supplicant.enable = false;

  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Configure console keymap
  # console.keyMap = "br-abnt2";
  console.keyMap = "us";

  users.users.gege = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/gege";
    description = "gege";
    extraGroups = [
      "wheel"
      "gege"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    btop
    fastfetch
  ];
  services.openssh.enable = true;

  system.stateVersion = "25.11";
  nix.settings.trusted-users = [
    "root"
    "gege"
  ];

  fileSystems."/mnt/Storage" = {
    device = "/dev/disk/by-uuid/df91cac8-2369-4a2e-a1a4-f06b82dc8db2";
    fsType = " ext4";
    options = [
      "defaults"
      "relatime"
    ];
  };
  services.homelab = {
    storage = "/mnt/Storage";
  };
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # This will add secrets.yml to the nix store
    # You can avoid this by adding a string to the full path instead, i.e.
    # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
    sops.defaultSopsFile = ./../../secrets/tokens.yaml;
    sops.defaultSopsFormat = "yaml";
    # This will automatically import SSH keys as age keys
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    # This is using an age key that is expected to already be in the filesystem
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    # This will generate a new key if the key specified above does not exist
    sops.age.generateKey = true;
    # This is the actual specification of the secrets.
    sops.secrets.example-key = {};
    sops.secrets."homelab/tokens/cloudflare" = {};
    sops.secrets."homelab/tokens/ngrok" = {};
    sops.secrets."homelab/tokens/telegram" = {};
}
