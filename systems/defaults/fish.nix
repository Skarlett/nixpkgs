{ ... }:
{
  programs.fish =
  {
    enable = true;
    vendor.functions.enable = true;
    vendor.config.enable = true;
    vendor.completions.enable = true;
    shellInit = ''
        # Spawns process outside of shell access
        function spawn
          $argv > /dev/null 2>&1 &
          disown
        end
    '';

    shellAliases =
    {
        ls="lsd --color always";
        l="ls -la";
        la="ls -a";
        lt="ls -tree";
        gr="git reset --soft HEAD~1";
        glog="git log --grph \
                 --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' \
                 --abbrev-commit \
                 --date=relative";
        gd="git diff --color | sed 's/^\([^-+ ]*\)[-+ ]/\\1/' | less -r";
        clr="clear";
        cls="clear";
        cp="cp -r";
        tmux = "tmux -u";
        more = "less";
        ".." = "cd ..";
        "..." = "cd ../..";
        dmesg="dmesg --color=always";
 	# vol = "pactl -- set-sink-volume 0";
        # clipboard="xclip -selection c";
        # cat = "bat";
    };
  };
}
