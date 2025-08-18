# Zsh Prompt Setup

This script automates the setup of a feature-rich Zsh environment on fresh Debian-based (Ubuntu) or DNF-based (Fedora, CentOS) systems. It installs Zsh, Oh My Zsh, essential plugins, and the Spaceship prompt.

## Features

-   Installs necessary packages (`zsh`, `vim`, `git`, `curl`, `fzf`).
-   Installs [Oh My Zsh](https://ohmyz.sh/).
-   Installs Zsh plugins:
    -   [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
    -   [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
-   Installs the [Spaceship Prompt](https://spaceship-prompt.sh/).
-   Configures `fzf` for better fuzzy finding.
-   Sets Zsh as the default shell for the current user.
-   Creates a minimal `.vimrc` with line numbers enabled.
-   The setup is idempotent and can be run multiple times without issues.

## Supported Systems

-   Debian / Ubuntu (uses `apt-get`)
-   Fedora / CentOS (uses `dnf`)

## Prerequisites

You must run this script as a non-root user that has `sudo` privileges. The script will prompt for your password once at the beginning to cache `sudo` credentials.

## Usage

You can download and run the script with a single command:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/your-username/your-repo/main/zsh-prompt.sh)"
```

*Remember to replace `your-username/your-repo` with the actual path to your repository once you've uploaded it.*

## What the Script Does

1.  **Package Installation**: Detects the package manager (`apt-get` or `dnf`) and installs `zsh`, `vim`, `git`, `curl`, and `fzf`.
2.  **Oh My Zsh**: Installs Oh My Zsh without changing the default shell automatically or launching Zsh immediately. It preserves any existing `.zshrc`.
3.  **Set Default Shell**: Changes the current user's default shell to Zsh.
4.  **Plugin Installation**: Clones `zsh-autosuggestions` and `zsh-syntax-highlighting` into the Oh My Zsh custom plugins directory.
5.  **Spaceship Prompt**: Clones the Spaceship prompt repository.
6.  **FZF Installation**: Clones the `fzf` repository and runs its installer.
7.  **`.zshrc` Configuration**:
    -   Sets the `plugins` order to `(git zsh-autosuggestions zsh-syntax-highlighting)`.
    -   Sources Oh My Zsh, Spaceship prompt, and fzf configurations.
    -   Configures the Spaceship prompt order and settings.
8.  **Vim Configuration**: Creates a simple `.vimrc` to enable line numbers.
9.  **Launch Zsh**: The script finishes by launching a new Zsh session (`exec zsh -l`).

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
# zsh-prompt
