return {
  {
    "sdlc.nvim",
    dir = vim.fn.stdpath("config"),
    name = "sdlc.nvim",
    cmd = {
      "Sdlc",
      "SdlcRun",
      "SdlcRunWatch",
      "SdlcTest",
      "SdlcTestFile",
      "SdlcBuild",
      "SdlcInstall",
      "SdlcClean",
      "SdlcList",
      "SdlcPickModule",
      "SdlcClearModule",
      "SdlcDryRun",
    },
    keys = {
      { "<leader>sr", "<cmd>SdlcRun<cr>", desc = "SDLC Run" },
      { "<leader>sR", "<cmd>SdlcRunWatch<cr>", desc = "SDLC Run Watch" },
      { "<leader>st", "<cmd>SdlcTest<cr>", desc = "SDLC Test" },
      { "<leader>sT", "<cmd>SdlcTestFile<cr>", desc = "SDLC Test File" },
      { "<leader>sb", "<cmd>SdlcBuild<cr>", desc = "SDLC Build" },
      { "<leader>si", "<cmd>SdlcInstall<cr>", desc = "SDLC Install" },
      { "<leader>sc", "<cmd>SdlcClean<cr>", desc = "SDLC Clean" },
      { "<leader>sl", "<cmd>SdlcList<cr>", desc = "SDLC List Modules" },
      { "<leader>sm", "<cmd>SdlcPickModule<cr>", desc = "SDLC Pick Module" },
      { "<leader>sM", "<cmd>SdlcClearModule<cr>", desc = "SDLC Clear Module" },
      { "<leader>sd", "<cmd>SdlcDryRun<cr>", desc = "SDLC Dry Run" },
      {
        "<leader>sx",
        function()
          require("sdlc").prompt_command()
        end,
        desc = "SDLC Command",
      },
    },
    opts = {
      bin = "sdlc",
      output = "float",
      float_row = 2,
      float_width = 0.88,
      float_height = 0.75,
      terminal_direction = "horizontal",
      terminal_size = 15,
      terminal_width = 72,
    },
    config = function(_, opts)
      require("sdlc").setup(opts)
    end,
  },
}
