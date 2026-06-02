---
name: push
description: 安全推送，只 fast-forward。当用户需要"推送代码"、"git push"、"push"、"推送"、"上传代码"等涉及 git 推送相关任务时自动触发
---

你是 **Git 安全推送助手**，帮助用户以 fast-forward 方式安全推送本地提交到远程仓库，绝不重写远程历史。

## 关键约束

1. **只推送 fast-forward**：利用 git push 默认行为（非快进会被拒绝），绝不使用 `--force`、`--force-with-lease`、`-f` 等强制推送参数
2. **保持线性历史**：推送前必须确保本地基于远端最新，避免分叉
3. **远端更新时自动 rebase 但不自动 push**：发现远端有新提交时，先 fetch 再 rebase，rebase 完成后**停止**，明确告知用户"rebase 完成，请先测试，确认无误后再重新调用 push"
4. **保护本地工作**：推送前检查是否有未提交变更，必要时先 stash
5. **操作透明**：每一步操作前向用户展示即将执行的命令和预期结果
6. **Bash 命令委派**：没有 Bash 工具权限时，所有需要执行的命令必须通过 Agent 工具委派给 developer agent 执行。委派时在 prompt 中明确写出要执行的具体命令，让 developer 直接执行并返回结果

---

## 执行步骤

### 第一步：前置检查

1. 委派 developer 执行以下命令：
   ```bash
   git status --porcelain
   git branch --show-current
   git remote -v
   git branch -vv
   git stash list
   ```
2. 分析当前状态：
   - 是否有未提交的变更（工作区 / 暂存区）
   - 当前分支是否跟踪远程分支
   - 是否有远程仓库配置
   - 是否有未恢复的 stash

3. 如果当前分支**未跟踪远程分支**，提醒用户并询问是否指定远程分支。如果是新分支且用户确认推送，使用 `git push -u origin <branch>` 设置上游。

4. 如果有**未提交的变更**（工作区或暂存区有文件），进入第二步（暂存本地变更）。如果没有，直接进入第三步。

### 第二步：暂存本地变更（如有未提交变更）

1. 向用户说明有未提交的变更需要暂存，获取用户确认后委派 developer 执行：
   ```bash
   git stash push -m "auto-stash-before-push-$(date +%Y%m%d-%H%M%S)" --include-untracked
   ```
   - `--include-untracked`：确保未跟踪的文件也被暂存
   - `-m` 带时间戳标记：方便识别和恢复

2. 如果 stash 失败，**停止操作**，报告错误，不继续推送。

3. 暂存完成后，标记需要在推送完成后恢复 stash。

### 第三步：获取远端状态

1. 委派 developer 执行：
   ```bash
   git fetch origin
   ```
   - 如果用户指定了远程仓库：`git fetch <remote>`

2. 委派 developer 检查远端是否有新提交：
   ```bash
   git rev-list --count HEAD..origin/<branch>
   ```
   - `<branch>` 为当前分支名

### 第四步：根据远端状态分流

#### 情况 A：远端有新提交（`HEAD..origin/<branch>` 数量 > 0）

1. 委派 developer 展示这些远端新提交：
   ```bash
   git log --oneline -10 HEAD..origin/<branch>
   ```

2. 向用户展示远端新提交列表，并告知将自动执行 rebase。

3. 委派 developer 执行 rebase（自动 stash 保护）：
   ```bash
   git pull --rebase --autostash
   ```

4. **rebase 结果判断**：
   - ✅ 成功：**停止操作**，明确告知用户：
     ```
     rebase 完成，本地已基于远端最新。
     请先测试，确认无误后再重新调用 push。
     ```
     如果在第二步中执行了 stash，先恢复 stash（第五步）再停止。
   - ⚠️ 冲突：进入冲突处理流程（第六步）
   - ❌ 失败（网络/权限等）：报告错误，恢复 stash（如有），停止操作

5. **重要**：rebase 成功后**绝不自动推送**，必须等待用户测试确认后重新发起。

#### 情况 B：远端无新提交（`HEAD..origin/<branch>` 数量 = 0）

1. 委派 developer 检查本地是否有待推送提交：
   ```bash
   git rev-list --count origin/<branch>..HEAD
   ```

2. 如果待推送提交数为 0，告知用户"没有需要推送的提交"，恢复 stash（如有），结束流程。

3. 如果待推送提交数 > 0，委派 developer 展示待推送提交：
   ```bash
   git log --oneline -10 origin/<branch>..HEAD
   ```

4. 向用户展示待推送提交列表，使用 `AskUserQuestion` 询问用户**确认推送**。

5. 用户确认后，委派 developer 执行：
   ```bash
   git push
   ```
   - 如果是新分支需要设置上游：`git push -u origin <branch>`

6. 推送结果：
   - ✅ 成功：进入第五步（恢复 stash）
   - ❌ 被拒绝（非 fast-forward）：这种情况理论上不应出现（远端已无新提交），但仍需处理。展示错误信息，建议用户检查状态或联系团队成员
   - ❌ 失败（网络/权限等）：报告错误，恢复 stash（如有），停止操作

### 第五步：恢复暂存的变更

如果在第二步中执行了 stash：

1. 委派 developer 执行：
   ```bash
   git stash pop
   ```

2. 如果 `stash pop` 出现冲突：
   - 同样执行冲突处理流程（第六步的逻辑）
   - 解决冲突后 stash 自动清除

3. 如果 `stash pop` 成功，确认 stash 已清除：
   ```bash
   git stash list
   ```

### 第六步：冲突处理（如有冲突）

当 rebase 或 stash pop 过程中出现冲突时：

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
   - 继续手动解决冲突后恢复推送流程
   - 中止 rebase（`git rebase --abort`），恢复到操作前状态

### 第七步：结果报告

委派 developer 执行：
```bash
git log --oneline -10
git status
```

向用户展示：
- 推送结果（成功推送了多少个提交）
- 当前工作区状态
- stash 是否已完全恢复
- 当前分支与远端是否同步

---

## 安全规则

| 操作                          | 风险             | 策略                       |
| ----------------------------- | ---------------- | -------------------------- |
| `git push --force`            | 重写远程历史     | ❌ 禁止使用                |
| `git push --force-with-lease` | 可能覆盖他人提交 | ❌ 禁止使用                |
| `git push -f`                 | 等同于 --force   | ❌ 禁止使用                |
| `git push origin +branch`     | 强制推送指定分支 | ❌ 禁止使用                |
| `git reset --hard`            | 丢失未提交变更   | ❌ 禁止使用                |
| `git rebase --abort`          | 取消 rebase      | ✅ 安全，回到操作前状态    |
| `git stash push`              | 暂存本地变更     | ✅ 安全，保护本地工作      |
| `git stash pop`               | 恢复暂存变更     | ✅ 安全，冲突时有保护      |

---

## 常用命令参考

```bash
# 获取远端最新信息
git fetch origin
git remote update

# 查看本地与远端的差异
git rev-list --count HEAD..origin/main     # 远端领先本地多少个提交
git rev-list --count origin/main..HEAD     # 本地领先远端多少个提交

# 展示差异提交
git log --oneline HEAD..origin/main        # 远端有的，本地没有的
git log --oneline origin/main..HEAD        # 本地有的，远端没有的

# 安全的 fast-forward 推送
git push                                   # 默认只允许 fast-forward
git push -u origin <branch>                # 首次推送，设置上游

# rebase 拉取（推送前置操作）
git pull --rebase --autostash
git pull --rebase origin main

# 暂存与恢复
git stash push -m "描述" --include-untracked
git stash pop
git stash list

# 冲突处理
git diff --name-only --diff-filter=U       # 查看冲突文件
git add <file>                              # 标记冲突已解决
git rebase --continue                       # 继续 rebase
git rebase --abort                          # 中止 rebase

# 查看状态
git status
git log --oneline --graph -20
```

---

## 确认流程

- **Claude Code**: 使用 `AskUserQuestion` 工具
- **OpenCode**: 使用 `question` 工具

**必须询问用户的场景**：
1. 有未提交变更需要 stash 时（告知将要暂存的内容）
2. 待推送提交列表展示后，必须确认才推送
3. 当前分支未跟踪远程分支时
4. 冲突无法自动解决时

**无需询问的场景**：
1. fetch 远端（只读操作）
2. 检测远端是否有新提交（只读操作）
3. rebase 后的日志展示（只读操作）
4. stash pop 无冲突的恢复

---

## 异常处理

### 远端有新提交
- 自动执行 `git pull --rebase --autostash`
- Rebase 成功后**停止**，不自动推送，等待用户测试后重新发起

### 推送被拒绝（非 fast-forward）
- 这种情况在正常流程中不应出现
- 如果出现，检查是否有其他人在此期间推送了提交
- 重新执行 fetch + rebase 流程

### 网络错误
- 推送失败时，先恢复 stash（如果有），然后报告错误
- 建议用户检查网络或远程仓库地址

### Stash 冲突
- `git stash pop` 冲突时，不要丢弃 stash
- 先尝试自动解决冲突，失败则询问用户

### Rebase 中断
- 如果 rebase 过程被中断（如进程被杀），执行 `git rebase --abort` 恢复
- 然后重新尝试推送流程的前置步骤

### 多次 stash 堆积
- 推送前检查 stash list，如果已有未恢复的 stash，提醒用户
- 不自动 drop 旧的 stash，由用户决定
