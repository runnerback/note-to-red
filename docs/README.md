# docs —— 插件开发元文档与工具

本目录集中存放**两个插件（note-to-red / wechat-converter）共用**的元文档和开发工具。

> 为什么放在 `note-to-red/docs/`？
> `obsidian-plugin/` 下只有 `note-to-red` 和 `obsidian-wechat-converter` 两个子目录是 git 仓库；顶层的散落文件无处被版本控制。因此把跨插件的文档/脚本收进 `note-to-red` 仓库的 `docs/` 里统一跟踪。这不是“干净归属”（这些内容同时关系到两个插件），只是为了有版本管理，聊胜于无。

## 目录内容

| 文件 | 说明 |
|------|------|
| `开发工作流.md` | 核心文档：如何构建、部署、日常开发循环、验证、回滚、常见坑。**先看这个。** |
| `deploy-to-vault.sh` | 部署脚本：把两个仓库的构建产物复制进真实 Obsidian Vault。只复制 `manifest.json`/`main.js`/`styles.css`，**从不碰 `data.json`**。 |
| `代码分析报告.md` | note-to-red 的代码评审报告（优点 / 不足 / 二次开发指引）。 |

> wechat-converter 的代码分析报告在 `obsidian-wechat-converter/docs/代码分析报告.md`（保留在各自仓库）。

## 快速上手

```bash
# 1. 构建（首次需先 npm install，wechat 需 --legacy-peer-deps）
cd ../ && npm run build                                   # note-to-red
cd ../../obsidian-wechat-converter && npm run build       # wechat-converter

# 2. 部署进 Vault
cd ~/Documents/MediaCrawlerPro/obsidian-plugin/note-to-red/docs
./deploy-to-vault.sh all

# 3. Obsidian 里 Cmd+P → Reload app without saving
```

细节见 `开发工作流.md`。

## `deploy-to-vault.sh` 用法

```bash
./deploy-to-vault.sh                # 部署两个插件
./deploy-to-vault.sh note-to-red    # 仅 note-to-red
./deploy-to-vault.sh wechat         # 仅 wechat-converter
OBSIDIAN_VAULT="/path/to/vault" ./deploy-to-vault.sh all   # vault 换位置时覆盖
```
- 路径相对脚本自身解析，脚本移动后仍可用（默认 REPO_ROOT = 本文件上两级 = `obsidian-plugin/`）。
- Vault 路径默认写死为当前机器；换机器/换库用 `OBSIDIAN_VAULT` 覆盖。

## 安全约定

- ⚠️ **不要把 `data.json` 放进任何仓库目录**（含 appSecret / 微信账号 / AI key）。两仓库 `.gitignore` 已忽略 `data.json`，但也不要 `git add -f`。
- 需要备份 `data.json` 时，复制到**仓库之外**（如 `~/obsidian-plugin-backups/`）。
- 这个 `deploy-to-vault.sh` 里含本机个人绝对路径（vault 位置）。若将来把 note-to-red 仓库公开，注意此项与文档中的个人路径。
