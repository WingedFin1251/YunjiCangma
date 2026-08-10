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
git clone https://github.com/WingedFin1251/Github.git
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
| Tab 页面 | `pages/tabs/XxxTab.ets` | `HomeTab.ets` |
| 子页面 | `pages/sub/XxxPage.ets` | `RepoDetailPage.ets` |
| 独立页面 | `pages/XxxPage.ets` | `LoginPage.ets` |
| Repository | `services/XxxRepository.ets` | `RepoRepository.ets` |
| 认证/工具服务 | `services/XxxService.ets` | `AuthService.ets` |
| HTTP 引擎 | `services/HttpClient.ets` | — |
| Model | `models/Xxx.ets` | `User.ets` |
| 公共组件 | `common/components/Xxx.ets` | `RepoCard.ets` |
| 常量 | `common/constants/XxxConstants.ets` | `APIConstants.ets` |
| 工具函数 | `common/utils/Xxx.ets` | `NavTitleBar.ets` |
| 测试 | `test/Xxx.test.ets` | `RepoRepository.test.ets` |

### ArkTS 编码规范

```typescript
// ✅ 推荐：声明式 UI + 主题联动
@Component
struct MyPage {
  @StorageLink('currentTheme') themeMode: string = 'dark';

  private T(): ThemeColors {
    const d = this.themeMode === 'dark';
    return {
      background: d ? DarkTheme.background : LightTheme.background,
      // ... 14 色值
    };
  }

  build() {
    Column() {
      Text('Hello')
        .fontSize(16)
        .fontColor(this.T().textPrimary)
    }
    .backgroundColor(this.T().background)
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
  color: string = '';
  route: string = '';
  constructor(icon: string, label: string, color: string, route: string) {
    this.icon = icon;
    this.label = label;
    this.color = color;
    this.route = route;
  }
}
private workItems: WorkItem[] = [
  new WorkItem('●', '议题', '#2EA44F', 'issues'),
];

// ❌ 避免：内联对象
private items: Array<{icon: string; label: string}> = [
  { icon: '🟢', label: '议题' },  // 报错：arkts-no-untyped-obj-literals
];
```

### 新增功能流程

1. **数据模型** — `models/` 中定义数据结构，与 GitHub API 返回结构对应
2. **API 封装** — 在对应 `services/XxxRepository.ets` 中添加方法，通过 `HttpClient.get<T>()` 调用
3. **页面组件** — `pages/` 或 `pages/sub/` 中创建 UI 组件
4. **路由注册** — 独立页面在 `main_pages.json` 注册；Tab 内子页通过 `NavPathStack.pushPath()` 导航
5. **路由映射** — 在父组件的 `@Builder pageMap(name, param)` 中添加 `NavDestination` 分支
6. **权限声明** — 在 `module.json5` 的 `requestPermissions` 中添加权限
7. **编写测试** — 在 `test/` 中写单元测试

### 新增页面步骤

1. 在 `pages/sub/` 创建 `.ets` 文件
2. 在对应 Tab 的 `pageMap` Builder 中添加路由分支：
   ```typescript
   @Builder
   homePageMap(name: string, param: ESObject) {
     if (name === 'newPage') {
       NavDestination() { NewPage({ ... }) }
         .title('新页面').backgroundColor(this.T().background).padding({ top: 32 })
     }
     // ... 其他路由
   }
   ```
3. 通过 `this.xxxStack.pushPath({ name: 'newPage' })` 导航
4. 如需独立入口（非 Tab 内），在 `main_pages.json` 注册后通过 `router.pushUrl()` 跳转

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
