# Repository Guidelines

## Project Structure & Module Organization

`tmux.conf` is the main configuration and the entry point used by the reload binding (`prefix` is `Ctrl+n`, then `r`). It defines key bindings, terminal behavior, and TPM plugin settings. `statusline.conf`, `theme.conf`, `utility.conf`, and `macos.conf` are separate configuration snippets; check whether a snippet is sourced before assuming it affects the active setup. `plugins/` contains third-party plugin repositories tracked as Git links. `备份文件/` holds reference configurations, not the active entry point. There is no application source tree or repository-level test suite.

## Development and Validation Commands

There is no build step. To load changes into a running server, use `tmux source-file ~/.config/tmux/tmux.conf`, or press `Ctrl+n` then `r` inside tmux. For an isolated configuration check, run `tmux -L guide-check -f "$PWD/tmux.conf" new-session -d -s guide-check`, then `tmux -L guide-check kill-server` after checking for errors. The isolated server uses a separate socket, so it does not reload your working sessions. Run `git diff --check` to catch whitespace errors. Plugin initialization can depend on locally installed programs and paths.

## Coding Style & Naming Conventions

Keep tmux commands in `.conf` files, one logical setting or binding per block. Follow the existing `# {{{` / `# }}}` comment folds and nearby indentation when editing `tmux.conf`. Name additional snippets by purpose, such as `statusline.conf`; use descriptive comments for bindings with shell commands or platform-specific behavior. Preserve LF line endings, as requested by `.gitattributes`. No formatter or linter is configured for this repository.

## Testing Guidelines

No project-wide tests or coverage target are defined. After editing, run the isolated tmux check and test affected bindings or status-line behavior in an interactive session. For terminal, clipboard, or macOS changes, verify on the relevant platform; a successful parse alone does not confirm the visible or clipboard result. Plugin-owned tests under `plugins/` belong to those upstream repositories.

## Commit & Pull Request Guidelines

The short Git history contains `Initial commit` and a timestamp-style subject, so it does not establish a consistent convention. Use a brief, descriptive commit subject for new changes. In pull requests, explain the user-visible behavior, list the tmux commands and interactive checks performed, and attach a screenshot when changing the status line or theme. Call out any new external command or plugin dependency. Keep changes to `plugins/` intentional and separate from local configuration edits.
