return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "biome" },
        typescript = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
        go = { "gofmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
      },
    },
  },
}
