{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    
    userName = "Devin Ferguson";  # Change this
    userEmail = "devin@example.com";  # Change this
    
    aliases = {
      # List all aliases
      la = "!git config -l | grep alias | cut -c 7-";
      
      # Branch management
      delete-merged-branches = "!f() { git checkout --quiet master && git branch --merged | grep --invert-match '\\*' | xargs -n 1 git branch --delete; git checkout --quiet @{-1}; }; f";
      
      # Diff commands
      d = "!git diff --ignore-space-at-eol -b -w --ignore-blank-lines -- ':!**/package-lock.json' ':!**/yarn.lock'";
      
      # Push commands
      pnb = "!git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)";
      fp = "push --force-with-lease";
      
      # Common shortcuts
      co = "checkout";
      s = "status --short --branch";
      br = "branch -v";
      addnw = "!sh -c 'git diff -U0 -w --no-color \"$@\" | git apply --cached --ignore-whitespace --unidiff-zero -'";
      cane = "commit --amend --no-edit";
      seperator = "commit --allow-empty -m \"--------SEPERATOR--------\"";
      
      # GitHub integration
      browse = "!gh repo view --web";
      
      # Rebase commands
      cont = "rebase --continue";
      continue = "!GIT_EDITOR=true git rebase --continue";
      conf = "!git s | grep ^U";
      
      # Log commands
      l = "log --graph --pretty=format:'%Cred%h%Creset %C(bold blue)%an%C(reset) - %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";
      day = "!sh -c 'git log --reverse --no-merges --branches=* --date=local --after=\"yesterday 11:59PM\" --author=\"`git config --get user.name`\"'";
      review = "!git log --no-merges --pretty=%an | head -n 100 | sort | uniq -c | sort -nr";
      churn = "!f() { git log --all -M -C --name-only --format='format:' \"$@\" | sort | grep -v '^$' | uniq -c | sort | awk 'BEGIN {print \"count\tfile\"} {print $1 \"\t\" $2}' | sort -g; }; f";
      deleted = "!git log --diff-filter=D --summary | grep delete";
      
      # Commit helpers
      empty = "commit --allow-empty";
      undo = "reset --soft HEAD~1";
      amend = "commit -a --amend";
      
      # Branch info
      cbr = "rev-parse --abbrev-ref HEAD";
      upstream = "rev-parse --abbrev-ref --symbolic-full-name @{u}";
      
      # Submodules
      si = "submodule init";
      su = "submodule update";
      sub = "!git submodule sync && git submodule update";
      
      # Statistics
      count = "shortlog -sn";
      
      # Cleanup
      cleanup = "!git remote prune origin && git gc && git clean -df && git stash clear";
      forget = "!git fetch -p origin && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D";
      
      # Update from upstream
      update = "!git fetch upstream && git rebase upstream/`git rev-parse --abbrev-ref HEAD`";
      
      # Tags
      lt = "describe --tags --abbrev=0";
      
      # Assume unchanged
      assume = "update-index --assume-unchanged";
      unassume = "update-index --no-assume-unchanged";
      assumed = "!git ls-files -v | grep ^h | cut -c 3-";
      unassumeall = "!git assumed | xargs git update-index --no-assume-unchanged";
      
      # Latest branches
      latest = "!git for-each-ref --sort='-committerdate' --format='%(color:red)%(refname)%(color:reset)%09%(committerdate)' refs/remotes | sed -e 's-refs/remotes/origin/--' | less -XFR";
      
      # Grep commands
      dg = "!sh -c 'git ls-files -m | grep $1 | xargs git diff' -";
      dgc = "!sh -c 'git ls-files | grep $1 | xargs git diff $2 $3 -- ' -";
      cg = "!sh -c 'git ls-files -m | grep $1 | xargs git checkout ' -";
      ag = "!sh -c 'git ls-files -m -o --exclude-standard | grep $1 | xargs git add --all' -";
      aa = "!git ls-files -d | xargs git rm && git ls-files -m -o --exclude-standard | xargs git add";
      rg = "!sh -c 'git ls-files --others --exclude-standard | grep $1 | xargs rm' -";
      
      remotes = "remote -v";
    };

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      
      include = {
        # Local gitconfig outside version control
        path = "~/.gitconfig-local";
      };
      
      color = {
        diff = "auto";
        status = "auto";
        branch = "auto";
        interactive = "auto";
        ui = "auto";
      };
      
      "color \"branch\"" = {
        current = "green bold";
        local = "green";
        remote = "red bold";
      };
      
      "color \"diff\"" = {
        meta = "yellow bold";
        frag = "magenta bold";
        old = "red bold";
        new = "green bold";
      };
      
      "color \"status\"" = {
        added = "green bold";
        changed = "yellow bold";
        untracked = "red";
      };
      
      "color \"sh\"" = {
        branch = "yellow";
      };
      
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      
      branch = {
        autosetuprebase = "always";
      };
      
      pull = {
        rebase = true;
      };
      
      diff = {
        renames = "copies";
        mnemonicprefix = true;
        compactionHeuristic = true;
      };
      
      difftool = {
        prompt = false;
      };
      
      apply = {
        whitespace = "nowarn";
      };
      
      core = {
        pager = "delta";
        editor = "nvim";
        whitespace = "cr-at-eol";
      };
      
      delta = {
        features = "unobtrusive-line-numbers decorations";
        whitespace-error-style = "22 reverse";
        syntax-theme = "base16-256";
      };
      
      "delta \"unobtrusive-line-numbers\"" = {
        line-numbers = true;
        line-numbers-left-format = "{nm:>4}┊";
        line-numbers-right-format = "{np:>4}│";
        line-numbers-left-style = "blue";
        line-numbers-right-style = "blue";
      };
      
      "delta \"decorations\"" = {
        commit-decoration-style = "bold yellow box ul";
        file-style = "bold yellow ul";
        file-decoration-style = "none";
        hunk-header-decoration-style = "yellow box";
      };
      
      interactive = {
        diffFilter = "delta --color-only";
      };
      
      rerere = {
        enabled = true;
      };
      
      grep = {
        extendRegexp = true;
        lineNumber = true;
      };
      
      credential = {
        helper = if pkgs.stdenv.isDarwin then "osxkeychain" else "cache";
      };
      
      rebase = {
        instructionFormat = "[%an - %ar] %s";
        autoStash = true;
      };
    };
    
    ignores = [
      # macOS
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "._*"
      
      # Linux
      "*~"
      ".directory"
      
      # Editors
      ".vscode"
      ".idea"
      "*.swp"
      "*.swo"
      "*~"
      ".*.sw?"
      
      # Node
      "node_modules"
      "npm-debug.log"
      
      # Python
      "__pycache__"
      "*.pyc"
      
      # General
      ".envrc"
      ".direnv"
    ];
  };

  # Git Delta for better diffs
  programs.git.delta = {
    enable = true;
  };

  # Lazygit configuration
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          activeBorderColor = [ "green" "bold" ];
          inactiveBorderColor = [ "white" ];
          selectedLineBgColor = [ "blue" ];
        };
      };
    };
  };
}
