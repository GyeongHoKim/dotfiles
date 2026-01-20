-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local shell
if vim.fn.has("win32") == 1 then
  shell = "pwsh"
elseif vim.fn.has("unix") == 1 then
  shell = "zsh"
end

if shell and vim.fn.executable(shell) == 1 then
  vim.o.shell = shell
end
