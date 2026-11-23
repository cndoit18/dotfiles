# 独立 Agent 评测协议

运行任何触发、输出或自评测前阅读。目标是把“Agent 执行与判断”同“宿主隔离与事实记录”结合起来，避免被测对象自己宣布自己通过。

## 1. 角色与信任边界

- **编排 Agent**：读取用例、准备候选版本、启动 Runner、保存证据、汇总报告。它可以加载 skill-forge，但不能充当干净 Runner。
- **Runner Agent**：在干净上下文中执行一条任务。触发评测只看到原始 query；执行评测可按实验设计强制激活候选 Skill。
- **Judge Agent**：只接收产物、断言和必要输入，不参与创建或优化。A/B 对比时隐藏版本身份。
- **确定性脚本**：校验结构、解析日志、计算指标。能机械判定的项目不交给 LLM 猜测。
- **人工评审**：检查实际可用性、审美和未覆盖意图，处理无法可靠自动判定的项目。

生成用例、执行用例、评分和修改 Skill 不应由同一个上下文无隔离地完成。

## 2. 运行前适配检查

逐项确认目标运行时能否提供：

1. 全新上下文，且不继承设计讨论、答案或先前加载的 Skill 正文；
2. 候选 Skill 已注册并出现在 Runner 的正常发现目录中；
3. 与其他真实 Skill 共存的目录，而非只给目标 Skill 的失真环境；
4. 完整工具事件或 Skill 加载日志；
5. 固定模型、参数、工具和输入的能力；
6. 隔离的产物目录，以及无害的测试文件和外部操作替身。

缺少第 1～4 项时，不做触发通过率断言。缺少完整日志时，可把输出作为普通任务结果，但不能从输出反推 Skill 曾加载。

## 3. 触发评测

### 3.1 准备用例

使用真实表达，混合正式、口语、简略、详细、显式和隐性请求。负例以共享关键词但意图不同的 near-miss 为主。

固定训练集和验证集。只用训练集失败修改 description，验证集只用于最终泛化检查。

### 3.2 运行

每个用例、每次重复都执行：

1. 创建干净 Runner，确认候选版本名称和发现目录。
2. 只发送 `query` 原文，不出现目标 Skill 名、斜杠命令、路径或“请使用某 Skill”。
3. 观察是否发生目标 Skill 的真实加载事件。
4. 保存完整事件日志，并在安全且运行时支持时于加载后停止；否则让任务在隔离环境完成。
5. 记录布尔结果和证据。没有完整日志时将本次标为不可判定，不得把“没有提到 Skill”记作未触发。

非确定性环境可先每条运行 3 次。默认初筛规则为：正例触发率 `> 0.5`，负例触发率 `< 0.5`；等于阈值不通过。正式项目可提高门槛。

### 3.3 JSONL 数据契约

每行是一条独立运行记录：

```json
{"configuration":"candidate","query_id":"create-implicit","query":"把团队复盘流程沉淀成可复用 Skill","should_trigger":true,"triggered":true,"evidence":{"kind":"skill_load_event","ref":"runs/create-implicit-1.json"}}
{"configuration":"candidate","query_id":"prompt-polish","query":"把这段提示词压缩到 200 字","should_trigger":false,"triggered":false,"evidence":{"kind":"tool_log","ref":"runs/prompt-polish-1.json"}}
```

字段要求：

- `configuration`：例如 `baseline`、`candidate`；同一次比较中保持含义稳定。
- `query_id`：同一配置内同一 query 的多次运行使用相同 ID。
- `should_trigger`、`triggered`：布尔值。
- `evidence.kind`：`skill_load_event`、`tool_log` 为强证据；`agent_self_report` 只作弱证据并会被单独计数。
- `evidence.ref`：可复核的日志位置或记录引用，不能为空。

汇总：

```bash
python3 scripts/aggregate_trigger_results.py results.jsonl
```

输出包含每个 query 的触发率、query 通过率、正例召回率、负例误触发率和弱证据运行数。弱证据较多时不得给出高置信结论。

## 4. 执行与输出评测

### 4.1 公平对照

创建模式比较：

```text
无 Skill vs 有候选 Skill
```

优化模式比较：

```text
旧版 Skill 快照 vs 候选 Skill
```

每组使用相同模型、参数、工具、输入文件、运行次数和干净上下文。只评测正文时可以显式提供 Skill 路径强制激活；端到端评测则保留自然路由，并分别记录触发和任务结果。

### 4.2 保存产物

每次迭代分别保存：

```text
iteration-N/
├── case-id/
│   ├── baseline/
│   │   ├── outputs/
│   │   ├── run.json
│   │   └── grading.json
│   └── candidate/
│       ├── outputs/
│       ├── run.json
│       └── grading.json
└── benchmark.json
```

记录 token、时长、工具调用和无法观察的事件。不要覆盖历史迭代。

### 4.3 断言与评审

- 文件、schema、数量、路径和确定行为用脚本验证。
- 语义覆盖和整体质量交给独立 Judge；A/B 顺序随机化并隐藏版本身份。
- Judge 对每项给 `PASS`、`FAIL`、`UNKNOWN` 和具体证据；没有证据不得 PASS。
- 检查两版都通过的无区分度断言，以及两版都失败的无效或超能力断言。
- 人工查看实际产物，特别检查“格式正确但没有解决任务”的假通过。

## 5. 二阶评测

当 skill-forge 的产物是另一个 Skill 时：

1. 静态校验生成的 Skill；
2. 把它注册到新的隔离环境；
3. 用未参与创作的 Runner 测试其触发与任务执行；
4. 对比无该产物或旧版产物的基线；
5. 将下游任务结果纳入 skill-forge 本身的评分。

只评审生成文本是一阶检查，不能证明产物有效。

## 6. 自评测与 DSH 注意事项

评测 skill-forge 自身时同样遵守以上隔离。当前主 Agent 已加载本 Skill，只能编排。

在支持独立子代理的运行时，可使用不继承对话的子代理作为 Runner；不要使用继承当前对话的 fork。开始前先用一个无害探针确认子代理的实际 Skill 目录和事件可见性。

某些 DSH 子代理接口只把最终结果返回给父 Agent，不提供完整工具轨迹。此时：

- 可以运行强制激活的执行评测并评审产物；
- 不能把子代理自报加载当作强触发证据；
- 触发评测必须等待宿主日志、事件流或专门运行时适配器；
- 无法取得强证据时在报告中明确写“触发 A/B 未执行／不可判定”。

## 7. 安全与停止

- 使用合成文件、临时目录和外部服务替身，不为了评测发送真实消息或修改真实数据。
- 不自动执行被测 Skill 中未审查的脚本。
- 任一运行越过批准范围时停止该运行并保留证据。
- 修复不得来自验证集原文；出现泄漏时更换验证集并重新评测。
- 达到预设通过条件或收益平台期即停止，不做无证据的无限自优化。

## 官方参考

- [触发描述评测](https://agentskills.io/skill-creation/optimizing-descriptions)
- [输出质量评测](https://agentskills.io/skill-creation/evaluating-skills)
