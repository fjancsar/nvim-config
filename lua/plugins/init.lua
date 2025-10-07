return {
  -- your existing formatter config
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },
  -- your existing lspconfig hook (keep it)
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  ---------------------------------------------------------------------------
  -- Treesitter: add C# + Razor grammars
  ---------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = opts.ensure_installed or {}
      for _, lang in ipairs({ "c_sharp", "lua", "vim" }) do
        if not vim.tbl_contains(opts.ensure_installed, lang) then
          table.insert(opts.ensure_installed, lang)
        end
      end
      -- sane defaults
      opts.highlight = opts.highlight or {}
      opts.highlight.enable = true
      opts.highlight.disable = opts.highlight.disable or { "vimdoc" }
      return opts
    end,
  },
  ---------------------------------------------------------------------------
  -- Mason: add Crashdummyy registry (roslyn & rzls live here) + ensure tools
  ---------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts = opts or {}
      -- add the custom registry while keeping defaults
      opts.registries = opts.registries or {
        "github:mason-org/mason-registry",
      }
      if not vim.tbl_contains(opts.registries, "github:Crashdummyy/mason-registry") then
        table.insert(opts.registries, "github:Crashdummyy/mason-registry")
      end

      -- make sure useful tools are listed (installed via :Mason or :MasonInstallAll)
      opts.ensure_installed = opts.ensure_installed or {}
      local to_install = {
        "lua-language-server",
        "stylua",
        "xmlformatter",
        "csharpier",
        "json-lsp",
        "html-lsp",
        "css-lsp",
        "typescript-language-server",
        "eslint-lsp",
        -- important for C#/Razor
        "roslyn",
        "rzls",
        -- debugger
        "netcoredbg",
      }
      for _, name in ipairs(to_install) do
        if not vim.tbl_contains(opts.ensure_installed, name) then
          table.insert(opts.ensure_installed, name)
        end
      end
      return opts
    end,
  },
  ---------------------------------------------------------------------------
  -- Roslyn LSP + Razor glue (rzls.nvim)
  ---------------------------------------------------------------------------
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    lazy = false, -- start the server when files open
    dependencies = {
      { "tris203/rzls.nvim", config = true },
    },
    config = function()
      -- Mason package layout (works on Windows & Linux)
      local mason = vim.fn.stdpath("data") .. "/mason/packages"
      local rzls_path = mason .. "/rzls/libexec"
      local join = vim.fs.joinpath

      -- Build Roslyn command with Razor bits from RZLS
      local cmd = {
        "roslyn",
        "--stdio",
        "--logLevel=Information",
        "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
        "--razorSourceGenerator=" .. join(rzls_path, "Microsoft.CodeAnalysis.Razor.Compiler.dll"),
        "--razorDesignTimePath=" .. join(rzls_path, "Targets", "Microsoft.NET.Sdk.Razor.DesignTime.targets"),
        "--extension=" .. join(rzls_path, "RazorExtension", "Microsoft.VisualStudioCode.RazorExtension.dll"),
      }

      -- Handlers from rzls.nvim so Razor/C# play nicely together
      local handlers = require("rzls.roslyn_handlers")

      vim.lsp.config("roslyn", {
        cmd = cmd,
        handlers = handlers,
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          },
          ["csharp|code_lens"] = { dotnet_enable_references_code_lens = true },
        },
      })

      -- enable Roslyn globally
      vim.lsp.enable("roslyn")

      -- recognize Razor on Windows
      vim.filetype.add({
        extension = { razor = "razor", cshtml = "razor" },
      })
    end,
  },
  ---------------------------------------------------------------------------
  -- Debugger: nvim-dap (we'll set netcoredbg path in lua/configs/nvim-dap.lua)
  ---------------------------------------------------------------------------
  {
    "mfussenegger/nvim-dap",
    config = function()
      require "configs.nvim-dap"
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui"]      = function() dapui.close() end
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          follow_current_file = { enabled = true },
          filtered_items = { hide_dotfiles = false, hide_gitignored = false },
        },
        window = { width = 30 },
      })
      -- Keybindings
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle left<cr>", { desc = "Toggle file explorer" })
      vim.keymap.set("n", "<leader>o", "<cmd>Neotree reveal<cr>", { desc = "Reveal current file" })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help" })
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble", "TroubleToggle" },
    opts = {
      use_diagnostic_signs = true, -- use your sign column icons
      focus = true,
      auto_jump = false,            -- don’t auto jump on single result
    },
    keys = {
      -- diagnostics
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",            desc = "Diagnostics (buffer)" },
      { "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (workspace)" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.severity=vim.diagnostic.severity.ERROR<cr>", desc = "Errors only" },
      -- lists
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                 desc = "Quickfix list" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                desc = "Location list" },
      -- LSP pickers inside Trouble (nice UI for results)
      { "gr",         "<cmd>Trouble lsp_references toggle<cr>",         desc = "LSP References (Trouble)" },
      { "gd",         "<cmd>Trouble lsp_definitions toggle<cr>",        desc = "LSP Definitions (Trouble)" },
      { "gI",         "<cmd>Trouble lsp_implementations toggle<cr>",    desc = "LSP Implementations (Trouble)" },
      { "gt",         "<cmd>Trouble lsp_type_definitions toggle<cr>",   desc = "LSP Type Defs (Trouble)" },
    },
  }
}
