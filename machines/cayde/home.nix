# home.nix — Home Manager config for user "skuroda".
{ config, pkgs, inputs, ... }:

{
  imports = [
    # Per-user Catppuccin — themes the programs HM manages below.
    inputs.catppuccin.homeModules.catppuccin
  ];

  home.username = "skuroda";
  home.homeDirectory = "/home/skuroda";

  # HM's own release version — independent of system.stateVersion.
  home.stateVersion = "25.11";

  ##########################################################################
  # Theming
  ##########################################################################
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

  ##########################################################################
  # Shell: zsh + oh-my-zsh
  ##########################################################################
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
    };

    shellAliases = {
      ll = "ls -alh";
      ".." = "cd ..";
      # Rebuild from your dotfiles repo:
      rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles#cayde";
      gs = "git status";
    };

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";     # powerline look — needs a Nerd Font
      plugins = [
        "git"
        "sudo"
        "docker"
        "python"
        "colored-man-pages"
      ];
    };

    ########################################################################
    # conda / miniforge
    #
    # This replaces `conda init zsh`, which cannot work here: Home Manager
    # owns ~/.zshrc as a read-only symlink into the Nix store, so conda
    # can't edit it (that's the "needs sudo /home/skuroda/.zshrc" error).
    # Doing it here means it also survives every rebuild.
    #
    # NOTE: if HM warns that `initExtra` is deprecated, rename it to
    # `initContent`.
    ########################################################################
    initContent = ''
      # >>> conda initialize >>>
      if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniforge3/etc/profile.d/conda.sh"
      fi
      if [ -f "$HOME/miniforge3/etc/profile.d/mamba.sh" ]; then
        . "$HOME/miniforge3/etc/profile.d/mamba.sh"
      fi
      # <<< conda initialize <<<
    '';
  };

  ##########################################################################
  # Terminal: WezTerm
  ##########################################################################
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        font = wezterm.font("JetBrainsMono Nerd Font"),
        font_size = 11.0,
        hide_tab_bar_if_only_one_tab = true,
        window_close_confirmation = "NeverPrompt",
        -- Uncomment if you see rendering glitches on the NVIDIA driver:
        -- front_end = "WebGpu",
      }
    '';
  };

  ##########################################################################
  # Other programs (each one HM manages also gets Catppuccin-themed)
  ##########################################################################
  programs.git = {
    enable = true;
    # userName = "Sumiya Kuroda";
    # userEmail = "s.kuroda@ucl.ac.uk";
  };

  programs.bat.enable = true;    # cat with syntax highlighting
  programs.fzf.enable = true;    # fuzzy finder (Ctrl+R history search)

  # User-scoped packages, if you prefer them over systemPackages:
  # home.packages = with pkgs; [ ripgrep fd ];
}
