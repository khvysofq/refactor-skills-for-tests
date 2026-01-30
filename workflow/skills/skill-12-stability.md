# Skill 12: 稳定性治理

> **触发条件**：门禁判定为 G3 Flaky，或表征测试不稳定  
> **目标**：消除测试中的非确定性，确保测试可重复

---

## 输入

- 不稳定测试的表现
- 相关代码和测试

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 稳定化后的测试 | 原测试位置 | ✓ |
| 稳定性措施记录 | 模块卡片 | ✓ |

---

## 核心任务

### 任务 1: 识别不稳定来源

**常见不稳定来源**：

| 来源 | 症状 | 检测方法 |
|------|------|----------|
| 时间依赖 | 超时/时间断言失败 | 检查 time/clock/sleep |
| 随机数 | 随机断言失败 | 检查 rand/random |
| 并发竞争 | 偶发失败/死锁 | TSAN, 多次运行 |
| 顺序依赖 | 单独跑过批量跑失败 | 打乱测试顺序 |
| 资源泄漏 | 后面的测试失败 | 检查 setup/teardown |
| 外部依赖 | 网络/文件系统不稳定 | 检查 I/O 操作 |
| 浮点精度 | 近似值断言失败 | 检查浮点比较 |

**诊断流程**：

1. **复现不稳定**：`for i in {1..50}; do ./run_tests --gtest_filter="*Flaky*" || echo "Fail: $i"; done`
2. **收集信息**：失败频率、失败模式、错误消息
3. **分类**：根据症状匹配上表

### 任务 2: 时间依赖治理

**问题**：测试依赖系统时间或 sleep

**解决方案**：

```cpp
// 问题代码
void Service::process() {
    auto start = std::time(nullptr);
    doWork();
    auto elapsed = std::time(nullptr) - start;
    if (elapsed > 10) {
        log("slow");
    }
}

// 解决方案：注入时钟
class Service {
public:
    explicit Service(IClock* clock = nullptr) 
        : clock_(clock ? clock : &system_clock_) {}
    
    void process() {
        auto start = clock_->now();
        doWork();
        auto elapsed = clock_->now() - start;
        // ...
    }
private:
    IClock* clock_;
    static SystemClock system_clock_;
};

// 测试中使用 FakeClock
TEST(Service, LogsSlowOperation) {
    FakeClock clock;
    Service service(&clock);
    
    // 模拟慢操作
    clock.advance(15);  // 前进 15 秒
    
    service.process();
    // 断言日志
}
```

### 任务 3: 随机数治理

**问题**：测试结果依赖随机数

**解决方案**：

```cpp
// 问题代码
std::string generateId() {
    return std::to_string(std::rand());
}

// 解决方案 1：固定种子
TEST(Generator, ProducesConsistentId) {
    std::srand(42);  // 固定种子
    auto id1 = generateId();
    
    std::srand(42);  // 重置
    auto id2 = generateId();
    
    EXPECT_EQ(id1, id2);
}

// 解决方案 2：注入 RNG
class IRandomGenerator {
public:
    virtual int next() = 0;
};

class Generator {
public:
    explicit Generator(IRandomGenerator* rng) : rng_(rng) {}
    std::string generateId() {
        return std::to_string(rng_->next());
    }
};

// 测试中使用固定序列
class FixedRng : public IRandomGenerator {
    std::vector<int> values_;
    size_t index_ = 0;
public:
    explicit FixedRng(std::vector<int> values) : values_(std::move(values)) {}
    int next() override { return values_[index_++]; }
};
```

### 任务 4: 并发竞争治理

**问题**：测试涉及多线程，结果不确定

**解决方案**：

```cpp
// 问题：竞态条件
TEST(Counter, ConcurrentIncrement) {
    Counter counter;
    std::thread t1([&]{ for(int i=0; i<1000; i++) counter.inc(); });
    std::thread t2([&]{ for(int i=0; i<1000; i++) counter.inc(); });
    t1.join(); t2.join();
    EXPECT_EQ(counter.value(), 2000);  // 可能失败！
}

// 解决方案 1：使用同步原语
TEST(Counter, ConcurrentIncrementWithSync) {
    Counter counter;  // 假设 Counter 内部已正确同步
    // 使用 barrier 或 latch 确保确定性启动
    std::latch ready(2);
    std::thread t1([&]{ ready.wait(); for(int i=0; i<1000; i++) counter.inc(); });
    std::thread t2([&]{ ready.wait(); for(int i=0; i<1000; i++) counter.inc(); });
    t1.join(); t2.join();
    EXPECT_EQ(counter.value(), 2000);
}

// 解决方案 2：单线程测试核心逻辑
// 并发正确性用专门的并发测试，核心逻辑用单线程测试

// 解决方案 3：使用确定性调度器
class DeterministicExecutor {
    // 按固定顺序执行任务
};
```

### 任务 5: 外部依赖隔离

**问题**：测试依赖外部资源

**解决方案**：

| 依赖 | 隔离方法 |
|------|----------|
| 文件系统 | 使用临时目录 + 清理 |
| 网络 | 使用 loopback / mock server |
| 数据库 | 使用 in-memory DB |
| 环境变量 | 保存/恢复 |

**文件系统隔离示例**：

```cpp
class TempDirTest : public ::testing::Test {
protected:
    std::string temp_dir_;
    
    void SetUp() override {
        temp_dir_ = std::filesystem::temp_directory_path() / 
                    ("test_" + std::to_string(std::rand()));
        std::filesystem::create_directories(temp_dir_);
    }
    
    void TearDown() override {
        std::filesystem::remove_all(temp_dir_);
    }
};

TEST_F(TempDirTest, WritesFile) {
    std::string path = temp_dir_ + "/output.txt";
    writeFile(path, "content");
    EXPECT_TRUE(std::filesystem::exists(path));
}
```

### 任务 6: 验证稳定性

**验证方法**：

```bash
# 运行 50 次
PASS=0
FAIL=0
for i in {1..50}; do
    if ./run_tests --gtest_filter="*PreviouslyFlaky*" > /dev/null 2>&1; then
        ((PASS++))
    else
        ((FAIL++))
    fi
done

echo "Results: $PASS passed, $FAIL failed"

# 目标：50/50 通过
if [ $FAIL -eq 0 ]; then
    echo "STABLE"
else
    echo "STILL FLAKY"
fi
```

---

## 稳定性措施速查表

| 问题 | 措施 |
|------|------|
| 时间 | IClock 接口 + FakeClock |
| 随机 | IRng 接口 + 固定种子/序列 |
| 并发 | 同步原语 / 单线程测试 / 确定性调度 |
| 文件 | 临时目录 + 清理 |
| 网络 | Loopback + Mock Server |
| 顺序依赖 | 确保测试独立性 |
| 浮点 | EXPECT_NEAR / approx |

---

## 验收标准

### 必须满足

- [ ] 不稳定来源已识别
- [ ] 稳定化措施已实施
- [ ] 连续运行 50 次无失败
- [ ] 措施记录在模块卡片中

### 验收检查

```bash
# 稳定性验证
for i in {1..50}; do 
    ./run_tests --gtest_filter="*<Module>*" || exit 1
done
echo "STABILITY: PASS"
```

---

## 应该做

- ✓ 先诊断再修复
- ✓ 选择最小侵入性的方案
- ✓ 记录稳定化措施
- ✓ 验证足够次数（≥50）

## 不应该做

- ✗ 通过增加 retry 掩盖问题
- ✗ 使用过长的 sleep 等待
- ✗ 跳过不稳定测试
- ✗ 验证次数不够就宣布稳定

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过（从 Skill 05 进入） | 继续 [Skill 05](skill-05-characterization.md) |
| 通过（从 Skill 08 进入） | 继续 [Skill 08](skill-08-refactor.md) |
| 未通过 - 可继续治理 | 继续分析和治理 |
| 未通过 - 无法解决 | [Skill 10: 人工介入](skill-10-human-input.md) |

---

## 时间预估

| 问题复杂度 | 预估时间 |
|------------|----------|
| 简单（单一来源） | 30 分钟 - 1 小时 |
| 中等（多个来源） | 1 - 2 小时 |
| 复杂（并发问题） | 2 - 4 小时 |

---

**完成后**：返回触发此 Skill 的位置继续执行
