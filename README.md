# My Dotfiles

This repository stores my personal configuration files (dotfiles) for various operating systems.

## Branching Strategy

This project uses a multi-branch strategy to manage configurations for different environments. The `main` branch serves as a general entry point and guide. Each operating system has its own dedicated branch.

To set up a new machine, you should clone the branch corresponding to its operating system directly.

## Getting Started

You can directly clone the specific branch for your operating system. This is more efficient than cloning the entire repository.

#### Example for macOS:
```bash
git clone --branch macos https://github.com/joi-com/dotfiles.git ~/.dotfiles
```

After cloning, navigate to the directory and follow the instructions in the local `README.md` file to complete the setup:
```bash
cd ~/.dotfiles
# Now read the README.md for setup instructions
```

## Branch Overview

-   `main`: This general guide.
-   `macos`: Contains configurations for macOS.
-   `windows` (Planned): Will contain configurations for Windows.
-   `linux` (Planned): Will contain configurations for Linux.


> this repo inspired by [driesvints/dotfiles](https://github.com/driesvints/dotfiles/tree/main)
