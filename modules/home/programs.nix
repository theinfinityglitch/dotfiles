{ pkgs, ... }:
{
  programs.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
    };
  };

  programs.fish.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos, btw";
    };
  };

  programs.obs-studio = {
    enable = true;

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "theinfinityglitch";
        email = "theinfinityglitch@gmail.com";
      };
      "credential \"https://github.com\"" = {
        helper = "!gh auth git-credential";
      };
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = false;
    };
  };
}
