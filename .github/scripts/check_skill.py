#!/usr/bin/env python3
"""校验技能 frontmatter：必须有 name 与 description，且 description 不能为空。"""
import io
import re
import sys
from pathlib import Path

REQUIRED = ("name", "description")


def parse_frontmatter(text: str) -> dict:
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    block = text[3:end]
    data, key, buf = {}, None, []
    for line in block.splitlines():
        m = re.match(r"^([A-Za-z_][\w-]*):\s*(.*)$", line)
        if m:
            if key:
                data[key] = "\n".join(buf).strip()
            key, buf = m.group(1), [m.group(2)]
        elif key and (line.startswith(" ") or not line.strip()):
            buf.append(line.strip())
        elif line and not line.startswith(" "):
            if key:
                data[key] = "\n".join(buf).strip()
            key, buf = None, []
    if key:
        data[key] = "\n".join(buf).strip()
    return data


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    skills = sorted((root / "skills").glob("*/SKILL.md"))
    if not skills:
        print("✗ 未找到任何 skills/*/SKILL.md")
        return 1

    failed = False
    for path in skills:
        rel = path.relative_to(root)
        fm = parse_frontmatter(io.open(path, encoding="utf-8-sig").read())
        missing = [k for k in REQUIRED if not fm.get(k)]
        if missing:
            print(f"✗ {rel}: 缺少 {', '.join(missing)}（缺 name/description 的技能不会被触发）")
            failed = True
            continue
        if fm["name"] != path.parent.name:
            print(f"! {rel}: name={fm['name']} 与目录名 {path.parent.name} 不一致（可触发，但易混淆）")
        if len(fm["description"]) < 30:
            print(f"! {rel}: description 过短（{len(fm['description'])} 字符），触发命中率会偏低")
        print(f"✓ {rel}: name={fm['name']}, description {len(fm['description'])} 字符")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
