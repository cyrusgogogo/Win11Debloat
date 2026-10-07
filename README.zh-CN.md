# Win11Debloat 简体中文汉化

[English](README.md) · 简体中文

Win11Debloat 是用于移除预装应用、调整隐私选项和自定义 Windows 界面的 PowerShell 工具。本分支在原有多语言架构中新增 `zh-CN`，保留上游功能与英文语言包。

## 使用前请注意

> **本工具会修改系统设置，并可卸载应用。请先备份重要数据，逐项阅读说明，只选择自己理解且需要的操作。使用风险由你自行承担。**
>
> 创建系统还原点和保留注册表备份有助于恢复，但不能保证恢复所有应用、应用数据或其他改动。不要把“还原注册表备份”理解成完整撤销所有操作。

尤其注意：禁用遥测可能影响 Windows Insider 更新；禁用位置服务会影响依赖位置的应用；关闭 BitLocker 自动加密会影响以后自动加密的行为；强制卸载 Edge 或移除标有警告的组件可能导致功能异常。请以界面中的完整提示为准，不要盲目应用全部选项。

## 下载这个汉化分支

1. 在本 GitHub 分支页面选择 **Code → Download ZIP**，完整解压文件夹。
2. 不要只下载 `Win11Debloat.ps1` 或语言文件；程序依赖同目录下的 `Scripts`、`Config`、`Schemas`、`Regfiles` 和 `Assets`。
3. 上游 README 中的在线快速启动命令、`Scripts/Get.ps1` 下载器和上游发布包会下载上游版本，**不保证包含本分支的中文语言包**。请使用本分支的完整文件。`Run.bat` 只启动本地脚本，不会自动下载替换语言包。

## 启动简体中文界面

需要 Windows 和 **Windows PowerShell 5.1（powershell.exe）**，不要使用 PowerShell 7（pwsh）。程序的 Appx 和系统还原功能依赖 Windows PowerShell 模块。

### 方法一：使用图形界面

1. 双击解压目录中的 `Run.bat`，按需确认 Windows 管理员权限提示。
2. Windows 显示语言为简体中文时，程序通常会自动使用 `zh-CN`。
3. 如果仍是英文，点击窗口右上角的齿轮按钮 **Settings（设置）**，将 **Language** 设为 **中文（中国）/ Chinese (China) / zh-CN** 对应的项目，然后选择 **Save**。名称取决于系统提供的语言名称。
4. 先查看主页、移除应用、系统调整与部署设置，确认要更改的用户及选项，再决定是否应用。

### 方法二：明确指定中文

在解压目录打开管理员 Windows PowerShell，运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Win11Debloat.ps1 -Language zh-CN
```

`-Language zh-CN` 使用现有语言参数，不会翻译或改变命令行参数名。这里的执行策略选项只针对启动的 PowerShell 进程；不要为此永久降低系统执行策略。

## 汉化范围

- 主窗口、导航、按钮、设置、对话框、提示及辅助功能标签
- 应用名称、应用用途说明和卸载风险警告
- 系统调整分类、功能说明、应用/撤销提示及分组选项
- 导入/导出配置、注册表备份与还原界面、部署设置

本次沿用上游的 **GUI 语言包**机制。`-CLI` 命令行菜单、启动器提示、部分底层 PowerShell/系统错误与日志，以及上游 Wiki 仍可能为英文。应用品牌、包标识符、功能 ID、参数名、注册表路径和实际清理行为保持不变。

## 维护和验证

翻译位于 `Config/Languages/zh-CN/` 的四个 JSON 文件。新增上游翻译键时，应同步更新这些文件并保留格式化占位符（例如 `{0}`）。中文计数统一采用 `other` 复数类别。

在已安装 Pester 5 的 Windows PowerShell 中，只运行语言相关测试：

```powershell
Invoke-Pester -Path .\Tests\SimplifiedChinese-Localization.Tests.ps1, .\Tests\Import-LanguageFile.Tests.ps1 -Output Detailed
```

新增的简体中文测试只读取语言 JSON 并调用语言加载/翻译函数，不运行清理入口或修改系统。完整测试方法见 [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md)。

本次已做 JSON、键集合、格式化占位符与非空内容的静态检查；尚未在 Windows 桌面实际启动 GUI，也未执行完整 Pester 套件。正式使用前，建议在可还原的 Windows 测试环境中检查文字截断、深浅主题、语言切换和各类弹窗。

## 致谢与许可

原项目：[Raphire/Win11Debloat](https://github.com/Raphire/Win11Debloat)。本 fork：[cyrusgogogo/Win11Debloat](https://github.com/cyrusgogogo/Win11Debloat)。项目按原有 [MIT 许可证](LICENSE) 分发，保留上游作者署名。
