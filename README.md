# Chrultrabook Homelab

This is my homelab configuration in a Chrultrabook. A Chrultrabook is a flashed Chromebook with [LibreBoot](https://libreboot.org/), capable of running Linux or Windows instead of Chrome OS. For more on this, refer to [MrChromebox](https://docs.mrchromebox.tech/) and [Chrultrabook](https://docs.chrultrabook.com/) documentations.

## Hardware

Samsung Chromebook 3 (CELES)
- CPU: Intel(R) Celeron(R) N3060 (2) @ 2.48 GHz
- RAM: 4GB
- Storage:
  - 11GB internal eMMC
  - 256GB external SSD (via USB)

## Setup

### NixOS

NixOS is the perfect distribution for homelabs like this. Its declarative nature makes it easier to keep track of changes, and reproducibility ensures consistent behavior across different hardware configurations. For example: although the vm-homelab host is deprecated, I used it first to test the entire configuration before deploying it to the actual hardware. This is perfect for a "staging" environment, and to redeploy the homelab on new hardware, if I ever get my hands in a new server (I hope so).

### Flakes

[Flakes](https://nixos.wiki/wiki/flakes) are a way to manage NixOS configurations as packages, allowing for easy reproducibility and sharing of configurations across different machines and pinning dependencies to specific versions. Personally, the best part of this is being able to deploy everything from outside the server, without needing to SSH into it, except when debugging.

### Tailscale and Cloudlfare domain

To a "VPN-like" experience, I use [Tailscale](https://tailscale.com/), which connects my devices between each other and allow me to access the homelab everywhere I go, while also ensuring that I can stream videos without arbitrary limits. [Cloudflare](https://www.cloudflare.com/) DNS is used to provide my custom domain for the homelab, making it easier to remember domains and access them, although all of them are private. This also makes HTTPS available for all services, without any additional configuration.

### SOPS secrets management

To manage secrets (tokens such as cloudflare), I use [SOPS](https://github.com/getsops/sops) through [sops-nix](https://github.com/Mic92/sops-nix), which encrypts secrets using [age](https://github.com/FiloSottile/age) and stores them in Git. This ensures that secrets are stored encrypted in the same repository as the homelab definition, can be edited in my personal machine and used in the server, and I still can share this configuration here :)

### External Storage

Since CELES has very limited storage capacity, I require using external storage for basically everything. The only thing that varies in storage still inside the eMMC is the NixOS configuration itself and everything in /nix/store. This means I need to be really careful when doing a full update and making sure old files are properly cleaned up.

Besides this, I expose to each host its default "storage" directory to each service use as needed in `config.services.homelab.storage`. For example, all bind mounts happen inside this directory, podman graphroot is set to a directory inside it, and so on. The actual server mounts an external SSD to /mnt/Storage and set this option as it, but vm-homelab defines it inside the the home folder.

## Services

Right now, this homelab is just a media lab. It is running:
- Jellyfin media server
- Jellyseer
- qBittorrent
- arr* stack
  - Radarr
  - Sonarr
  - Bazarr
  - Prowlarr
  - Flaresolverr

Currently disabled services:
- [brokerbot](https://github.com/germanocorrea/brokerbot): a telegram bot that sends messages through UNIX sockets
- [archiveteam-warrior](https://github.com/ArchiveTeam/warrior-dockerfile)
- [wallabag](https://github.com/wallabag/wallabag)
- some generic health services (network connectivity, power, disk usage, etc)
