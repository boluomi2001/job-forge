#!/usr/bin/env python3
"""校验换行与编码约定。

- .sh 必须纯 LF：Windows 上被写成 CRLF 会让 Linux/macOS 报 `syntax error near '\\r'`
- .ps1 必须带 UTF-8 BOM：Windows PowerShell 5.1 会把无 BOM 的 UTF-8 当 ANSI 解析，
  中文注释/字符串会破坏引号配对，报"字符串缺少终止符"
- .ps1 的 CRLF 由 .gitattributes 在检出时生成，因此这里不强制工作区换行形态
"""
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[2]
failed = False


def check_sh(p: Path) -> bool:
    data = p.read_bytes()
    if b"\r\n" in data:
        print(f"✗ {p.relative_to(root)}: 含 CRLF（shell 脚本必须用 LF）")
        return False
    print(f"✓ {p.relative_to(root)}: LF")
    return True


def check_ps1(p: Path) -> bool:
    data = p.read_bytes()
    if not data.startswith(b"\xef\xbb\xbf"):
        print(f"✗ {p.relative_to(root)}: 缺少 UTF-8 BOM（Windows PowerShell 5.1 解析中文会失败）")
        return False
    form = "CRLF" if b"\r\n" in data else "LF"
    print(f"✓ {p.relative_to(root)}: BOM, 工作区换行 {form}")
    return True


for sh in sorted(root.glob("scripts/*.sh")):
    failed |= not check_sh(sh)

for ps in sorted(root.glob("scripts/*.ps1")):
    failed |= not check_ps1(ps)

sys.exit(1 if failed else 0)
