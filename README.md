# Bottom line up front / Too Long; Didn't Read

Use Git Bash, Cygwin, Linux, etc in the same HOME directory without interfering with one another. Also provides some Git wrappers for Git Bash and Cygwin diff and merge using Beyond Compare 4. This works by detecting the OS in a generic ~/.bash_profile and using a specific configuration in `HOME/.homer/${HOMER_OS_TYPE}/bash_profile` etc. Important things to configure are the path to Homer's git repository, Git tools, and a path to an individual Bash history file. More files and folders relative to `HOME` such as `HOME/bin` can also be used.

# Overview

It is inspired by this [Atlassian tutorial](https://www.atlassian.com/git/tutorials/homer). Many snippets have been taken from [Greg's Wiki](https://mywiki.wooledge.org/) in an effort to make the code robust and not break on whitespace. An interesting way of managing branches/forks using worktrees and easily created with a wrapper script that is included is described in [Workarounds to Git worktree using bare repository and cannot fetch remote branches](https://morgan.cugerone.com/blog/workarounds-to-git-worktree-using-bare-repository-and-cannot-fetch-remote-branches/).

# Setup

1. Clone the homer.git repository to the desired location
2. Create a personal branch, check it out, add, and commit at any point during setup
3. Add user name and email to .gitconfig
   1. Hint: Run commands like `cd ~/git/homer; git config --file .gitconfig user.name "Bulbous Dreamer"` to modify a specific file
4. Optional: Configure homer to not show untracked files so `homer status` does not list everything: `cd ~/git/homer; git config --file .gitconfig status.showUntrackedFiles no`
5. Edit the `HOMER_GIT_DIR` variable in `.bash_profile` to the path to your repository
6. Optionally move the `README.md` file to `homer/.homer` to reduce clutter in HOME (it is only in the top level so Github displays it)
7. Ensure there is a `homer/.homer/${HOMER_OS_TYPE}` folder for your OS
   * Run `uname -o` and see if the output is in `homer/.bash_profile` case statement
   * If there is not, add it, and copy and paste the `homer/.homer/template` folder to `homer/.homer/${HOMER_OS_TYPE}`
8. Put the desired settings you want to save from your current `HOME` directory into the appropriate `homer/.homer/${HOMER_OS_TYPE}` files
   * e.g. aliases from `HOME/.bash_aliases`
   * Hint: View the files that will be checked out to HOME by running `git ls-tree --name-only <your branch>`
9. Move the existing files to a backup location so the Homer versions can be checked out instead
10. Place the Homer files in `HOME `(modify the `--git-dir` path as needed)
   * `git --git-dir="${HOME}/git/homer" --work-tree="${HOME}" checkout`
11. When a new terminal is opened it will load the configuration from Homer
12. Use commands like `homer checkout` to run Git commands on the Homer files in HOME

# Pseudoscript

```bash
cd ~/git
git clone https://github.com/bulbousdreamer/homer
cd homer
# Optional: Hide untracked files in home directory
git config --local status.showUntrackedFiles no
# Add user information to local config to easily commit without having user name and email in ~/.gitconfig
git config --local user.name "..."
git config --local user.email "..."
git branch <your branch>
git checkout <your branch>
git ls-tree --name-only <your branch>
# Merge personal copies of files that are listed as being tracked
# then move them to a new location to deconflict
# git add, commit the modified files
# Check out the Homer files to HOME (modify the --git-dir path as needed)
# This may have an error that
git --git-dir="${HOME}/git/homer" --work-tree="${HOME}" checkout <your branch>
# Backup any conflicting files and checkout again if necessary
# Close existing windows so the new configuration can be loaded
# Reopen a terminal such as Git Bash
```

# Usage

To run Git commands in `HOME`, use the convenient `homer` script such as `homer checkout`. Some git subcommands are disabled via `.gitconfig` and `homer` script in `bin` to avoid creating problems by cleaning or resetting the `HOME` directory, for example. They are only detected if they are the first positional argument to `homer` script. One way to use a disabled subcommand is to use the long form such as `git --git-dir="${HOMER_GIT_DIR}" --work-tree="${HOME}" <dangerous subcommand>`.

# Maintenance

To avoid breaking the configuration in `HOME`, it is recommended that modifications are made in a regular repository such as `HOME/git/homer` then checked out to `HOME` once stable. To maintain basic functionality, ensure the OS can be detected by `homer/.bash_profile` and there are OS-specific `git-eidtor`, `git-ext-diff`, `git-ext-merge` to use Git normally.

# Skeleton Files

Can be useful to see what settings the OS recommends. Not sure if these are correct in all situations.

cyg: /etc/defaults/etc/skel
lin: /etc/skel
win: /etc/profile.d

# Issues

* README.md is in the top level, cluttering `HOME`
* Git Bash transforms anything beginning with `/` into a path so cannot pass Windows style command line options that need that character such as `subst /d D:` or `/solo` into Beyond Compare 4