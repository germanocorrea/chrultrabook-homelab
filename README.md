# Chrultrabook Homelab

This is my homelab configuration in a Chrultrabook. A Chrultrabook is a Chromebook flashed with MrChromebox's coreboot-based UEFI firmware, capable of running Linux or Windows instead of ChromeOS. For more on this, refer to the [MrChromebox](https://docs.mrchromebox.tech/) and [Chrultrabook](https://docs.chrultrabook.com/) documentation.

## Hardware

Samsung Chromebook 3 (CELES)
- CPU: Intel(R) Celeron(R) N3060 (2) @ 2.48 GHz
- RAM: 4GB
- Storage:
  - 11GB internal eMMC
  - 256GB external SSD (via USB)

## Setup

### NixOS

NixOS is the perfect distribution for homelabs like this. Its declarative nature makes it easier to keep track of changes, and reproducibility ensures consistent behavior across different hardware configurations. For example: although the vm-homelab host is deprecated, I used it first to test the entire configuration before deploying it to the actual hardware. This is perfect for a "staging" environment, and to redeploy the homelab on new hardware, if I ever get my hands on a new server (I hope so).

### Flakes

[Flakes](https://nixos.wiki/wiki/flakes) are a way to manage NixOS configurations as packages, allowing for easy reproducibility and sharing of configurations across different machines and pinning dependencies to specific versions. Personally, the best part of this is being able to deploy everything from outside the server, without needing to SSH into it, except when debugging.

### Tailscale, Caddy and Cloudflare DNS

For a "VPN-like" experience, I use [Tailscale](https://tailscale.com/), which connects my devices to each other and allows me to access the homelab everywhere I go, while also ensuring that I can stream videos without arbitrary limits. [Caddy](https://caddyserver.com/) runs as a reverse proxy in front of all services. [Cloudflare](https://www.cloudflare.com/) DNS provides my custom domain for the homelab, making the services easier to remember and access, although all of them are private. Caddy gets TLS certificates through the Cloudflare DNS challenge, so every service has HTTPS without any additional configuration.

### USB Challenges

Because CELES has no Ethernet port or SATA connection, both networking and external storage go through USB adapters. Initial configurations were very unstable because of this, so specific kernel flags and udev rules were needed: USB autosuspend is disabled (`usbcore.autosuspend=-1`), and a udev rule keeps the USB Ethernet adapter powered on.

### SOPS secrets management

To manage secrets (tokens such as Cloudflare's), I use [SOPS](https://github.com/getsops/sops) through [sops-nix](https://github.com/Mic92/sops-nix), which encrypts secrets using [age](https://github.com/FiloSottile/age) and stores them in Git. This ensures that secrets are stored encrypted in the same repository as the homelab definition, can be edited in my personal machine and used in the server, and I can still share this configuration here :)

### Default Services Storage

Since CELES has very limited storage capacity, I require using external storage for basically everything. The only data that still lives on the eMMC is the NixOS configuration itself and everything in `/nix/store`. This means I need to be really careful when doing a full update and making sure old files are properly cleaned up.

Besides this, each host defines a default "storage" directory in `config.services.homelab.storage`, and each service uses it as needed. For example, all bind mounts happen inside this directory, podman graphroot is set to a directory inside it, and so on. The actual server mounts an external SSD at `/mnt/Storage` and sets this option to it, but vm-homelab defines it inside the home folder.
