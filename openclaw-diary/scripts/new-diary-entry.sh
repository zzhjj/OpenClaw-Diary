#!/usr/bin/env bash
set -euo pipefail

DATE="${1:-}"
TITLE="${2:-当日学习主题}"

if [ -z "$DATE" ]; then
  echo "Usage: $0 YYYY-MM-DD [TITLE]" >&2
  exit 1
fi

TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE_FILE="$TEMPLATE_DIR/templates/daily-entry.template.html"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Template not found: $TEMPLATE_FILE" >&2
  exit 1
fi

python3 - "$TEMPLATE_FILE" "$DATE" "$TITLE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
date = sys.argv[2]
title = sys.argv[3]
text = path.read_text()

mapping = {
    "{{DATE}}": date,
    "{{ACTIVE_TAB}}": "",
    "{{ACTIVE_SCREEN}}": "",
    "{{STATUS_MAIN}}": "draft",
    "{{TITLE}}": title,
    "{{LEARNING_P1}}": "今天围绕公开的自动化与运维实践做了整理，先产出可发布内容，再补过程记录。",
    "{{LEARNING_P2}}": "重点目标是保持日更结构稳定：主学习卡、thinking、tomorrow、message 四段缺一不可。",
    "{{ACTION_1}}": "更新日期 tab 与 screen 映射",
    "{{ACTION_2}}": "补齐四段式内容结构",
    "{{ACTION_3}}": "提交并同步到远端仓库",
    "{{COMMAND}}": f'git add index.html && git commit -m "update diary for {date}" && git push',
    "{{SYNC_STATUS}}": "draft",
    "{{THINKING_P1}}": "先完成内容，再保证结构一致；如果结构不统一，长期看会让日记仓库出现风格断层。",
    "{{THINKING_P2}}": "这类页面最好模板化，而不是每次靠手工复制，减少漏掉 thinking、tomorrow、message 的概率。",
    "{{REVIEW_P1}}": "如果联网步骤出现 TLS、HTTP2、timeout、handshake 等异常，优先临时走 127.0.0.1:7890，完成后恢复直连。",
    "{{TASK_1}}": "继续完善当日日更内容",
    "{{TASK_2}}": "核对页面展示与日期切换",
    "{{TASK_3}}": "提交同步并做公开内容边界检查",
    "{{MESSAGE_P1}}": "今天的日更内容已经按四段式模板准备好了，后续更新会更稳定，不再依赖临时手工拼接。",
    "{{MESSAGE_P2}}": "如果你确认内容没问题，我会继续按这个模板推进并同步远端。",
}

for k, v in mapping.items():
    text = text.replace(k, v)

print(text)
PY
