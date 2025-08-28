#!/bin/bash

# 目标前缀
NEW_PREFIX="git@codeup.aliyun.com:5fae220a2f8cc15c287b498a/iot/"

echo "开始更新并验证 remote origin URL..."
echo "------------------------"
for dir in */; do
    if [ -d "$dir" ] && [ -d "$dir/.git" ]; then
        echo "处理项目: $dir"
        cd "$dir"
        
        CURRENT_URL=$(git config --get remote.origin.url)
        
        if [ -n "$CURRENT_URL" ]; then
            PROJECT_NAME=$(basename "$CURRENT_URL" .git)
            NEW_URL="${NEW_PREFIX}${PROJECT_NAME}.git"
            
            echo "旧 URL: $CURRENT_URL"
            echo "新 URL: $NEW_URL"
            
            # 更新 URL
            git remote set-url origin "$NEW_URL"
            
            # 验证步骤
            echo -n "验证中... "
            
            # 方法1：检查 git ls-remote 是否成功
            if git ls-remote --exit-code "$NEW_URL" >/dev/null 2>&1; then
                echo "✅ 验证成功 - 远程仓库可访问"
            else
                echo "❌ 验证失败 - 可能无法访问远程仓库"
                # 可选：回滚到原始 URL
                # git remote set-url origin "$CURRENT_URL"
                # echo "已回滚到原始 URL"
            fi
            
        else
            echo "无法获取 remote origin url"
        fi
        
        cd ..
        echo "------------------------"
    fi
done
