# vscodium-config

Standard, version-controlled VSCodium setup for macOS. Clone this repo on any
Mac and run `./install.sh` to get an identical editor.

## What's inside

| File                | Purpose                                                        |
| ------------------- | -------------------------------------------------------------- |
| `settings.json`     | All user settings (editors, fonts, TS/Go, telemetry off).      |
| `keybindings.json`  | User keybindings.                                              |
| `snippets/`         | Per-language user snippets (`*.json` are symlinked).           |
| `extensions.txt`    | Extension IDs installed from Open VSX by `install.sh`.         |
| `custom.css`        | Workbench chrome font fix; applied via the Custom CSS ext.     |
| `install.sh`        | Symlinks the config into VSCodium and installs extensions.     |
| `bootstrap.sh`      | Clone-or-update + run `install.sh` (used by the one-liner).    |

## Install on a new Mac

One line (clones the repo and runs the installer):

```sh
curl -fsSL https://raw.githubusercontent.com/Jameshudson/vscodium-config/main/bootstrap.sh | bash
```

Or manually:

```sh
git clone https://github.com/Jameshudson/vscodium-config.git ~/Projects/vscodium-config
~/Projects/vscodium-config/install.sh
```

`install.sh` first checks for VSCodium and installs it via Homebrew if missing,
then symlinks the files into
`~/Library/Application Support/VSCodium/User/`, so `git pull` updates your
editor immediately. Existing files are backed up with a `.bak.<timestamp>`
suffix.

### Custom CSS (one-time, per machine)

The sidebar/tab chrome font size is not a native setting, so it is patched via
the **Custom CSS and JS Loader** extension (`s-h-a-d-o-w.vscode-custom-css`, the
Open VSX fork — the original `be5invis` one is not published to Open VSX):

```sh
# 1. allow VSCodium to patch itself
sudo chown -R "$(whoami)" "/Applications/VSCodium.app"
```
Then in VSCodium: `Cmd+Shift+P` → **Enable Custom CSS and JS** → reload.

Repeat after every VSCodium update (the patch is reverted by updates).

## Updating the standard

```sh
codium --list-extensions > extensions.txt
git add -A && git commit -m "Update VSCodium config"
git push
```

> Note: `settings.json`, `keybindings.json`, `custom.css` and snippets are
> symlinks into this repo, so edits made inside VSCodium land directly in the
> working tree — just `git add`/commit to share them.

## Notes

- VSCodium has **no built-in Settings Sync** (unlike VS Code), which is why this
  is git-based.
- Extensions are installed from [Open VSX](https://open-vsx.org/); any ID that
  only exists on the Microsoft Marketplace will fail to install.
