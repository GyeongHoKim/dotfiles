# dotfiles

This repository contains my personal dotfiles. Use GNU Stow to install them:

```bash
stow */
```

## Known Issues

### ESLint LSP Server

> <https://github.com/LazyVim/LazyVim/issues/3383>

There is known issues with v4.10 ESLint LSP server that cannot read flat config files.  
If you use flat eslint config in your project, you should downgrade to v4.5 with MasonInstaller

```bash
:MsonInstall eslint-lsp 4.5.0
```
