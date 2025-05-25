#!/bin/bash

# Oh My Zsh Installation Script
echo "🚀 Setting up Oh My Zsh..."

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "📦 Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "✅ Oh My Zsh already installed"
fi

# Install zsh plugins
echo "🔌 Installing Zsh plugins..."

# zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
  echo "📦 Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
else
  echo "✅ zsh-autosuggestions already installed"
fi

# zsh-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
  echo "📦 Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
else
  echo "✅ zsh-syntax-highlighting already installed"
fi

echo "🎉 Oh My Zsh setup complete!"
echo "💡 Don't forget to run 'stow zsh' from your dotfiles directory to link the configuration files."
echo "🔄 Then restart your terminal or run 'source ~/.zshrc' to apply changes."
