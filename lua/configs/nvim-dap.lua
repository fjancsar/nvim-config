local dap = require("dap")

-- 🔍 Mason base (platform aware)
local mason_base = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg"
local is_windows = vim.loop.os_uname().version:match("Windows")
local exe = is_windows
  and (mason_base .. "/netcoredbg/netcoredbg.exe")
  or  (mason_base .. "/netcoredbg/netcoredbg")

-- 🧠 Validate
if vim.fn.filereadable(exe) == 0 then
  vim.notify("netcoredbg not found at: " .. exe, vim.log.levels.ERROR)
  return
end

-- 🧩 Adapter definition
local adapter = {
  type = "executable",
  command = exe,
  args = { "--interpreter=vscode" },
}

dap.adapters.coreclr = adapter
dap.adapters.netcoredbg = adapter

-- 🧪 Config for C# launch
dap.configurations.cs = {
  {
    type = "coreclr",
    name = "Launch .NET",
    request = "launch",
    program = function()
      -- Auto-suggest Debug folder (net8/net9 etc)
      local default_path = vim.fn.getcwd() .. "/bin/Debug/"
      local dll = vim.fn.input("Path to DLL: ", default_path, "file")
      return dll
    end,
  },
}

-- 🧭 Optional keymaps
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<F5>", function() dap.continue() end, opts)
map("n", "<F9>", function() dap.toggle_breakpoint() end, opts)
map("n", "<F10>", function() dap.step_over() end, opts)
map("n", "<F11>", function() dap.step_into() end, opts)
map("n", "<S-F11>", function() dap.step_out() end, opts)

-- 🧰 Optional: if DAP-UI installed
pcall(function()
  local dapui = require("dapui")
  dapui.setup()
  dap.listeners.after.event_initialized["dapui_open"] = function() dapui.open() end
  dap.listeners.before.event_terminated["dapui_close"] = function() dapui.close() end
  dap.listeners.before.event_exited["dapui_close"] = function() dapui.close() end
end)
