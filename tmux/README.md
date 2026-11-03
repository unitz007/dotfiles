# tmux + Claude Code

A tmux setup for running several [Claude Code](https://claude.com/claude-code) sessions side by side, one per project window, and seeing at a glance which ones need you.

```
 TMUX  Work   1:api ⠹  2:web ●  3:infra ✓  4:logs                       14:32 laptop
```

| Indicator | Meaning |
|---|---|
| `⠋⠙⠹⠸…` spinner | Claude is working |
| `●` | Claude is waiting for you (permission prompt or question) |
| `✓` | Claude finished. Cleared when you open the window |
| `✗` | The turn failed (API error) |

## What's here

| File | What it does |
|---|---|
| [`tmux.conf`](tmux.conf) | `Ctrl+Space` prefix, vi copy mode, Catppuccin-coloured status bar with the indicators, windows numbered from 1, TPM plugins |
| [`claude-tmux-state`](claude-tmux-state) | Called by Claude Code hooks. Stores Claude's state on the tmux window it runs in (`@claude_state`) |
| [`claude-hooks.json`](claude-hooks.json) | The Claude Code hooks to merge into `~/.claude/settings.json` |
| [`tm`](tm) | Launcher: creates your sessions and project windows from a config file (each window can start Claude, resuming its last conversation), then attaches |
| [`tm-sessions.example`](tm-sessions.example) | Example config for `tm` |
| [`tmux-goto`](tmux-goto) | `prefix g <letter>` jumps to the window whose name starts with that letter. Press it again to cycle through windows that share the letter |

## Install

Requires tmux 3.2 or later, and Claude Code for the indicators.

1. Link the files. `bootstrap.sh` in this repo does this, or by hand:

   ```bash
   ln -s "$PWD/tmux" ~/.tmux
   ln -s "$PWD/tmux/tmux.conf" ~/.tmux.conf
   ln -s "$PWD/tmux/tm" ~/.local/bin/tm
   ```

   The config calls scripts under `~/.tmux/`, so that link matters. Clone TPM and install the plugins:

   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ~/.tmux/plugins/tpm/bin/install_plugins
   ```

2. Add the hooks from [`claude-hooks.json`](claude-hooks.json) to the `hooks` section of `~/.claude/settings.json`. Merge them with any hooks you already have. If you have none:

   ```bash
   jq -s '.[0] * .[1]' ~/.claude/settings.json ~/.tmux/claude-hooks.json > /tmp/settings.json \
     && mv /tmp/settings.json ~/.claude/settings.json
   ```

   New Claude sessions pick the hooks up; restart ones that are already running.

3. Set up your sessions:

   ```bash
   mkdir -p ~/.config/tm
   cp ~/.tmux/tm-sessions.example ~/.config/tm/sessions
   ```

   Edit it to list your projects, then run `tm`.

## Usage

| | |
|---|---|
| `tm` | Create any missing sessions from `~/.config/tm/sessions` and attach to the first one |
| `tm <name>` | Attach to the session whose name starts with `<name>` |
| `tm -l` | List the sessions in the config |
| `prefix g <letter>` | Jump to the next window whose name starts with `<letter>` |
| `prefix 1`–`9` | Jump to a window by number |
| `prefix C-s` / `prefix C-r` | Save / restore all sessions (tmux-resurrect) |

`tm` leaves sessions that already exist alone, so it is safe to run any time. After a reboot, running `tm` brings everything back, and each Claude window continues its last conversation (`claude --continue`).

tmux-continuum saves a snapshot every 15 minutes. Automatic restore is off because `tm` rebuilds the sessions; use `prefix C-r` to restore anything else.

## How the indicators work

Claude Code runs hooks at points in its lifecycle. Each hook runs `claude-tmux-state <state>`, which uses `$TMUX_PANE` (inherited from the pane Claude runs in) to set a window option:

| Hook | State |
|---|---|
| `UserPromptSubmit`, `PostToolUse` | `working` |
| `Notification` (permission prompt or question) | `waiting` |
| `Stop` | `done` |
| `StopFailure` | `error` |
| `SessionEnd` | cleared |

The status bar reads `@claude_state` in `window-status-format`. The spinner frame is chosen from the last digit of the current second (`status-interval 1`), so it needs no background process. A `session-window-changed` hook clears `✓` when you open the window.

Outside tmux, `claude-tmux-state` does nothing.

## Test it

Set a state by hand on another window and watch the status bar:

```bash
for s in working waiting done error; do tmux set -w -t :2 @claude_state $s; sleep 3; done
tmux set -wu -t :2 @claude_state
```
