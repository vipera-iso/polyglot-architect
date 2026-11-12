# Polyglot Architect — 简体中文

**评估任意代码库。逐个组件决定应使用哪种语言。生成可验证的迁移路线图——而非语言热度排行榜。**

## 安装

```bash
git clone https://github.com/vipera-iso/polyglot-architect.git \
  ~/.claude/skills/polyglot-architect
chmod +x ~/.claude/skills/polyglot-architect/scripts/*.sh
```

## 使用

```text
/polyglot-architect
评估这个仓库。哪些部分应该用其他语言重写，哪些应保持不变，为什么？给我决策表和路线图。
```

## 你将收到

7 部分报告：
1. 组件映射 — 单元列表 + 边界
2. 热力图 — 冷/温/热百分比 + 性能分析证据
3. 决策表 — SWAP / BIND / CONSIDER / KEEP
4. 接缝规格 — 每个 SWAP 和 BIND
5. KEEP 列表 — 保留的部分及原因
6. 路线图 — Phase 1/2/3 + 指标 + 影子模式
7. 自我批评 — 反炒作检查

**"不迁移"是有效且常见的结论。** 大多数单元应保持 KEEP。

完整文档见 [README.md](../../README.md)。
