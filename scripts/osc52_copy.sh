#!/usr/bin/env bash

# 这段脚本是一个智能化的“复制适配器”，可以根据当前运行环境（本地还是 SSH / tmux）来判断应该如何处理复制操作。
# 它的目的是将标准输入中的内容复制到宿主机系统剪贴板，无论你是在本地终端、tmux 还是 SSH 远程环境中。
# 💡 脚本的用途场景总结
# 场景	问题	脚本的解决方式
# 本地终端 (非 tmux / 非 SSH)	tmux 复制无法自动粘贴	用 pbcopy / xclip 复制内容
# tmux 本地使用	tmux buffer 复制无法粘贴	用 OSC52 注入终端剪贴板
# 远程 SSH 场景	无法使用本地 pbcopy / xclip，鼠标也复制不了	用 OSC52 编码将数据发回终端
# 远程 SSH + tmux 场景	复制行为被隔离，既不能 pbcopy 又不能选中复制	使用 OSC52 成为唯一解决方式
#
# ✅ 这个脚本的最大价值是它“自动判断运行环境”，然后选择最合适的复制方法，从而统一复制行为。
# ✅ 如何使用该脚本（配合 tmux）
# 将此脚本保存为：
# ~/.local/bin/osc52-copy.sh
# chmod +x ~/.local/bin/osc52-copy.sh
# 在 ~/.tmux.conf 添加一行：
# bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "bash ~/.local/bin/osc52-copy.sh"
# 这样你在 tmux 的复制模式中按下 y（或可改为 Enter），就会使用这个脚本处理复制逻辑。
# 读取标准输入的内容，存入变量 input
# 这通常配合 tmux 的 copy-pipe 功能使用，用于接收用户在 tmux 中复制的内容

# 补充：确保终端支持 OSC52
# 终端程序	支持 OSC52 吗？	设置项
# iTerm2 (macOS)	✅ 支持	默认启用
# WezTerm	✅ 支持	默认启用
# Kitty	✅ 支持	默认启用
# GNOME Terminal	部分支持	需安装剪贴板扩展
# Windows	❌ 可能不支持	推荐使用 WezTerm

input=$(cat)

# 判断是否在 SSH 环境中
# -n "$SSH_CONNECTION"：如果变量非空，说明当前在 SSH 远程连接中。
# -n "$TMUX"：如果变量非空，说明当前在 tmux 里。
# 只要满足这两个条件中的任意一个，就说明我们不一定能直接访问系统剪贴板，所以使用 OSC52。
if [ -n "$SSH_CONNECTION" ] || [ -n "$TMUX" ]; then
    # 构造 OSC52 协议 的转义序列，将 base64 编码后的内容注入终端，由终端将其放入剪贴板。
    # \e]52;c;{base64内容}\a 是 OSC52 的规范格式。
    # 这是唯一能让远程终端中的内容“注入”到本地剪贴板的办法之一。
    printf "\e]52;c;%s\a" "$(printf "%s" "$input" | base64 | tr -d '\n')"
# 如果不在 SSH 或 tmux 环境中，就认为你是在本地终端中，直接使用系统命令来复制。
else
    # 如果是 macOS 系统（带有 pbcopy 命令），使用它将内容复制到系统剪贴板。
    if command -v pbcopy >/dev/null 2>&1; then
        printf "%s" "$input" | pbcopy
    # 如果是 Linux 系统，且安装了 xclip，用它将内容写入剪贴板（-selection clipboard 表示写入系统级剪贴板）。
    elif command -v xclip >/dev/null 2>&1; then
        printf "%s" "$input" | xclip -selection clipboard
    fi
fi
