#!/bin/zsh

# 批量对所有Git仓库执行git fetch
# 使用方法: ./batch_git_fetch.sh [目录] [选项]
# 示例: ./batch_git_fetch.sh /path/to/projects
# 选项:
#   -r              递归扫描子目录（默认不递归）
#   --verbose       显示详细输出（默认只显示摘要）
#   --dry-run       只显示会处理的仓库，不执行fetch
#   --help          显示帮助信息

# 显示帮助信息
show_help() {
    echo "Git批量fetch脚本"
    echo ""
    echo "使用方法: $0 [目录] [选项]"
    echo ""
    echo "参数:"
    echo "  [目录]        要扫描的目录（可选，默认为当前目录）"
    echo ""
    echo "选项:"
    echo "  -r              递归扫描子目录中的 Git 仓库"
    echo "  --verbose       显示详细的fetch输出"
    echo "  --dry-run       只显示会处理的仓库，不执行实际fetch"
    echo "  --help          显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                    # fetch当前目录下的所有Git仓库"
    echo "  $0 /path/to/projects  # fetch指定目录下的所有Git仓库"
    echo "  $0 -r                 # 递归fetch当前目录及子目录的所有Git仓库"
    echo "  $0 --verbose          # 显示详细的fetch输出"
    echo "  $0 --dry-run          # 只显示会处理的仓库列表"
    exit 0
}

# 解析参数
RECURSIVE=false
VERBOSE=false
DRY_RUN=false
BASE_DIR=""

for arg in "$@"; do
    case $arg in
        --help)
            show_help
            ;;
        -r)
            RECURSIVE=true
            ;;
        --verbose)
            VERBOSE=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        *)
            if [ -z "$BASE_DIR" ]; then
                BASE_DIR="$arg"
            fi
            ;;
    esac
done

BASE_DIR=${BASE_DIR:-"."}

# 检查目录是否存在
if [ ! -d "$BASE_DIR" ]; then
    echo "错误: 目录 '$BASE_DIR' 不存在"
    exit 1
fi

echo "Git批量fetch操作"
echo "扫描目录: $(realpath "$BASE_DIR")"
if [ "$RECURSIVE" = true ]; then
    echo "扫描模式: 递归扫描"
else
    echo "扫描模式: 仅扫描直接子目录"
fi
echo "========================"

# 根据是否递归设置find命令
repo_list=""
if [ "$RECURSIVE" = false ]; then
    repo_list=$(find "$BASE_DIR" -maxdepth 2 -type d -name ".git" -exec dirname {} \;)
else
    repo_list=$(find "$BASE_DIR" -type d -name ".git" -exec dirname {} \;)
fi

# 统计变量
total_repos=0
success_count=0
error_count=0
skipped_count=0

# 临时文件存储错误信息
ERROR_FILE=$(mktemp)

echo "$repo_list" | while read -r repo; do
    [ -z "$repo" ] && continue
    
    REPO_NAME=$(basename "$repo")
    REPO_PATH=$(realpath "$repo")
    total_repos=$((total_repos + 1))
    
    echo ""
    echo "[$total_repos] 处理仓库: $REPO_NAME"
    echo "    路径: $REPO_PATH"
    
    # 检查是否有远程仓库
    cd "$repo" || continue
    
    remote_count=$(git remote | wc -l)
    if [ "$remote_count" -eq 0 ]; then
        echo "    状态: 跳过 (无远程仓库)"
        skipped_count=$((skipped_count + 1))
        continue
    fi
    
    # 显示远程仓库信息
    echo "    远程仓库:"
    git remote -v | sed 's/^/      /'
    
    if [ "$DRY_RUN" = true ]; then
        echo "    操作: [DRY RUN] 将执行 git fetch"
        continue
    fi
    
    # 执行git fetch
    echo "    操作: 执行 git fetch..."
    
    if [ "$VERBOSE" = true ]; then
        # 显示详细输出
        if git fetch --all --prune 2>&1; then
            echo "    结果: ✅ fetch成功"
            success_count=$((success_count + 1))
        else
            echo "    结果: ❌ fetch失败"
            echo "$REPO_NAME: fetch失败" >> "$ERROR_FILE"
            error_count=$((error_count + 1))
        fi
    else
        # 静默执行，只显示结果
        if git fetch --all --prune >/dev/null 2>&1; then
            echo "    结果: ✅ fetch成功"
            success_count=$((success_count + 1))
        else
            echo "    结果: ❌ fetch失败"
            echo "$REPO_NAME: fetch失败" >> "$ERROR_FILE"
            error_count=$((error_count + 1))
        fi
    fi
    
    cd - > /dev/null || exit
done

echo ""
echo "========================"
echo "批量fetch完成!"
echo ""
echo "统计信息:"
echo "  总计仓库: $total_repos"
if [ "$DRY_RUN" = false ]; then
    echo "  成功: $success_count"
    echo "  失败: $error_count"
    echo "  跳过: $skipped_count"
    
    # 显示错误信息
    if [ -s "$ERROR_FILE" ]; then
        echo ""
        echo "失败的仓库:"
        cat "$ERROR_FILE" | sed 's/^/  /'
    fi
else
    echo "  [DRY RUN模式] 实际未执行fetch操作"
fi

# 清理临时文件
rm -f "$ERROR_FILE"

echo ""
echo "操作完成!"
