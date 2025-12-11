#!/bin/bash

OS="$(uname -s)"
case "${OS}" in
    Linux*)
        ;;
    Darwin*)
        ;;
    *)
        echo "Unsupported operating system: ${OS}"
        exit 0
        ;;
esac

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

source $HOME/.cargo/env
source ~/.profile

# Install cargo binstall
curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

# Install bob-nvim
cargo binstall bob-nvim
