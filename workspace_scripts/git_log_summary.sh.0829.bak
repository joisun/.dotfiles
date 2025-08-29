#!/bin/zsh

# 脚本用于总结过去指定天数内各个项目的Git提交日志
# 使用方法: ./git_log_summary.sh <天数> [目录] [选项]
# 示例: ./git_log_summary.sh 7 /path/to/projects
# 选项:
#   -r              递归扫描子目录（默认不递归）
#   --show-merge    显示merge提交信息（默认隐藏）
#   --summary       显示统计信息（默认不显示）
#   --verbose       显示处理进度（默认不显示）
#   --dedup         去重相同的提交信息（默认不去重）
#   --include-copies 包含复制仓库（默认自动忽略复制仓库）
#   --help          显示帮助信息

# 显示帮助信息
show_help() {
    echo "Git提交日志汇总脚本"
    echo ""
    echo "使用方法: $0 <天数> [目录] [选项]"
    echo ""
    echo "参数:"
    echo "  <天数>        要统计的天数（必需）"
    echo "  [目录]        要扫描的目录（可选，默认为当前目录）"
    echo ""
    echo "选项:"
    echo "  -r              递归扫描子目录中的 Git 仓库"
    echo "  --show-merge    显示merge提交信息（默认隐藏）"
    echo "  --summary       显示统计信息（默认不显示）"
    echo "  --verbose       显示处理进度（默认不显示）"
    echo "  --dedup         去重相同的提交信息（默认不去重）"
    echo "  --include-copies 包含复制仓库（默认自动忽略复制仓库）"
    echo "  --help          显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 7                    # 统计当前目录及直接子目录最近7天的提交"
    echo "  $0 14 /path/to/projects -r # 递归统计指定目录最近14天的提交"
    echo "  $0 7 . --show-merge      # 统计最近7天的提交，包括merge信息"
    echo "  $0 7 . --summary        # 统计最近7天的提交，显示统计信息"
    echo "  $0 7 . --verbose        # 统计最近7天的提交，显示处理进度"
    echo "  $0 7 . --dedup          # 统计最近7天的提交，去重相同提交"
    echo "  $0 7 . --include-copies # 统计最近7天的提交，包含复制仓库"
    exit 0
}

# 解析参数
SHOW_MERGE=false
RECURSIVE=false
SHOW_SUMMARY=false
VERBOSE=false
DEDUP=false
DAYS=""
BASE_DIR=""

for arg in "$@"; do
    case $arg in
        --help)
            show_help
            ;;
        -r)
            RECURSIVE=true
            ;;
        --show-merge)
            SHOW_MERGE=true
            ;;
        --summary)
            SHOW_SUMMARY=true
            ;;
        --verbose)
            VERBOSE=true
            ;;
        --dedup)
            DEDUP=true
            ;;
        *)
            if [ -z "$DAYS" ]; then
                DAYS="$arg"
            elif [ -z "$BASE_DIR" ]; then
                BASE_DIR="$arg"
            fi
            ;;
    esac
done

if [ -z "$DAYS" ]; then
    echo "错误: 必须指定天数"
    echo "使用 $0 --help 查看帮助信息"
    exit 1
fi

# 验证天数是否为数字
if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
    echo "错误: 天数必须是正整数"
    exit 1
fi

BASE_DIR=${BASE_DIR:-"."}

# 获取仓库的远程地址（用于识别复制仓库）
get_repo_remote_url() {
    local repo_path="$1"
    local remote_url=""
    
    # 尝试获取 origin 的 URL
    if [ -f "$repo_path/.git/config" ]; then
        # 从 .git/config 中提取远程地址
        remote_url=$(git -C "$repo_path" config --get remote.origin.url 2>/dev/null)
        
        # 如果没有 origin，尝试获取第一个远程仓库
        if [ -z "$remote_url" ]; then
            remote_url=$(git -C "$repo_path" remote -v 2>/dev/null | head -1 | awk '{print $2}')
        fi
    fi
    
    # 如果还是没有远程地址，使用仓库路径作为唯一标识
    if [ -z "$remote_url" ]; then
        # 使用 .git 目录的创建时间和路径的组合作为标识
        local git_dir_stat=$(stat -f "%m" "$repo_path/.git" 2>/dev/null || stat -c "%Y" "$repo_path/.git" 2>/dev/null || echo "unknown")
        remote_url="local:$(realpath "$repo_path"):$git_dir_stat"
    fi
    
    echo "$remote_url"
}

# 判断是否为复制仓库
is_copy_repo() {
    local repo_name="$1"
    
    # 常见的复制仓库模式：
    # 1. 以数字结尾：name-2, name-3, name_2, name_3
    # 2. 包含copy标识：name-copy, name_copy, name-backup
    # 3. 包含日期：name-20240101, name_0801
    # 4. 包含temp标识：name-tmp, name-temp, name_tmp
    # 5. 包含test标识：name-test, name_test
    
    if [[ "$repo_name" =~ -[0-9]+$ ]] || \
       [[ "$repo_name" =~ _[0-9]+$ ]] || \
       [[ "$repo_name" =~ -(copy|backup|tmp|temp|test)$ ]] || \
       [[ "$repo_name" =~ _(copy|backup|tmp|temp|test)$ ]] || \
       [[ "$repo_name" =~ -[0-9]{6,8}$ ]] || \
       [[ "$repo_name" =~ _[0-9]{6,8}$ ]] || \
       [[ "$repo_name" =~ -(bak|clone)$ ]] || \
       [[ "$repo_name" =~ _(bak|clone)$ ]]; then
        return 0  # 是复制仓库
    fi
    return 1  # 不是复制仓库
}
is_merge_commit() {
    local message="$1"
    if [[ "$message" =~ ^[Mm]erge.*$ ]] || \
       [[ "$message" =~ ^[Aa]uto.*merge.*$ ]] || \
       [[ "$message" =~ .*into.*from.*$ ]] || \
       [[ "$message" =~ ^[Pp]ull.*request.*$ ]]; then
        return 0
    fi
    return 1
}

# 提取任务/主题标签
extract_topic() {
    local message="$1"
    local topic=""

    # 查找第一个形如 #topic:value 的部分
    local full_tag_and_value=$(echo "$message" | grep -oE '#topic:[^#]*' | head -1)

    if [ -n "$full_tag_and_value" ]; then
        # 从找到的字符串中，移除'#topic:'前缀，并去除首尾空格
        topic=$(echo "$full_tag_and_value" | sed -e 's/^#topic://' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    fi

    # 如果没有找到 #topic: 标签，则归类为"其他"
    if [ -z "$topic" ]; then
        topic="其他"
    fi

    echo "$topic"
}

# 跨平台的日期计算函数
get_since_date() {
    local days=$1
    
    # 尝试 macOS 的 date 命令
    if date -v-${days}d +%Y-%m-%d 2>/dev/null; then
        return 0
    fi
    
    # 尝试 GNU date (Linux)
    if date -d "${days} days ago" +%Y-%m-%d 2>/dev/null; then
        return 0
    fi
    
    # 备用方案：使用 Python
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import datetime
target_date = datetime.datetime.now() - datetime.timedelta(days=${days})
print(target_date.strftime('%Y-%m-%d'))
"
        return 0
    fi
    
    # 如果都失败了，返回错误
    echo "错误: 无法计算日期" >&2
    exit 1
}

# 获取指定天数前的日期
SINCE_DATE=$(get_since_date "$DAYS")
if [ "$VERBOSE" = true ]; then
    echo "统计时间范围: $SINCE_DATE 到 $(date +%Y-%m-%d)"
fi

# 临时文件存储提交日志
TEMP_FILE=$(mktemp)

if [ "$VERBOSE" = true ]; then
    echo "收集 $DAYS 天内的提交日志..."
    if [ "$SHOW_MERGE" = false ]; then
        echo "注意: 默认隐藏merge提交，使用 --show-merge 参数显示"
    fi
fi

# 根据是否递归设置find命令
repo_list=""
if [ "$RECURSIVE" = false ]; then
    if [ "$VERBOSE" = true ]; then
        echo "提示: 默认只扫描直接子目录。使用 -r 选项进行递归扫描。"
    fi
    repo_list=$(find "$BASE_DIR" -maxdepth 2 -type d -name ".git" -exec dirname {} \;)
else
    if [ "$VERBOSE" = true ]; then
        echo "提示: 正在进行递归扫描..."
    fi
    repo_list=$(find "$BASE_DIR" -type d -name ".git" -exec dirname {} \;)
fi

# 查找所有git仓库并过滤复制仓库
REPO_MAP_FILE=$(mktemp)
FILTERED_REPOS_FILE=$(mktemp)

if [ "$INCLUDE_COPIES" = false ] && [ "$VERBOSE" = true ]; then
    echo "正在识别并过滤复制仓库..."
fi

# 第一遍：收集所有仓库信息
echo "$repo_list" | while read -r repo; do
    [ -z "$repo" ] && continue
    
    REPO_NAME=$(basename "$repo")
    REPO_PATH=$(realpath "$repo")
    REMOTE_URL=$(get_repo_remote_url "$repo")
    REPO_NAME_LENGTH=${#REPO_NAME}
    
    if [ "$VERBOSE" = true ]; then
        echo "检测仓库: $REPO_NAME -> 远程地址: $REMOTE_URL"
    fi
    
    # 格式：remote_url|repo_path|repo_name|name_length
    echo "$REMOTE_URL|$REPO_PATH|$REPO_NAME|$REPO_NAME_LENGTH" >> "$REPO_MAP_FILE"
done

# 调试：显示收集到的仓库信息
if [ "$VERBOSE" = true ]; then
    echo ""
    echo "收集到的仓库信息："
    cat "$REPO_MAP_FILE"
    echo ""
fi

# 第二遍：对于每个远程地址，只保留目录名最短的仓库
if [ "$INCLUDE_COPIES" = false ]; then
    # 按远程地址分组，保留目录名最短的
    sort "$REPO_MAP_FILE" | \
    awk -F'|' '
    {
        remote_url = $1
        repo_path = $2
        repo_name = $3
        name_length = $4
        
        if (!(remote_url in shortest_name_length) || name_length < shortest_name_length[remote_url]) {
            shortest_name_length[remote_url] = name_length
            selected_repos[remote_url] = repo_path "|" repo_name
            if (remote_url in skipped_repos) {
                skipped_repos[remote_url] = skipped_repos[remote_url] " " previous_selected[remote_url]
            }
            previous_selected[remote_url] = repo_name
        } else {
            skipped_repos[remote_url] = skipped_repos[remote_url] " " repo_name
        }
    }
    END {
        for (remote_url in selected_repos) {
            print selected_repos[remote_url]
        }
    }' > "$FILTERED_REPOS_FILE"
else
    # 如果包含复制仓库，则使用所有仓库
    cut -d'|' -f2,3 "$REPO_MAP_FILE" > "$FILTERED_REPOS_FILE"
fi

# 调试：显示过滤后的仓库
if [ "$VERBOSE" = true ]; then
    echo "过滤后的仓库："
    cat "$FILTERED_REPOS_FILE"
    echo ""
fi

# 显示过滤结果
if [ "$INCLUDE_COPIES" = false ] && [ "$VERBOSE" = true ]; then
    original_count=$(wc -l < "$REPO_MAP_FILE")
    filtered_count=$(wc -l < "$FILTERED_REPOS_FILE")
    skipped_count=$((original_count - filtered_count))
    
    if [ $skipped_count -gt 0 ]; then
        echo "已跳过 $skipped_count 个复制仓库，保留 $filtered_count 个主仓库"
    else
        echo "未发现复制仓库，保留所有 $filtered_count 个仓库"
    fi
fi

# 查找所有git仓库并收集日志
while IFS='|' read -r repo_path repo_name; do
    [ -z "$repo_path" ] && continue
    
    cd "$repo_path" || continue
    
    if [ "$VERBOSE" = true ]; then
        echo "正在处理仓库: $repo_name"
    fi
    
    # 直接获取指定时间范围内的所有提交，不做预检查
    commit_count=0
    
    # 获取所有分支的提交哈希值
    git log --all --since="$SINCE_DATE 00:00:00" --until="$(date +%Y-%m-%d) 23:59:59" --format="%H" 2>/dev/null | while read -r commit_hash; do
        if [ -n "$commit_hash" ]; then
            # 获取提交日期
            commit_date=$(git log -1 --format="%ad" --date=short "$commit_hash" 2>/dev/null)
            
            if [ -n "$commit_date" ]; then
                # 获取完整的提交消息（包括多行）
                commit_message=$(git log -1 --format="%B" "$commit_hash" 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                
                # 确保消息不为空
                if [ -n "$commit_message" ] && [ "$commit_message" != " " ]; then
                    # 提取任务/主题
                    topic=$(extract_topic "$commit_message")
                    
                    # 输出格式: date|topic|repo_name|message
                    echo "$commit_date|$topic|$repo_name|$commit_message" >> "$TEMP_FILE"
                    commit_count=$((commit_count + 1))
                fi
            fi
        fi
    done
    
    # 显示处理结果
    if [ "$VERBOSE" = true ]; then
        if [ $commit_count -gt 0 ]; then
            echo "  - 找到 $commit_count 个提交"
        else
            echo "  - 无提交记录"
        fi
    fi
    
    cd - > /dev/null || exit
done < "$FILTERED_REPOS_FILE"

# 清理临时文件
rm "$REPO_MAP_FILE" "$FILTERED_REPOS_FILE"

# 检查是否有数据
if [ ! -s "$TEMP_FILE" ]; then
    echo "在过去 $DAYS 天内没有找到提交记录"
    rm "$TEMP_FILE"
    exit 0
fi

# 去重处理（如果启用）
if [ "$DEDUP" = true ]; then
    DEDUP_FILE=$(mktemp)
    
    if [ "$VERBOSE" = true ]; then
        echo "正在去除重复的提交信息..."
    fi
    
    # 按日期+主题+消息进行去重，保留仓库名最短的记录
    sort "$TEMP_FILE" | \
    awk -F'|' '
    {
        key = $1 "|" $2 "|" $4  # date|topic|message 作为去重的键
        if (!(key in seen) || length($3) < length(repo_names[key])) {
            seen[key] = $0
            repo_names[key] = $3
        }
    }
    END {
        for (key in seen) {
            print seen[key]
        }
    }' > "$DEDUP_FILE"
    
    # 替换原文件
    mv "$DEDUP_FILE" "$TEMP_FILE"
    
    if [ "$VERBOSE" = true ]; then
        dedup_count=$(wc -l < "$TEMP_FILE")
        echo "去重后剩余 $dedup_count 个提交"
    fi
fi

# 统计信息
if [ -s "$TEMP_FILE" ] && [ "$SHOW_SUMMARY" = true ]; then
    total_commits=$(wc -l < "$TEMP_FILE")
    total_repos=$(cut -d'|' -f3 "$TEMP_FILE" | sort -u | wc -l)
    echo ""
    echo "找到 $total_commits 个提交，涉及 $total_repos 个仓库"
    
    # 显示各仓库的提交统计
    echo ""
    echo "各仓库提交统计："
    cut -d'|' -f3 "$TEMP_FILE" | sort | uniq -c | sort -nr | while read -r count repo; do
        echo "  $repo: $count 个提交"
    done
fi

# 按日期排序并格式化输出
{
    echo "# Git 提交日志汇总 (最近 $DAYS 天)"
    echo "生成时间: $(date)"
    if [ "$SHOW_SUMMARY" = true ] && [ -s "$TEMP_FILE" ]; then
        total_commits=$(wc -l < "$TEMP_FILE")
        echo "统计范围: $SINCE_DATE 到 $(date +%Y-%m-%d) (共 $total_commits 个提交)"
    else
        echo "统计范围: $SINCE_DATE 到 $(date +%Y-%m-%d)"
    fi
    echo ""
    
    # 使用临时文件进行数据处理
    SORTED_FILE=$(mktemp)
    sort -r "$TEMP_FILE" > "$SORTED_FILE"
    
    current_date=""
    current_topic=""
    current_repo=""
    date_counter=1
    topic_counter=1
    repo_counter=1
    commit_counter=1
    
    while IFS='|' read -r date topic repo message; do
        # 跳过空行或不完整的行
        if [ -z "$date" ] || [ -z "$message" ] || [ -z "$repo" ] || [ -z "$topic" ]; then
            continue
        fi
        
        # 清理数据
        date=$(echo "$date" | tr -d ' ')
        topic=$(echo "$topic" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        repo=$(echo "$repo" | tr -d ' ')
        message=$(echo "$message" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # 检查是否是新的日期
        if [ "$current_date" != "$date" ]; then
            current_date="$date"
            echo "$date_counter. $current_date"
            date_counter=$((date_counter + 1))
            topic_counter=1
            current_topic=""
            current_repo=""
        fi
        
        # 检查是否是新的任务主题
        if [ "$current_topic" != "$topic" ]; then
            current_topic="$topic"
            echo "    $((date_counter-1)).$topic_counter [$topic]"
            topic_counter=$((topic_counter + 1))
            repo_counter=1
            current_repo=""
        fi
        
        # 检查是否是新的项目
        if [ "$current_repo" != "$repo" ]; then
            current_repo="$repo"
            echo "        $((date_counter-1)).$((topic_counter-1)).$repo_counter $repo"
            repo_counter=$((repo_counter + 1))
            commit_counter=1
        fi
        
        # 输出提交信息（过滤merge信息）
        if [ "$SHOW_MERGE" = true ] || ! is_merge_commit "$message"; then
            echo "            $((date_counter-1)).$((topic_counter-1)).$((repo_counter-1)).$commit_counter $message"
            commit_counter=$((commit_counter + 1))
        fi
        
    done < "$SORTED_FILE"
    
    # 清理临时文件
    rm "$SORTED_FILE"
    
} < "$TEMP_FILE"

# 清理临时文件
rm "$TEMP_FILE"

echo ""
echo "日志汇总完成!"
