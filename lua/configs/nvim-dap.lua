-- lua/configs/nvim-dap.lua
local dap = require("dap")

-- ---------- helpers ----------
local function first_existing(paths)
  for _, p in ipairs(paths) do
    if vim.fn.filereadable(p) == 1 then
      return p
    end
  end
  return nil
end

local is_windows = vim.loop.os_uname().version:match("Windows")
local std_data = vim.fn.stdpath("data")
local mason_bin = std_data .. "/mason/bin"
local mason_pkgs = std_data .. "/mason/packages"

-- =====================================================================
-- .NET (netcoredbg)  — from Mason
-- =====================================================================
do
  local netcoredbg = first_existing({
    mason_pkgs .. "/netcoredbg/netcoredbg/netcoredbg.exe", -- Windows
    mason_pkgs .. "/netcoredbg/netcoredbg/netcoredbg",     -- Linux/macOS
    mason_bin .. "/netcoredbg.cmd",                        -- Windows shim
    mason_bin .. "/netcoredbg",                            -- *nix shim
  })

  if not netcoredbg then
    vim.notify("netcoredbg not found. Install with :MasonInstall netcoredbg", vim.log.levels.ERROR)
  else
    local adapter = {
      type = "executable",
      command = netcoredbg,
      args = { "--interpreter=vscode" },
    }
    dap.adapters.coreclr = adapter
    dap.adapters.netcoredbg = adapter

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "Launch .NET",
        request = "launch",
        program = function()
          local default_path = vim.fn.getcwd() .. "/bin/Debug/"
          return vim.fn.input("Path to DLL: ", default_path, "file")
        end,
      },
    }
  end
end

-- =====================================================================
-- Rust (codelldb) — from Mason
-- =====================================================================
do
  local codelldb = first_existing({
    mason_bin .. "/codelldb.cmd",                                         -- Windows shim
    mason_bin .. "/codelldb",                                             -- *nix shim
    mason_pkgs .. "/codelldb/extension/adapter/codelldb.exe",             -- Windows direct
    mason_pkgs .. "/codelldb/extension/adapter/codelldb",                 -- *nix direct
  })

  if not codelldb then
    -- Don’t hard error; user may not have Rust. Just warn once.
    vim.schedule(function()
      vim.notify("codelldb not found. Install with :MasonInstall codelldb", vim.log.levels.WARN)
    end)
  else
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = codelldb,
        args = { "--port", "${port}" },
      },
    }

    dap.configurations.rust = {
      {
        name = "Debug current binary (cargo build)",
        type = "codelldb",
        request = "launch",
        program = function()
          vim.fn.jobstart({ "cargo", "build" }, { detach = true })
          local default_dir = vim.fn.getcwd() .. (is_windows and "\\target\\debug\\" or "/target/debug/")
          return vim.fn.input("Path to executable: ", default_dir, "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }
  end
end

-- =====================================================================
-- Keymaps
-- =====================================================================
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<F5>", function() dap.continue() end, opts)
map("n", "<F9>", function() dap.toggle_breakpoint() end, opts)
map("n", "<F10>", function() dap.step_over() end, opts)
map("n", "<F11>", function() dap.step_into() end, opts)
map("n", "<S-F11>", function() dap.step_out() end, opts)

-- =====================================================================
-- DAP-UI (optional)
-- =====================================================================
pcall(function()
  local dapui = require("dapui")
  dapui.setup()
  dap.listeners.after.event_initialized["dapui_open"] = function() dapui.open() end
  dap.listeners.before.event_terminated["dapui_close"] = function() dapui.close() end
  dap.listeners.before.event_exited["dapui_close"] = function() dapui.close() end
end)
