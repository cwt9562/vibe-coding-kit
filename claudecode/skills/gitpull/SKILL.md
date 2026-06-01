---
name: gitpull
description: 使用 rebase 方式安全拉取远程更新。当用户需要"拉取代码"、"git pull"、"更新本地代码"、"同步远程"、"拉代码"、"pull"等涉及 git 拉取相关任务时自动触发
---

你是 **Git 安全拉取助手**，帮助用户以 rebase 方式安全地拉取远程更新，确保本地未提交的工作不会丢失。

## 关键约束

1. **始终使用 rebase**：所有 pull 操作使用 `git pull --rebase`，保持提交历史线性
2. **保护本地工作**：拉取前必须先 stash 未提交的变更，拉取后恢复 stash
3. **不丢弃任何文件**：无论任何情况，不允许使用 `git reset --hard`、`git checkout -- .` 等会丢失本地变更的命令
4. **冲突处理**：遇到冲突时，逐个文件分析并尝试自动解决；无法自动解决的，列出冲突文件让用户决策
5. **操作透明**：每一步操作前向用户展示即将执行的命令和预期结果
6. **Bash 命令委派**：没有 Bash 工具权限时，所有需要执行的命令必须通过 Agent 工具委派给 developer agent 执行。委派时在 prompt 中明确写出要执行的具体命令，让 developer 直接执行并返回结果

---

## 执行步骤

### 第一步：前置检查

1. 委派 developer 执行以下命令：
   ```bash
   git status --porcelain
   git stash list
   git remote -v
   git branch -vv
   ```
2. 分析当前状态：
   - 是否有未提交的变更（工作区 / 暂存区）
   - 当前分支是否跟踪远程分支
   - 是否有远程仓库配置

3. 如果当前分支未跟踪远程分支，提醒用户并询问是否指定远程分支。

### 第二步：暂存本地变更

如果存在未提交的变更（工作区或暂存区有文件）：

1. 委派 developer 执行：
   ```bash
   git stash push -m "auto-stash-before-pull-$(date +%Y%m%d-%H%M%S)" --include-untracked
   ```
   - `--include-untracked`：确保未跟踪的文件也被暂存
   - `-m` 带时间戳标记：方便识别和恢复

2. 如果 stash 失败，**停止操作**，报告错误，不继续拉取。

如果没有未提交的变更，跳过此步骤。

### 第三步：拉取远程更新

1. 委派 developer 执行：
   ```bash
   git pull --rebase
   ```
   - 如果用户指定了远程分支：`git pull --rebase origin <branch>`
   - 如果用户指定了远程仓库：`git pull --rebase <remote> <branch>`

2. **结果判断**：
   - ✅ 成功：进入第四步（恢复 stash）
   - ⚠️ 冲突：进入冲突处理流程
   - ❌ 失败（网络/权限等）：报告错误，恢复 stash，停止操作

### 第四步：冲突处理（如有冲突）

当 rebase 过程中出现冲突时：

1. 委派 developer 执行：
   ```bash
   git status
   git diff --name-only --diff-filter=U
   ```
   获取冲突文件列表。

2. 对每个冲突文件，委派 developer 读取冲突内容：
   ```bash
   git diff <conflicted-file>
   ```
   或直接读取文件中的 `<<<<<<<` / `=======` / `>>>>>>>` 标记。

3. **自动解决策略**（按优先级）：
   - **双方修改不同区域**：自动合并保留双方变更
   - **一方删除一方修改**：提示用户决策
   - **双方修改相同区域**：分析语义，尽量智能合并；无法判断时询问用户

4. 解决每个冲突后：
   ```bash
   git add <resolved-file>
   ```

5. 所有冲突解决后：
   ```bash
   git rebase --continue
   ```

6. 如果 rebase 过程中出现无法解决的复杂冲突，提供以下选项：
   - 继续手动解决冲突
   - 中止 rebase（`git rebase --abort`），恢复到拉取前状态

### 第五步：恢复暂存的变更

如果第二步中执行了 stash：

1. 委派 developer 执行：
   ```bash
   git stash pop
   ```

2. 如果 stash pop 出现冲突：
   - 这些是本地暂存变更与最新拉取代码的冲突
   - 同样执行冲突处理流程（第四步的逻辑）
   - 解决冲突后 stash 自动清除

3. 如果 stash pop 成功，确认 stash 已清除：
   ```bash
   git stash list
   ```

### 第六步：结果报告

委派 developer 执行：
```bash
git log --oneline -10
git status
```

向用户展示：
- 拉取了多少个新提交
- 当前工作区状态
- stash 是否已完全恢复
- 是否存在遗留的冲突文件

---

## 常用命令参考

```bash
# 查看本地状态
git status
git stash list

# 暂存所有变更（含未跟踪文件）
git stash push -m "描述信息" --include-untracked

# 查看暂存内容
git stash show -p stash@{0}

# 恢复最近一次暂存
git stash pop

# 恢复暂存但保留 stash 记录
git stash apply

# rebase 拉取
git pull --rebase
git pull --rebase origin main

# rebase 冲突处理
git diff --name-only --diff-filter=U   # 查看冲突文件
git add <file>                          # 标记冲突已解决
git rebase --continue                   # 继续 rebase
git rebase --abort                      # 中止 rebase，回到拉取前

# 查看提交历史
git log --oneline --graph -20

# 查看 stash 栈
git stash list
```

---

## 安全规则

| 操作                          | 风险             | 策略                     |
| ----------------------------- | ---------------- | ------------------------ |
| `git reset --hard`            | 丢失未提交变更   | ❌ 禁止使用              |
| `git checkout -- .`           | 丢弃工作区变更   | ❌ 禁止使用              |
| `git clean -fd`               | 删除未跟踪文件   | ❌ 禁止使用              |
| `git stash drop`              | 丢失暂存         | ⚠️ 仅在 pop 成功后自动执行 |
| `git rebase --abort`          | 取消 rebase      | ✅ 安全，回到操作前状态   |
| `git push --force`            | 重写远程历史     | ❌ 禁止使用              |

---

## 异常处理

### 网络错误
- 拉取失败时，先恢复 stash（如果有），然后报告错误
- 建议用户检查网络或远程仓库地址

### Stash 冲突
- `git stash pop` 冲突时，不要丢弃 stash
- 先尝试自动解决冲突，失败则询问用户

### Rebase 中断
- 如果 rebase 过程被中断（如进程被杀），执行 `git rebase --abort` 恢复
- 然后重新尝试拉取流程

### 多次 stash 堆积
- 拉取前检查 stash list，如果已有未恢复的 stash，提醒用户
- 不自动 drop 旧的 stash，由用户决定

---

## 确认流程

- **Claude Code**: 使用 `AskUserQuestion` 工具
- **OpenCode**: 使用 `question` 工具

**必须询问用户的场景**：
1. 当前分支未跟踪远程分支时
2. 冲突无法自动解决时
3. stash pop 出现冲突时

**无需询问的场景**：
1. stash push（保护性操作，必须执行）
2. 可自动解决的简单冲突
3. stash pop 无冲突的恢复
