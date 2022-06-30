# Overview

Inspired by this [Atlassian tutorial](https://www.atlassian.com/git/tutorials/homer). Many snippets have been taken from [Greg's Wiki](https://mywiki.wooledge.org/). An interesting way of managing branches/forks using worktrees is described in [Workarounds to Git worktree using bare repository and cannot fetch remote branches](https://morgan.cugerone.com/blog/workarounds-to-git-worktree-using-bare-repository-and-cannot-fetch-remote-branches/). This repository will allow a HOME directory to be shared by multiple operating systems without interfering with one another and be tracked in Git for backup, portability, and collaboration. This is often an issue when using network area storage at work. 

The files contain expected entry points such as `~/.bash_profile`, detect the OS, and then source an OS-specific version of the file. A `homer` function is provided to allow the user's HOME directory to contain files tracked by Git while not making HOME itself a Git repository. .gitconfig makes use of wrapper scripts to run `diff` and `merge` appropriately. .bash_history is stored in the OS-specific .homer folder. A ~/bin folder is included for user scripts which can also contain a wrapper script to call an OS-specific version if needed.

# Setup

## Simple 
1. Clone the homer.git repository to the desired location
      * ~/git/homer is the default location
2. Create a personal branch
3. Combine and save your existing configuration such as ~/.bashrc into the OS-specific version in ~/git/homer/.homer
      * Edit the path to the `homer` repository if not in ~/git/homer
4. Ensure there are no files worth saving in your HOME folder that will be overwritten by replacing them with files from homer
5. `git --git-dir="${HOME}/git/homer" --work-tree="${HOME}" checkout`
6. Configure homer to not show untracked files
7. When a new terminal is opened it will load the configuration from homer

```bash
cd ~/git
git clone https://github.com/bulbousdreamer/homer
cd homer
git ls-files
# Backup personal copies of files that are listed as being tracked e.g. mv ~/.bashrc ~/.bashrc.bak
git --git-dir="${HOME}/git/homer" --work-tree="${HOME}" checkout
# Backup any conflicting files and checkout again if necessary
# Close existing windows so the new configuration an be loaded
# Reopen a terminal such as Git Bash
# Hide untracked files in home directory
homer config --local status.showUntrackedFiles no
# Add user information to local config to easily commit without having user name and email in ~/.gitconfig
```

# Usage

To run Git commands in `HOME`, use the convenient `homer` function such as `homer status`. Some git subcommands are disabled via `.gitconfig` and `homer` function in bash_functions to avoid creating problems by cleaning or resetting the HOME directory, for example. One way to use a disabled subcommand is to use the long form such as `git --git-dir="${HOME}/git/homer" --work-tree="${HOME}" <dangerous subcommand>`.

# Maintenance

To avoid breaking the configuration in HOME, it is recommended that large edits and merges are performed in ~/git/homer before using the files in HOME. It may be convenient to run configuration commands like `git config --file .gitconfig config ...`.

Ensure there is an OS value in homer/.bash_profile. Ensure the homer/.homer/<os>/bashrc sets the HISTFILE to homer/.homer/<os>/bash_history.

# Skeleton Files

Can be useful to see what settings the OS recommends.

cyg:  /etc/defaults/etc/skel
lin: /etc/skel
win: C:/Program Files/Git/etc/profile.d

# Issues

The current approach is to have normal entry point for most anything in HOME so that everything will work normally. Also the .homer/cyg etc folders are self contained. It is tedious and maybe not worth it.
