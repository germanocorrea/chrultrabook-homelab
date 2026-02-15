{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "chrultrabook-homelab";

  networking.networkmanager.enable = true;

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
    # brokerbotSocket = "/run/user/1000/brokerbot";
  };

}
