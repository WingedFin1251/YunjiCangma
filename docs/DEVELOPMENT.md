# 开发指南

## 环境要求

| 工具 | 版本 | 说明 |
|------|------|------|
| DevEco Studio | 5.0+ | 官方 IDE，必装 |
| HarmonyOS SDK | API 6.1.0 (23) | 在 DevEco Studio 内下载 |
| ohpm | 随 IDE 安装 | 包管理器 |
| Node.js | 18+ | ohpm 依赖 |
| Git | 2.30+ | 版本控制 |

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/YOUR_USERNAME/Github.git
cd Github
```

### 2. 打开项目

1. 启动 DevEco Studio
2. **File → Open** → 选择项目根目录
3. 等待 ohpm 依赖自动安装
4. 等待 Hvigor 索引构建完成

### 3. 运行

- **模拟器**：点击工具栏运行按钮（Shift + F10）
- **真机**：USB 连接 → 开启开发者模式 → 运行

### 4. 构建

```bash
# Debug
hvigorw assembleHap --mode module -p product=default -p buildMode=debug

# Release  
hvigorw assembleHap --mode module -p product=default -p buildMode=release
```

## 项目规范

### 文件命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 页面组件 | `pages/XxxPage.ets` | `RepoDetailPage.ets` |
| Tab 页面 | `pages/tabs/XxxTab.ets` | `HomeTab.ets` |
| Service | `services/XxxService.ets` | `RepoService.ets` |
| Model | `models/Xxx.ets` | `Repository.ets` |
| 公共组件 | `common/components/Xxx.ets` | `RepoCard.ets` |
| 常量 | `common/constants/XxxConstants.ets` | `APIConstants.ets` |
| 测试 | `test/Xxx.test.ets` | `RepoService.test.ets` |

### ArkTS 编码规范

```typescript
// ✅ 推荐：声明式 UI
@Component
struct MyPage {
  @State data: string = '';

  build() {
    Column() {
      Text(this.data)
        .fontSize(16)
    }
  }
}

// ❌ 避免：命令式 DOM 操作
// document.getElementById() — ArkTS 不存在此概念
```

### ArkTS 严格模式规则

本项目启用了 `strictMode`（`caseSensitiveCheck` + `useNormalizedOHMUrl`），以下规则必须遵守：

1. **常量用类静态属性** — `export class DarkTheme { static readonly bg = '#121212' }`，禁止裸对象字面量
2. **数据用具名类实例** — 数组元素必须是有构造函数的类实例，禁止内联匿名对象
3. **静态方法无 `this`** — `this.xxx()` → `ClassName.xxx()`
4. **禁止对象展开** — `...obj` 不可用，需显式属性赋值
5. **数组显式类型** — `private items: MyClass[] = [...]` 必须标注类型
6. **`FontWeight.Light`** 不存在 → 使用 `FontWeight.Lighter`

```typescript
// ✅ 推荐模式：具名类 + 显式类型
class WorkItem {
  icon: string = '';
  label: string = '';
  constructor(icon: string, label: string) {
    this.icon = icon;
    this.label = label;
  }
}
private workItems: WorkItem[] = [
  new WorkItem('🟢', '议题'),
];

// ❌ 避免：内联对象
private items: Array<{icon: string; label: string}> = [
  { icon: '🟢', label: '议题' },  // 报错：arkts-no-untyped-obj-literals
];
```

### 新增功能流程

1. **数据模型** — `models/` 中定义数据结构，与 GitHub API 返回结构对应
2. **API 封装** — `services/` 中添加 API 调用方法，统一错误处理
3. **页面组件** — `pages/` 中创建 UI 组件
4. **路由注册** — 如需独立页面入口，在 `main_pages.json` 注册
5. **权限声明** — 在 `module.json5` 的 `requestPermissions` 中添加权限
6. **编写测试** — 在 `test/` 中写单元测试

### 新增页面步骤

1. 在 `pages/` 创建 `.ets` 文件
2. 在 `main_pages.json` 的 `src` 数组中添加路径
3. 若为 Tab 内子页面：通过 `NavPathStack.pushPath()` 导航
4. 若为独立页面：通过 `router.pushUrl()` 或 Navigation 导航

```json
// main_pages.json
{
  "src": [
    "pages/MainPage",
    "pages/RepoDetailPage"
  ]
}
```

### Git 提交规范

```
<type>(<scope>): <subject>

feat(home): add repository list component
fix(api): handle 401 unauthorized error
docs(readme): update build instructions
refactor(theme): extract color constants
test(repo): add repository service unit tests
```

## 调试技巧

### 日志

```typescript
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
hilog.info(DOMAIN, 'GitHub', 'API request: GET /repos/%{public}s', owner);
```

在 DevEco Studio 的 **Log** 窗口中过滤 `GitHub` 查看应用日志。

### 网络调试

- 使用 DevEco Studio 的 **Network Inspector** 查看 HTTP 请求
- 开发阶段可在 `module.json5` 中允许 `cleartext` 流量

### 布局调试

- DevEco Studio 内置 **Layout Inspector** 可视化组件树
- 开发时可给组件临时加背景色辅助定位

## 测试

```bash
# 本地单元测试（无需设备）
hvigorw test

# 设备集成测试（需要设备/模拟器）
hvigorw ohosTest
```

### 测试结构

```
entry/src/
├── test/           # 本地单元测试（JS 运行时）
│   ├── List.test.ets
│   └── LocalUnit.test.ets
└── ohosTest/       # 设备集成测试（HarmonyOS 运行时）
    ├── List.test.ets
    └── Ability.test.ets
```

## 常见问题

### Q: ohpm install 失败

检查网络连接和 ohpm 仓库配置。国内用户可配置华为镜像：

```bash
ohpm config set registry https://repo.harmonyos.com/ohpm/
```

### Q: 模拟器启动失败

确保在 DevEco Studio 中已下载并配置 HarmonyOS 模拟器镜像。

### Q: 签名错误

开发阶段使用 DevEco Studio 自动生成的调试签名。在 `File → Project Structure → Signing Configs` 中检查。
