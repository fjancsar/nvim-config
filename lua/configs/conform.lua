local options = {
  -- what to use per filetype
  formatters_by_ft = {
    lua = { "stylua" },
    cs  = { "csharpier" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  -- enable format-on-save (optional)
  format_on_save = {
    timeout_ms = 1000,
    lsp_fallback = true,
  },

  -- custom formatter definitions (Windows-friendly)
  formatters = {
    csharpier = {
      command = "csharpier",                -- uses %USERPROFILE%\.dotnet\tools\csharpier.exe
      args = { "format", "$FILENAME" },     -- call the CLI on a temp file
      stdin = false,
      tempfile = true,
    },
  },
}

return options
