# Skill 03: 收敛评估

> **触发**: Phase 03 指示  
> **目标**: 评估当前模块划分是否已收敛  
> **预计耗时**: 15–30 分钟

---

## 输入

- 所有模块的 L1 报告（含复杂度评级，来自 P2）
- [收敛条件与迭代控制](../definitions/convergence_criteria.md)

## 输出

| 产出物 | 路径 | 必须 |
|---|---|---|
| 收敛结论 | 写入总体报告或迭代日志 | ✅ |
| 再入列表（未收敛时） | 同上 | 条件必须 |

---

## 核心任务

### 任务 0: 自动化验证门禁（硬门禁，必须首先执行）

本任务运行自动化脚本进行程序化验证。**脚本检测到的违规不可通过主观推理绕过**——任何 VIOLATION 或 MISSING 均直接导致「未收敛」判定。

#### Check A — 地板规则合规性

验证所有模块的最终评级是否符合客观指标地板规则。阈值从 `engineering_metadata.md` 动态读取。

```bash
echo "=== 地板规则合规性检查 ==="
FLOOR_VIOLATIONS=0

# 从 engineering_metadata.md 读取动态阈值
META="docs/codearch/engineering_metadata.md"
FLOOR_HIGH=$(grep -oP '地板阈值_高\s*\|\s*\K[0-9]+' "$META" 2>/dev/null | head -1)
if [ -z "$FLOOR_HIGH" ]; then
  echo "WARNING: 无法从 $META 读取地板阈值_高，使用默认值 3000"
  FLOOR_HIGH=3000
fi
echo "地板阈值_高 = $FLOOR_HIGH"

for f in docs/codearch/modules/*.md; do
  module=$(basename "$f" .md)
  # 提取代码行数（匹配 "代码行数 | NNN" 格式）
  lines=$(grep -oP '代码行数\s*\|\s*\K[0-9,]+' "$f" 2>/dev/null | tr -d ',' | head -1)
  # 提取评级（匹配 "等级: X" 或 "等级**: X" 格式）
  rating=$(grep -oP '\*{0,2}等级\*{0,2}\s*[:：]\s*\K(低|中|高|极高)' "$f" 2>/dev/null | head -1)
  # 提取密度信号触发数（匹配 "密度高信号数 | N" 格式）
  density_signals=$(grep -oP '密度高信号数\s*\|\s*\K[0-9]+' "$f" 2>/dev/null | head -1)

  # Check 1: 代码行数地板
  if [ -n "$lines" ] && [ "$lines" -gt "$FLOOR_HIGH" ]; then
    if [ "$rating" = "低" ] || [ "$rating" = "中" ]; then
      echo "VIOLATION: $module ($lines lines > 地板阈值_高 $FLOOR_HIGH, rated '$rating', minimum: 高)"
      FLOOR_VIOLATIONS=$((FLOOR_VIOLATIONS + 1))
    fi
  fi

  # Check 2: 密度信号地板
  if [ -n "$density_signals" ] && [ "$density_signals" -ge 3 ]; then
    if [ "$rating" = "低" ] || [ "$rating" = "中" ]; then
      echo "VIOLATION: $module (密度高信号数=$density_signals >= 3, rated '$rating', minimum: 高)"
      FLOOR_VIOLATIONS=$((FLOOR_VIOLATIONS + 1))
    fi
  fi
done
echo "地板规则违规数: $FLOOR_VIOLATIONS"
```

#### Check B — 已拆报告存在性

验证所有声称「已拆」的模块，其子模块报告文件是否实际存在。

```bash
echo "=== 已拆报告存在性检查 ==="
MISSING_REPORTS=0
for f in docs/codearch/modules/*.md; do
  module=$(basename "$f" .md)
  if grep -q '结论.*已拆' "$f" 2>/dev/null; then
    # 提取子模块名列表
    subs=$(grep '已拆' "$f" | grep -oP '子模块[：:]\s*\K[^)]+' | tr '、,/' '\n')
    while IFS= read -r sub; do
      sub=$(echo "$sub" | xargs)
      [ -z "$sub" ] && continue
      found=0
      [ -f "docs/codearch/modules/${sub}.md" ] && found=1
      [ -f "docs/codearch/modules/${module}-${sub}.md" ] && found=1
      if [ $found -eq 0 ]; then
        echo "MISSING: $module claims sub-module '$sub' but no report found"
        MISSING_REPORTS=$((MISSING_REPORTS + 1))
      fi
    done <<< "$subs"
  fi
done
echo "缺失子模块报告数: $MISSING_REPORTS"
```

#### 门禁判定

- 若 `FLOOR_VIOLATIONS > 0` 或 `MISSING_REPORTS > 0`，**直接判定「未收敛」**，产出再入列表：
  - 地板规则违规的模块 → 重入 P2 重新评级
  - 子模块报告缺失的模块 → 重入 P1 生成缺失报告
- 门禁通过后，继续执行后续任务。

---

### 任务 1: 叶子模块收敛检查

逐个检查所有叶子模块的收敛状态：

| 情况 | 判定 |
| ---- | ---- |
| 复杂度 ≤ 中，且代码行数 ≤ **地板阈值_高** 且密度高信号数 < 3（或有充分豁免理由） | ✅ 已收敛 |
| 复杂度 ≤ 中，但代码行数 > **地板阈值_高** 或密度高信号数 ≥ 3 且无豁免 | ❌ 评级疑似偏低（应由任务 0 Check A 已拦截） |
| 复杂度 高/极高，拆分状态为「已拆」且子模块报告已验证存在 | ✅ 已收敛（子模块成为新的叶子节点） |
| 复杂度 高/极高，拆分状态为「不拆」且理由合格 | ✅ 已收敛 |
| 复杂度 高/极高，拆分状态为「待拆」或无拆分说明 | ❌ 未收敛，加入再入列表 |
| 复杂度 高/极高，「不拆」理由不合格 | ❌ 未收敛 |

```bash
# 检查所有 高/极高 模块的拆分状态
for f in docs/codearch/modules/*.md; do
  if grep -q "等级.*高\|等级.*极高" "$f" 2>/dev/null; then
    module=$(basename "$f" .md)
    echo "=== $module ==="
    grep "已拆\|不拆\|待拆" "$f" 2>/dev/null || echo "NO SPLIT STATUS"
  fi
done
```

### 任务 2: 评级交叉验证（反偷懒检查）

结合任务 0 的自动化脚本输出，对照客观指标复核 P2 评级，防止模型系统性低估复杂度：

- **首先检查任务 0 Check A 的输出**：若存在地板规则违规，直接将对应模块加入再入列表（无需人工复核）
- 在脚本结果基础上，进一步逐个检查所有评级为 低/中 的模块，核实其客观指标（代码行数、依赖数量、外部依赖类型）是否与评级一致
- 重点关注以下情形：
  - 代码行数 > **拆分评估阈值**但评级为 中（且无充分的信息密度论证）
  - 维度 F 密度高信号数 ≥ 2 但评级为 低/中
  - 存在线程/并发机制但评级为 低/中
  - 存在硬件/SDK 依赖但评级 < 极高
- 若发现评级偏低的模块，加入再入列表，标注需重新进入 P2 评级

### 任务 3: 粒度一致性检查

对比同一层级模块的规模，发现粒度不一致的情况：

- 同层级模块之间，若某模块体量是其兄弟模块的 5 倍以上，标记为可能需要进一步分解
- 若某模块非常小（< 200 行），标记为可能需与兄弟模块合并

### 任务 4: 索引一致性检查

验证总体报告中的模块索引与实际文件一一对应：

```bash
# 检查索引引用的文件是否都存在
grep -oE 'modules/[^)]+\.md' docs/codearch/overall_report.md | sort -u | while read p; do
  [ -f "docs/codearch/$p" ] && echo "OK $p" || echo "MISSING $p"
done

# 检查实际文件是否都已编入索引
for f in docs/codearch/modules/*.md; do
  p="modules/$(basename $f)"
  grep -q "$p" docs/codearch/overall_report.md && echo "INDEXED $p" || echo "UNINDEXED $p"
done
```

### 任务 5: 产出收敛结论

根据任务 0–4 的检查结果，产出最终结论：

- **任务 0 未通过** → 直接结论：「未收敛（自动化门禁未通过）」，产出再入列表
- **任务 0 通过，且任务 1–4 全部通过** → 结论：「已收敛」
- **任务 0 通过，但任务 1–4 任一项未通过** → 产出再入列表：

| 模块 | 问题 | 处置 |
| ---- | ---- | ---- |
| … | 地板规则违规 / 子模块报告缺失 / 待拆 / 评级偏低 / 粒度不一致 / 索引缺失 / … | 重入 P2 / 重入 P1 |

- 按 [convergence_criteria](../definitions/convergence_criteria.md) 记录迭代历史
- 检查迭代轮数：若已达最大轮数（3 轮），强制收敛并标注「已达迭代上限」

---

## 验收标准

- [ ] 任务 0 的自动化脚本已执行，输出已记录
- [ ] 任务 1–4 的检查均已执行并记录结果
- [ ] 产出明确的收敛结论（「已收敛」或「未收敛」+ 再入列表）
- [ ] 迭代历史已记录

---

## 注意事项

| 类别 | 说明 |
|---|---|
| **DO** | 逐项检查每个维度，记录检查证据 |
| **DO** | 对照客观指标复核评级，不放过偷懒式低评 |
| **DON'T** | 不要仅凭模块数量判断收敛——质量优先 |
| **DON'T** | 不要跳过「不拆」理由的合格性审查 |

---

## 跳转

| 结果 | 下一步 |
|---|---|
| 已收敛 | → Phase 03 验收 → P4（深度分析） |
| 未收敛 | → Phase 03 → P1，携带再入列表 |
