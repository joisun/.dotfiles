#!/bin/zsh

# 检查是否提供了分支名称作为参数
if [ $# -ne 1 ]; then
    echo "用法: $0 <分支名称>"
    exit 1
fi

BRANCH_NAME="$1"

# 遍历当前目录下所有一级目录
for dir in */; do
    # 检查是否为目录且包含 .git 目录
    if [ -d "$dir/.git" ]; then
        # 在该目录下执行 git branch 检查分支是否存在
        if git -C "$dir" branch --list "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
            # 仅输出项目名称（去掉末尾的斜杠）
            echo "${dir%/}"
        fi
    fi
done
