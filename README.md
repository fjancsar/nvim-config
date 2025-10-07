# Prerequisites (Windows)
## Install with **Chocolatey**

```powershell
choco install -y neovim git ripgrep fd 7zip nodejs-lts
choco install -y dotnet-sdk
choco install -y visualstudio2022buildtools --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --passive"
```

## Install with **winget**

```powershell
winget install Neovim.Neovim
winget install Git.Git
winget install BurntSushi.ripgrep.MSVC
winget install sharkdp.fd
winget install OpenJS.NodeJS.LTS
winget install Microsoft.DotNet.SDK.9
winget install Microsoft.VisualStudio.2022.BuildTools --override "--passive --add Microsoft.VisualStudio.Workload.VCTools"
```

## Dotnet tools

```powershell
dotnet tool install -g csharpier
dotnet tool install -g csharp-ls
```

> Why Build Tools? Treesitter compiles parsers with MSVC (x64).
> Why Node? only needed for rare TS grammars; safe to have.

---

# Get this config onto a machine

```powershell
# clone into Neovim’s config dir
git clone <your-private-repo-url> $env:LOCALAPPDATA\nvim

# (optional) first sync plugins headless
nvim --headless "+Lazy! sync" +qa
```

---

# Neovim setup (first time)

Open a project root (folder with `.csproj`/`.sln`):

```powershell
nvim .
```

Inside Neovim:

1. **Plugins**

```
:Lazy sync     " q to close when done
```

2. **Install language servers & tools**

```
:Mason
```

Press `i` on these if not installed:

```
roslyn
rzls
netcoredbg
lua-language-server
stylua
csharpier
json-lsp
html-lsp
css-lsp
typescript-language-server
eslint-lsp
```

3. **Treesitter parsers**

```
:TSInstallSync c_sharp razor lua vim
```

If this fails on Windows, run from a **VS Dev Prompt (x64)** then retry.

4. **Verify LSP**

```
:LspInfo        " should show 'roslyn' attached in a .cs file
```

---

# Daily usage (keys)

* **File tree**: `<Space>e` (toggle), `<Space>o` (reveal current file)
* **Find files / grep**: `<Space>ff`, `<Space>fg`, buffers: `<Space>fb`
* **Go to def / back**: `gd`, back: `Ctrl+o`, forward: `Ctrl+i`
* **References / hover / rename / actions**: `gr`, `K`, `<Space>rn`, `<Space>ca`
* **Diagnostics (Trouble)**:

  * Buffer: `<Space>xx`
  * Workspace: `<Space>xw`
  * Lists for symbol: `gD` (defs), `gr` (refs), `gI` (impl), `gt` (type defs)
* **Format on save**: enabled (CSharpier for `.cs`, Stylua for `.lua`)
  Manual: `:Format`
* **Debug (netcoredbg)**:
  F9 = breakpoint, F5 = start, F10/F11/Shift+F11 = step, DAP-UI auto-opens.
  First launch will prompt for the DLL (e.g. `bin/Debug/net9.0/YourApp.dll`).

---

# Quick checks / fixes

* **Treesitter complaints on Windows**

  * Open a **Developer Command Prompt for VS (x64)**:

    ```powershell
    & "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=x64
    ```
  * Then in Neovim:

    ```
    :TSUpdateSync c_sharp razor
    ```

* **CSharpier not formatting**

  * Confirm tool: `csharpier --version`
  * Try direct: `:!csharpier format %`
  * Ensure `lua/configs/conform.lua` contains:

    ```lua
    formatters_by_ft = { cs = { "csharpier" }, lua = { "stylua" } }
    format_on_save = { timeout_ms = 2000, lsp_fallback = true }
    formatters = {
      csharpier = { command = "csharpier", args = { "format", "$FILENAME" }, stdin = false, tempfile = true },
    }
    ```

* **Roslyn didn’t attach**

  * Open Neovim in the **project root** (where `.csproj` lives)
  * `:LspInfo` to see status
  * `:Mason` → ensure `roslyn` installed

---

That’s it. Copy this into `README.md` in your config repo.
