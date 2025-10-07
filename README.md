# Neovim Development Setup (C# + Rust, Windows)

## Prerequisites

### Option 1 — Chocolatey

```powershell
choco install -y neovim git ripgrep fd 7zip nodejs-lts
choco install -y dotnet-sdk
choco install -y visualstudio2022buildtools --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --passive"
```

### Option 2 — winget (recommended)

```powershell
winget install Neovim.Neovim
winget install Git.Git
winget install BurntSushi.ripgrep.MSVC
winget install sharkdp.fd
winget install OpenJS.NodeJS.LTS
winget install Microsoft.DotNet.SDK.9
winget install Microsoft.VisualStudio.2022.BuildTools --override "--passive --add Microsoft.VisualStudio.Workload.VCTools"
```

Why Build Tools? Treesitter needs MSVC for native parser builds.
Why Node? Required only by some JS/TS-based grammars; safe to include.
.NET 9 SDK is required for Roslyn LSP (`Microsoft.CodeAnalysis.LanguageServer.dll`).

---

## .NET Tools

```powershell
dotnet tool install -g csharpier
dotnet tool install -g csharp-ls
```

If NuGet feeds are blocked by proxy, create a local `NuGet.only-nugetorg.config` file and use `--configfile` when installing.

---

## Get This Config

```powershell
# clone into Neovim’s config folder
git clone <your-private-repo-url> $env:LOCALAPPDATA\nvim

# optional: pre-sync plugins headless
nvim --headless "+Lazy! sync" +qa
```

---

## First-Time Setup

### 1. Open a project

Open your repository root (contains `.sln`, `.csproj`, or `Cargo.toml`):

```powershell
nvim .
```

### 2. Sync plugins

```
:Lazy sync
```

Press `q` to close when finished.

### 3. Install language servers

```
:Mason
```

Press `i` to install these if missing:

```
roslyn
rzls
netcoredbg
lua-language-server
stylua
csharpier
rust-analyzer
json-lsp
html-lsp
css-lsp
typescript-language-server
eslint-lsp
```

### 4. Treesitter parsers

```
:TSInstallSync c_sharp razor lua vim rust
```

If this fails on Windows, run Neovim from a Visual Studio Developer Command Prompt (x64) and retry.

### 5. Verify LSP

```
:LspInfo
```

Should show `roslyn` attached in a `.cs` file or `rust_analyzer` in a `.rs` file.

---

## Daily Usage (Keybindings)

| Action                                      | Command / Key                       |
| ------------------------------------------- | ----------------------------------- |
| Toggle file tree                            | `<Space>e`                          |
| Reveal current file                         | `<Space>o`                          |
| Find files                                  | `<Space>ff`                         |
| Live grep                                   | `<Space>fg`                         |
| Find open buffers                           | `<Space>fb`                         |
| Go to definition                            | `gd`                                |
| Go back / forward                           | `Ctrl+o` / `Ctrl+i`                 |
| References / Hover / Rename / Actions       | `gr`, `K`, `<Space>rn`, `<Space>ca` |
| Diagnostics (Trouble) - buffer              | `<Space>xx`                         |
| Diagnostics (Trouble) - workspace           | `<Space>xw`                         |
| Type definitions / Implementations          | `gt`, `gI`                          |
| Format file                                 | `:Format` or save                   |
| Debug start                                 | `F5`                                |
| Breakpoint / Step over / Step in / Step out | `F9`, `F10`, `F11`, `Shift+F11`     |

---

## Quick Checks and Fixes

### Treesitter errors on Windows

Open a Developer Command Prompt for Visual Studio (x64):

```powershell
& "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=x64
```

Then in Neovim:

```
:TSUpdateSync c_sharp razor rust
```

---

### CSharpier not formatting

Check:

```powershell
csharpier --version
```

Try manually:

```
:!csharpier format %
```

Ensure your `lua/configs/conform.lua` contains:

```lua
local options = {
  formatters_by_ft = {
    lua  = { "stylua" },
    cs   = { "csharpier" },
    rust = { "rustfmt" },
  },
  format_on_save = {
    timeout_ms = 2000,
    lsp_fallback = true,
  },
  formatters = {
    csharpier = {
      command = "csharpier",
      args = { "format", "$FILENAME" },
      stdin = false,
      tempfile = true,
    },
    rustfmt = {
      command = "rustfmt",
      args = { "--edition", "2021" },
      stdin = true,
    },
  },
}
return options
```

---

### Roslyn not attaching

1. Open Neovim in your project root (where `.csproj` lives).
2. Run `:LspInfo` to check active servers.
3. Open `:Mason` and ensure `roslyn` is installed.
4. Confirm you have .NET 9 runtime and SDK:

   ```powershell
   dotnet --list-sdks
   ```

---

### Rust Analyzer not attaching

1. Run `rust-analyzer --version` to confirm installation.
2. Ensure `Cargo.toml` is present at project root.
3. Open any `.rs` file and run:

   ```
   :LspInfo
   ```

   It should show `rust_analyzer` attached.

---

### Debugging Rust

Neovim uses the same DAP interface for Rust as for .NET.
You can debug binaries built via Cargo:

1. Build your app first:

   ```powershell
   cargo build
   ```
2. In Neovim:

   * Press `F5` to start debugging.
   * When prompted, select the `.exe` under `target\debug\`.

---