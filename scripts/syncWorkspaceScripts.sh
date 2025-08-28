#!/bin/bash

echo "Sync workspace/scripts*.sh"


for f in $DOTFILES/workspace_scripts/*.sh; do
  filename=$(basename $f)
  target=$WORKSPACE/$filename

  ln -sf $f $target
  echo "✅ $target -> $f"
done
