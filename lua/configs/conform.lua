-- lua/configs/conform.lua
local options = {
  -- per-filetype formatter mapping
  formatters_by_ft = {
    lua  = { "stylua" },
    cs   = { "csharpier" },
    rust = { "rustfmt" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  -- enable format-on-save
  format_on_save = {
    timeout_ms = 1000,
    lsp_fallback = true,
  },

  -- custom formatter definitions
  formatters = {
    csharpier = {
      command  = "csharpier",                -- expects %USERPROFILE%\.dotnet\tools on PATH
      args     = { "format", "$FILENAME" },  -- run on temp file (Windows-friendly)
      stdin    = false,
      tempfile = true,
    },
    rustfmt = {
      command = "rustfmt",
      args    = { "--edition", "2021" },
      stdin   = true,
    },
  },
}

return options
