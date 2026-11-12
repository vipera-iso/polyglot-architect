# Polyglot Architect — Tiếng Việt

**Đánh giá bất kỳ codebase nào. Quyết định từng thành phần nên dùng ngôn ngữ nào. Đưa ra lộ trình migration có thể kiểm chứng — không phải bảng xếp hạng ngôn ngữ.**

## Cài đặt

```bash
git clone https://github.com/vipera-iso/polyglot-architect.git \
  ~/.claude/skills/polyglot-architect
chmod +x ~/.claude/skills/polyglot-architect/scripts/*.sh
```

## Dùng

```text
/polyglot-architect
Đánh giá repo này. Phần nào nên viết lại bằng ngôn ngữ khác, phần nào giữ nguyên, tại sao? Cho tôi bảng quyết định và lộ trình.
```

## Bạn sẽ nhận được

Báo cáo 7 phần:
1. Component map — danh sách unit + ranh giới
2. Heat map — % cold/warm/hot + bằng chứng profiling
3. Decision table — SWAP / BIND / CONSIDER / KEEP
4. Seam specs — cho mọi SWAP và BIND
5. KEEP list — phần giữ nguyên và lý do
6. Roadmap — Phase 1/2/3 với metric + shadow mode
7. Self-critique — tự kiểm tra anti-hype

**"Không migrate" là kết luận hợp lệ và phổ biến.** Đa số unit sẽ là KEEP.

Xem [README.md](../../README.md) để biết đầy đủ.
