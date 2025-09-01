# .dotfiles

for my macOS

---

## 使用方法 (Usage)

#### 首次安装 (First-time Setup)

1.  **克隆仓库 (Clone Repository)**
    ```bash
    git clone https://github.com/joi-com/dotfiles.git ~/.dotfiles
    ```

2.  **重载 Shell (Reload Shell)**
    安装脚本已将 `bin` 目录添加到 `PATH`。为使其生效, 请**重启终端**或执行：

    ```bash
    source ~/.zshrc
    ```

#### 日常使用 (Everyday Use)

安装完成后, 您可以在任何路径下直接使用 `bin` 目录中的命令：

-   `dot_sync`: 同步远端仓库及本地配置。
-   `dot_setup_my_mac`: 重新执行安装流程(电脑初始化), 会检查并安装所有指定的软件。
-   `setup <repo> <dir>`: 快速初始化一个新项目。

---

## 目录说明 (Directory Structure)

-   **`bin/`**: 全局可执行脚本。
-   **`scripts/`**: `bin` 脚本所调用的辅助脚本。
-   **`dot.configs/`**: 其他工具的配置文件。
-   **`workspace_scripts/`**: 工作区常用脚本, 会被硬链接到 ~/Desktop/workspace/
-   **`Brewfile`**: Homebrew 应用列表。
-   **`.macos`**: macOS 系统设置。
-   **`.zshrc`, `aliases.zsh`**: Zsh Shell 配置。
