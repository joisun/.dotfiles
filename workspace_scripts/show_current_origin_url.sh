#!/bin/bash


echo "当前所有项目的 remote origin URL："
echo "------------------------"
for dir in */; do
    if [ -d "$dir" ] && [ -d "$dir/.git" ]; then
        cd "$dir"
        CURRENT_URL=$(git config --get remote.origin.url)
        if [ -n "$CURRENT_URL" ]; then
            echo "$dir: $CURRENT_URL"
        else
            echo "$dir: 未设置 remote origin"
        fi
        cd ..
    fi
done
echo "------------------------"
