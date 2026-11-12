#!/bin/bash
# Claude Code status line: folder, git branch, model, context used
input=$(cat)
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)

out=$(printf '\033[34m%s\033[0m' "$(basename "$dir")")
[ -n "$branch" ] && out="$out $(printf '\033[32m(%s)\033[0m' "$branch")"
out="$out $(printf '\033[36m%s\033[0m' "$model")"
[ -n "$used" ] && out="$out $(printf 'ctx:%.0f%%' "$used")"
echo "$out"
