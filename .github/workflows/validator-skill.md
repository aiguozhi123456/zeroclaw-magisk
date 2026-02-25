# GitHub Workflow Validator

该技能用于诊断、检查和修复GitHub Actions工作流中的常见问题。

## 检查清单

### 1. 基础语法检查
- [ ] YAML语法正确
- [ ] 缩进使用空格（2个或4个）
- [ ] 所有引号匹配
- [ ] 没有tab字符

### 2. 触发器配置
- [ ] workflow_dispatch输入参数定义正确
- [ ] schedule cron表达式有效
- [ ] 其他事件触发器配置正确

### 3. 权限配置
- [ ] permissions字段在顶层或job层级
- [ ] 权限名称有效（contents, issues, pull-requests等）
- [ ] 不包含无效的权限（如releases）

### 4. 步骤逻辑
- [ ] 条件表达式语法正确
- [ ] 步骤依赖关系合理
- [ ] 环境变量和上下文使用正确

### 5. Git操作
- [ ] checkout配置正确（fetch-depth, token等）
- [ ] git commit处理空提交
- [ ] git tag处理已存在标签
- [ ] 文件删除/清理逻辑正确

### 6. 文件打包
- [ ] 压缩包路径正确
- [ ] 压缩包结构符合目标系统要求
- [ ] 临时文件被正确清理

### 7. Release创建
- [ ] tag_name格式正确
- [ ] files路径存在且匹配
- [ ] fail_on_unmatched_files配置合理

## 常见问题诊断

### 问题1: YAML语法错误
**症状**: workflow无法触发，显示语法错误

**检查方法**:
```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/workflow.yml'))"
```

**常见原因**:
- 缩进不一致
- 多行字符串格式错误
- 特殊字符未转义

### 问题2: 权限无效
**症状**: workflow_dispatch失败，提示"Unexpected value"

**检查方法**:
查看GitHub文档中的有效权限列表：
https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token

**常见错误**:
```yaml
# 错误
permissions:
  releases: write  # releases不是有效权限

# 正确
permissions:
  contents: write  # contents权限包括创建releases
```

### 问题3: tag已存在
**症状**: git push tag失败，"tag already exists"

**解决方案**:
```yaml
# 使用--force强制更新
git tag -f "$VERSION"
git push origin "$VERSION" --force
```

### 问题4: 压缩包结构错误
**症状**: 解压后有多余目录层级

**检查方法**:
```bash
unzip -l package.zip
```

**解决方案**:
```yaml
# 错误
zip -r "package-$VERSION.zip" ./

# 正确
cd module-dir && zip -r "../package-$VERSION.zip" . && cd ..
```

### 问题5: 空提交导致失败
**症状**: "nothing to commit, working tree clean"

**解决方案**:
```yaml
# 使用--allow-empty
if git diff --cached --quiet; then
  git commit --allow-empty -m "Update to $VERSION"
else
  git commit -m "Update to $VERSION"
fi
```

### 问题6: Release上传文件失败
**症状**: "Pattern does not match any files"

**检查方法**:
```bash
ls -la *.zip  # 确认文件存在
```

**解决方案**:
```yaml
# 1. 不删除zip文件，或在上传前创建
# 2. 使用正确的相对路径
# 3. 添加fail_on_unmatched_files: true便于调试
```

## 工作流最佳实践

### 1. 版本控制策略
```yaml
# 备份原始文件
- name: Backup files
  run: |
    cp file.ext /tmp/backup.ext

# 恢复占位符
- name: Restore placeholders
  run: |
    cp /tmp/placeholders/* .
```

### 2. 强制更新机制
```yaml
workflow_dispatch:
  inputs:
    force_update:
      description: '强制更新到最新版本'
      type: boolean
      default: false

- name: Check if update needed
  id: check
  run: |
    if [ "${{ inputs.force_update }}" = "true" ]; then
      echo "update_needed=true" >> $GITHUB_OUTPUT
    else
      # 正常版本检查
    fi
```

### 3. 环境变量使用
```yaml
env:
  SOURCE_REPO: zeroclaw-labs/zeroclaw

# 在步骤中引用
"${{ env.SOURCE_REPO }}"
```

### 4. 多行JSON生成
```yaml
# 推荐使用echo而非heredoc
echo '{' > output.json
echo "  \"version\": \"$VERSION\"," >> output.json
echo "  \"versionCode\": $VERSION_CODE" >> output.json
echo '}' >> output.json
```

### 5. Checkout配置
```yaml
- uses: actions/checkout@v4
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    fetch-depth: 0      # 获取所有历史
    clean: true         # 清理工作目录
```

## 诊断命令

### 检查工作流语法
```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/workflow.yml'))"
```

### 测试工作流触发
```bash
gh workflow run workflow-name.yml -f input1=value1
```

### 查看工作流日志
```bash
gh run view <run-id> --log
gh run view <run-id> --log-failed
```

### 检查工作流历史
```bash
gh run list --workflow=workflow-name.yml --limit 10
```

### 验证输出文件
```bash
# 下载release包
wget <release-url>

# 检查结构
unzip -l package.zip

# 解压验证
unzip -q package.zip -d test-dir
ls -la test-dir/
```

## 故障排除步骤

1. **查看最新运行状态**
   ```bash
   gh run list --workflow=workflow.yml --limit 1
   ```

2. **查看失败日志**
   ```bash
   gh run view <run-id> --log-failed
   ```

3. **检查语法**
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('.github/workflows/workflow.yml'))"
   ```

4. **验证远程配置**
   ```bash
   gh api /repos/owner/repo/contents/.github/workflows/workflow.yml
   ```

5. **触发测试运行**
   ```bash
   gh workflow run workflow.yml -f force_update=true
   ```

6. **验证输出**
   - 检查生成的文件
   - 验证文件结构
   - 测试功能是否正常

## 参考资源

- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Token Permissions](https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token)
- [Workflow Commands](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions)
- [action-gh-release](https://github.com/softprops/action-gh-release)
