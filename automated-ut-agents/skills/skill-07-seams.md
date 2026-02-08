# Skill 07: 设计 Seam 与依赖分离

> **触发条件**：Skill 04 评估结果为 S3，或 Skill 05 完成后  
> **目标**：把不可测模块变成可测模块，降低副作用与耦合

---

## 输入

- Skill 04 产出的模块卡片（含 Seam 候选点）
- 如有：Skill 05 的表征测试（作为重构护栏）

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| Seam 接口 | `include/<module>/interfaces/` | ✓ |
| 默认实现 | `src/<module>/impl/` | ✓ |
| 测试替身 | `tests/fakes/` | ✓ |
| 更新的模块卡片 | `docs/testing/modules/<module>.md` | ✓ |

---

## 核心任务

### 任务 1: 识别需要分离的依赖

**从模块卡片的外部依赖列表中筛选**：

| 优先级 | 需要分离的依赖类型 |
|--------|-------------------|
| 高（必须分离） | 文件系统操作、网络操作、时间/时钟、随机数生成 |
| 中（推荐分离） | 数据库操作、外部服务调用、系统调用 |
| 低（可选） | 日志（除非需要验证日志内容）、配置（除非配置逻辑复杂） |

### 任务 2: 设计 Seam 接口

**设计原则**：

1. **最小接口原则**：只暴露需要的方法
2. **抽象正确的层次**：不要过于具体或过于抽象
3. **接口名称反映职责而非实现**
4. **考虑测试替身的实现难度**

**常见 Seam 模式**：

#### 时钟接口

```cpp
// include/interfaces/clock.h
class IClock {
public:
    virtual ~IClock() = default;
    virtual std::time_t now() const = 0;
    virtual void sleep(int milliseconds) = 0;
};

// src/impl/system_clock.cpp
class SystemClock : public IClock {
public:
    std::time_t now() const override {
        return std::time(nullptr);
    }
    void sleep(int ms) override {
        std::this_thread::sleep_for(std::chrono::milliseconds(ms));
    }
};

// tests/fakes/fake_clock.h
class FakeClock : public IClock {
public:
    explicit FakeClock(std::time_t initial = 0) : current_(initial) {}
    
    std::time_t now() const override { return current_; }
    void sleep(int ms) override { current_ += ms / 1000; }
    
    void advance(int seconds) { current_ += seconds; }
    void set(std::time_t t) { current_ = t; }
    
private:
    std::time_t current_;
};
```

#### 文件系统接口

```cpp
// include/interfaces/filesystem.h
class IFileSystem {
public:
    virtual ~IFileSystem() = default;
    virtual std::string read(const std::string& path) = 0;
    virtual void write(const std::string& path, const std::string& content) = 0;
    virtual bool exists(const std::string& path) = 0;
};

// tests/fakes/fake_filesystem.h
class FakeFileSystem : public IFileSystem {
public:
    std::string read(const std::string& path) override {
        if (files_.count(path) == 0) throw std::runtime_error("File not found");
        return files_[path];
    }
    
    void write(const std::string& path, const std::string& content) override {
        files_[path] = content;
    }
    
    bool exists(const std::string& path) override {
        return files_.count(path) > 0;
    }
    
    // 测试辅助
    void setFile(const std::string& path, const std::string& content) {
        files_[path] = content;
    }
    
private:
    std::map<std::string, std::string> files_;
};
```

#### 网络接口

```cpp
// include/interfaces/http_client.h
class IHttpClient {
public:
    virtual ~IHttpClient() = default;
    
    struct Response {
        int status_code;
        std::string body;
    };
    
    virtual Response get(const std::string& url) = 0;
    virtual Response post(const std::string& url, const std::string& body) = 0;
};
```

### 任务 3: 实施依赖注入

**注入方式选择**：

| 方式 | 适用场景 | 示例 |
|------|----------|------|
| 构造注入 | 依赖在对象生命周期内不变 | `Service(IClock* clock)` |
| 方法注入 | 依赖按调用变化 | `process(IReader* reader)` |
| 属性注入 | 可选依赖 | `void setClock(IClock*)` |
| 工厂注入 | 需要多次创建依赖 | `Service(IFactory* factory)` |

**实施步骤**：

1. 添加接口头文件
2. 创建默认实现（包装现有逻辑）
3. 修改类构造函数接受接口指针/引用
4. 提供默认参数或工厂方法（保持后向兼容）
5. 创建测试替身
6. 运行现有测试/表征测试验证行为不变

**修改示例**：

```cpp
// 修改前
class Service {
public:
    void process() {
        auto now = std::time(nullptr);  // 直接调用
        // ...
    }
};

// 修改后
class Service {
public:
    // 新构造函数
    explicit Service(IClock* clock = nullptr) 
        : clock_(clock ? clock : &default_clock_) {}
    
    void process() {
        auto now = clock_->now();  // 通过接口调用
        // ...
    }
    
private:
    IClock* clock_;
    static SystemClock default_clock_;  // 保持默认行为
};
```

### 任务 4: 验证行为不变

**验证方法**：

```bash
# 1. 运行表征测试（如果有）
./run_tests --gtest_filter="*GoldenTest*"

# 2. 运行现有单元测试
./run_tests --gtest_filter="*<Module>*"

# 3. 运行完整门禁
./tools/test.sh
```

**如果行为变化**：
- 检查接口实现是否正确
- 检查默认值是否等价
- 如果是预期变化，更新 Golden 数据

---

## 常见 Seam 模式速查

### 全局状态 → Context 对象

```cpp
// 修改前
static Config g_config;

void process() {
    if (g_config.debug) { ... }
}

// 修改后
struct Context {
    Config config;
    IClock* clock;
    ILogger* logger;
};

void process(const Context& ctx) {
    if (ctx.config.debug) { ... }
}
```

### 单例 → 可注入单例

```cpp
// 修改前
class Logger {
    static Logger& instance();
};

// 修改后
class Logger {
    static Logger& instance() {
        return current_ ? *current_ : default_;
    }
    
    // 测试专用
    static void setInstance(Logger* logger) {
        current_ = logger;
    }
    
    static void resetInstance() {
        current_ = nullptr;
    }
    
private:
    static Logger* current_;
    static Logger default_;
};
```

### 硬编码路径 → 配置化

```cpp
// 修改前
std::ifstream file("/etc/app/config.json");

// 修改后
std::ifstream file(config.config_path);  // 测试时可指定临时目录
```

---

## 验收标准

### 必须满足

- [ ] Seam 接口已定义
- [ ] 默认实现保持原有行为
- [ ] 测试替身已创建
- [ ] 依赖可在测试中替换
- [ ] 所有现有测试/表征测试通过

### 验收检查

```bash
# 接口存在
ls include/*/interfaces/*.h && echo "PASS" || echo "FAIL"

# 测试替身存在
ls tests/fakes/*.h && echo "PASS" || echo "FAIL"

# 测试通过
./tools/test.sh && echo "PASS" || echo "FAIL"
```

---

## 应该做

- ✓ 小步修改，每步验证
- ✓ 保持后向兼容（默认参数）
- ✓ 接口设计简洁
- ✓ 测试替身易于使用

## 不应该做

- ✗ 一次性重构所有依赖
- ✗ 破坏现有 API
- ✗ 过度设计接口
- ✗ 跳过验证步骤

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | [Skill 08: 小步重构](skill-08-refactor.md) |
| 未通过 - 行为变化 | [Skill 09: 行为差异判定](skill-09-behavior-drift.md) |
| 未通过 - 测试不稳定 | [Skill 12: 稳定性治理](skill-12-stability.md) |
| 未通过 - 设计问题 | 重新设计接口 |

---

## 时间预估

| 依赖数量 | 预估时间 |
|----------|----------|
| 1-2 个依赖 | 1 - 2 小时 |
| 3-5 个依赖 | 2 - 4 小时 |
| >5 个依赖 | 4 - 8 小时 |

---

**完成后**：进入 [Skill 08: 小步重构](skill-08-refactor.md)
