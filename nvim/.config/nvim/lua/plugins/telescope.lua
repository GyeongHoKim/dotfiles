return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    -- 파일 검색
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },

    -- Git 관련
    { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
    { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
    { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git Branches" },

    -- LSP 관련
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
    { "<leader>fw", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace Symbols" },
    { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
    { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Go to Definition" },

    -- 검색
    { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Word under cursor" },
    { "<leader>fo", "<cmd>Telescope vim_options<cr>", desc = "Vim Options" },
    { "<leader>fc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },

    -- 특수 검색
    { "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer Fuzzy Find" },
    { "<leader>f.", "<cmd>Telescope resume<cr>", desc = "Resume Last Search" },
  },
}
