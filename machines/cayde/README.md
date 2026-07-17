# ❄️ cayde — NixOS Configuration

A flake-based NixOS configuration for host **`cayde`** (user **`skuroda`**).
Originally installed at NixOS 23.05, repaired and rebuilt on the **25.11** channel,
with a full Wayland desktop stack, CUDA/ML tooling, and remote-access setup.

> Built around this machine's real `hardware-configuration.nix` (2× GTX 1080,
> ext4 root, SWC ceph/winstor CIFS mounts). Keep that file — everything else
> is designed to sit alongside it.

---

## 🧩 Components

| Category | Choice |
| --- | --- |
| OS | NixOS 25.11 (flake-based) |
| Window Manager | Niri (Wayland, scrollable-tiling) |
| Fallback Desktop | XFCE (X11) |
| Display Manager | greetd + tuigreet |
| Desktop Shell (bar / launcher / notifications) | noctalia-shell |
| Color Scheme | catppuccin-nix (Mocha) |
| Network Management | NetworkManager |
| Terminal Emulator | Warp |
| File Manager | Yazi |
| Media Player | mpv |
| Image Viewer | imv |
| Fonts | Nerd Fonts (JetBrains Mono, Fira Code, Symbols) |
| Editors / IDE | VS Code (+ extensions), Vim |
| Remote Editing | VS Code Remote-SSH (nixos-vscode-server) |
| Remote Desktop | RustDesk, x2go |
| Remote Shell | OpenSSH |
| Containers | Docker + NVIDIA Container Toolkit |
| GPU | 2× GTX 1080 (Pascal) — nvidia `legacy_580` driver |
| CUDA | cudaPackages (cudatoolkit + cuDNN) |
| Python | python3 + uv + conda (+ nix-ld) |
| Comms | Slack |
| Browsers | Google Chrome, Firefox |
| Audio | PipeWire |
| Printing | CUPS |
| Dotfile Management | Home Manager |
| Boot | GRUB (BIOS, /dev/sda) |

---

## 📦 Flake Inputs (dependencies)

| Input | Source | Purpose |
| --- | --- | --- |
| `nixpkgs` | `github:NixOS/nixpkgs/nixos-25.11` | Base package set |
| `home-manager` | `github:nix-community/home-manager/release-25.11` | Per-user config |
| `vscode-server` | `github:nix-community/nixos-vscode-server` | VS Code Remote-SSH support |
| `catppuccin` | `github:catppuccin/nix` | Theming |
| `noctalia` | `github:noctalia-dev/noctalia-shell` | Wayland desktop shell |

> `noctalia` keeps its own (unstable) nixpkgs for Quickshell — it is intentionally
> **not** pinned to follow the system nixpkgs. Cost: a larger first download.

---

## 🗂️ File Layout

```
/etc/nixos/
├── flake.nix                  # inputs + the `cayde` system definition
├── configuration.nix          # main system config
├── hardware-configuration.nix # YOURS — do not replace
├── nvidia.nix                 # 2× GTX 1080, legacy_580 driver
├── docker.nix                 # Docker + NVIDIA container toolkit
├── desktop-extras.nix         # fonts, Niri, tuigreet, noctalia, imv/yazi/mpv, catppuccin
├── home.nix                   # Home Manager config (user skuroda)
└── .gitignore                 # keeps smb-secrets / keys out of git
```

---

## 🚀 Installation

### 1. Back up your current config
```bash
sudo cp -a /etc/nixos /etc/nixos.bak
```

### 2. Copy the files in
Copy everything **except** `hardware-configuration.nix` into your config dir
(usually `/etc/nixos/`). Keep your existing hardware file — it holds your disk
UUIDs and the ceph/winstor mounts.
```bash
sudo cp flake.nix configuration.nix nvidia.nix docker.nix \
        desktop-extras.nix home.nix .gitignore /etc/nixos/
```

### 3. Track the files in git ⚠️ required
Flakes only see **git-tracked** files. New files are invisible until added,
even inside an existing repo.
```bash
cd /etc/nixos
git init          # skip if already a repo
git add .         # <-- the step everyone forgets
```
> `git add` (staging) is enough — you do **not** need to commit or push for the
> build to work. If your config lives somewhere other than `/etc/nixos`
> (e.g. `~/nix-config`), put the files there and adjust the `--flake` path below.

### 4. Build
```bash
sudo nixos-rebuild switch --flake /etc/nixos#cayde \
  --option experimental-features 'nix-command flakes'
```
The `--option` flag is only needed for this **first** build; flakes stay enabled
afterward. Later rebuilds are just:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#cayde
```

### 5. Enable the per-user VS Code server service (once)
Not declarative — run once, logged in as `skuroda`:
```bash
systemctl --user enable --now auto-fix-vscode-server.service
```

---

## 🛟 Recommended: build in two passes

The riskiest piece is greetd/tuigreet launching the **X11 XFCE** session
(Wayland/Niri is fine). To de-risk the first build:

1. In `configuration.nix`, temporarily add:
   ```nix
   services.xserver.displayManager.lightdm.enable = true;
   ```
2. In `desktop-extras.nix`, comment out the whole `services.greetd = { ... };` block.
3. Build, confirm you can log in + SSH, **then** switch to tuigreet.

You can't brick the machine: every switch creates a new generation, and the old
one stays in the GRUB boot menu. To undo a bad switch:
```bash
sudo nixos-rebuild switch --rollback
```

---

## ✅ Post-install / verify

- **Niri first run is bare** (no terminal/launcher bound). `Super+Shift+E` exits.
  Configure it (ideally via Home Manager) before relying on it.
- **noctalia** — launch from Niri: add `spawn-at-startup "noctalia-shell"` to
  `~/.config/niri/config.kdl`.
- **conda** — enter its FHS shell first: `conda-shell`, then `conda-install` (once).
- **uv** — works out of the box (nix-ld handles downloaded Pythons).
- **Docker + GPU** — `docker run --gpus all ...`; if that fails on 25.11 use the
  CDI form `docker run --device nvidia.com/gpu=all ...`.

---

## 🔧 Maintenance

```bash
# Update all flake inputs and re-lock, then rebuild
nix flake update /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#cayde

# Update a single input
nix flake update nixpkgs --flake /etc/nixos

# Free old generations
sudo nix-collect-garbage -d
```

---

## 📝 Notes

- `system.stateVersion = "23.05"` is intentionally left unchanged (it reflects the
  first install and governs stateful defaults — not the nixpkgs version).
- To pin **CUDA 12.6** specifically, replace `cudaPackages` with `cudaPackages_12_6`
  in `configuration.nix`, or add an overlay:
  ```nix
  nixpkgs.overlays = [ (final: prev: { cudaPackages = final.cudaPackages_12_6; }) ];
  ```
- Home Manager owns the dotfiles it manages — let it write them rather than editing
  by hand, or it will refuse to overwrite.

## 🙏 Reference

Stack inspired by [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
(Niri + noctalia-shell + tuigreet + catppuccin).