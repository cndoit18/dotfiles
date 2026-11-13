# AGENTS.md

## 仓库用途

这是一个使用 [chezmoi](https://www.chezmoi.io/) 管理 `$HOME` 配置的 dotfiles 仓库。

仓库存放的是**源状态**，不是实际的 home 目录。修改仓库后，由 chezmoi 将源状态渲染并应用到 `$HOME`。Agent 修改此仓库时，应编辑源状态并验证渲染结果，而不是直接修改真实的 `$HOME` 文件。

## 仓库结构

- `.chezmoiroot` 指向 `home/`，因此 `home/` 是受管理配置的源状态根目录。
- `home/` 下的路径和文件名决定渲染后的目标路径、权限及处理方式。
- `.chezmoiscripts/darwin/` 和 `.chezmoiscripts/linux/` 存放系统专用脚本。
- `.chezmoiignore.tmpl` 控制不同环境下需要忽略的内容。
- `.chezmoiexternal.toml.tmpl` 定义需要下载的外部文件和归档。

## 文件名语义

chezmoi 会通过文件名控制目标行为：

| 属性 | 作用 |
|---|---|
| `dot_` | 映射为隐藏文件，例如 `dot_xxx` 对应 `.xxx` |
| `private_` | 设置受限权限 |
| `exact_` | 将目标目录设为 exact，可能删除其中不受管理的文件 |
| `noexact_` | 抵消父目录的 exact 属性 |
| `.tmpl` | 作为 Go 模板渲染，而不是原样复制 |

移动或重命名文件时，保留这些属性，除非任务明确要求改变目标行为。

## 如何修改

1. 先确定源路径和目标路径；映射不清楚时使用：

   ```bash
   chezmoi source-path <target>
   chezmoi target-path <source>
   ```

2. 在 `home/` 或相应的 chezmoi 定义中修改源状态。不要直接编辑真实 `$HOME` 目标，也不要在仓库根目录模拟 home 目录。

3. 修改 `.tmpl` 时，通过 chezmoi 验证渲染结果。模板中的 `onepasswordRead` 必须保留，不得替换为字面量机密。

4. 修改外部下载内容时，应更改 `.chezmoiexternal.toml.tmpl` 中的定义，不要直接维护下载产物。

5. 修改脚本或其模板数据时，注意 `run_onchange_` 和 `run_after_` 脚本可能在后续 apply 中执行，包括安装软件包或工具。

## 验证与实际应用

常用验证命令：

```bash
# 查看源状态将对目标产生的变化
chezmoi diff

# 预览 apply 过程，不实际修改目标
chezmoi apply --dry-run --verbose

# 验证单个模板
chezmoi execute-template < path/to/template.tmpl
```

完成后，确认 diff 符合任务目标，没有意外的文件删除或脚本执行。依赖不可用或验证失败时，报告具体错误，不要猜测渲染结果。

不要为了验证而执行非 dry-run 的 `chezmoi apply`。只有用户明确要求且已经检查目标变化时才可执行；如果涉及文件删除、软件安装或其他难以撤销的影响，执行前必须获得用户确认。

提交信息沿用仓库的 Conventional Commits 风格。
