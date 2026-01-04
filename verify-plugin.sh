#!/bin/bash

echo "🔍 Flutter Skills Plugin 验证脚本"
echo "=================================="
echo ""

# 验证 JSON 格式
echo "1️⃣ 验证 JSON 配置文件..."
if python3 -m json.tool .claude-plugin/marketplace.json > /dev/null 2>&1; then
  echo "   ✅ marketplace.json 格式正确"
else
  echo "   ❌ marketplace.json 格式错误"
  exit 1
fi

if python3 -m json.tool plugins/flutter-skills/.claude-plugin/plugin.json > /dev/null 2>&1; then
  echo "   ✅ plugin.json 格式正确"
else
  echo "   ❌ plugin.json 格式错误"
  exit 1
fi

echo ""

# 验证文件存在
echo "2️⃣ 验证必需文件..."
files=(
  "plugins/flutter-skills/.claude-plugin/plugin.json"
  "plugins/flutter-skills/commands/flutter-review.md"
  "plugins/flutter-skills/commands/flutter-format.md"
  "plugins/flutter-skills/agents/flutter-review.md"
  "plugins/flutter-skills/skills/flutter-review/SKILL.md"
  "plugins/flutter-skills/skills/flutter-format/SKILL.md"
)

all_exist=true
for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo "   ✅ $file"
  else
    echo "   ❌ $file 不存在"
    all_exist=false
  fi
done

if [ "$all_exist" = false ]; then
  exit 1
fi

echo ""

# 验证插件元数据
echo "3️⃣ 验证插件元数据..."
plugin_name=$(python3 -c "import json; print(json.load(open('plugins/flutter-skills/.claude-plugin/plugin.json'))['name'])")
marketplace_name=$(python3 -c "import json; print(json.load(open('.claude-plugin/marketplace.json'))['name'])")

echo "   插件名称: $plugin_name"
echo "   市场名称: $marketplace_name"
echo "   ✅ 元数据验证通过"

echo ""
echo "=================================="
echo "✨ 所有验证通过!"
echo ""
echo "📝 下一步操作:"
echo "1. 在此目录启动 Claude Code: claude"
echo "2. 添加本地市场: /plugin marketplace add ."
echo "3. 安装插件: /plugin install flutter-skills@$marketplace_name"
echo "4. 测试命令: /flutter-skills:flutter-review"
echo ""
