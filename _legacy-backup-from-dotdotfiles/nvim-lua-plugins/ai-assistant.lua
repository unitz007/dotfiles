-- AI Assistant Plugin Configuration
-- Integrates local LLM capabilities into Neovim



---@type LazySpec
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<C-l>",
            accept_word = false,
            accept_line = false,
            next = "<C-]>",
            prev = "<C-[>",
            dismiss = "<C-c>",
          },
        },
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>"
          },
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = "node", -- Node.js version must be >= 16.x
        server_opts_overrides = {},
      })
    end,
  },

  {
    "github/copilot.vim",
    event = "InsertEnter",
  },

  -- Alternative: Local LLM integration via Ollama
  {
    "jcdickinson/codeium.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("codeium").setup({
        enable = true,
        disable_inline_completion = false,
        disable_signatures = false,
        keymap = {
          accept = "<C-l>",
          accept_word = "<C-w>",
          accept_line = "<C-l>",
          next = "<C-]>",
          prev = "<C-[>",
          dismiss = "<C-c>",
        },
        api_url = "http://localhost:11434",
        debug = false,
      })
    end,
  },

  -- Custom AI commands
  {
    "nvim-lua/plenary.nvim",
    -- Required dependency for custom AI functions
  },

  -- Add AI assistant commands
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        {
          "<leader>a",
          group = "AI Assistant",
          {
            "e",
            function()
              -- Explain current function
              require("ai-assistant").explain_current()
            end,
            desc = "Explain current code",
          },
          {
            "r",
            function()
              -- Refactor current selection
              require("ai-assistant").refactor_current()
            end,
            desc = "Refactor code",
          },
          {
            "t",
            function()
              -- Generate tests
              require("ai-assistant").generate_tests()
            end,
            desc = "Generate tests",
          },
          {
            "c",
            function()
              -- Complete current line
              require("ai-assistant").complete_line()
            end,
            desc = "Complete line",
          },
        },
      },
    },
  },
}