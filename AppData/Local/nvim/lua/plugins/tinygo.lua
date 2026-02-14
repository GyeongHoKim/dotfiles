-- TinyGo support for LazyVim
-- See: https://tinygo.org/docs/guides/ide-integration/vim-neovim
-- Plugin: https://github.com/pcolladosoto/tinygo.nvim
--
-- Commands:
--   :TinyGoSetTarget <target>  - Set TinyGo target (TAB for completion, use "original" to reset)
--   :TinyGoTargets             - List available TinyGo targets
--   :TinyGoEnv                 - Show current target, GOROOT, GOFLAGS
--
-- Optional: add .tinygo.json in project root with {"target": "pico"} for auto target.
return {
  "pcolladosoto/tinygo.nvim",
  ft = "go",
  opts = {
    -- config_file: path to config; default uses .tinygo.json in cwd if present
    -- config_file = ".tinygo.json",
  },
}
