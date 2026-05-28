---
title: "用 Hugo + GitHub Pages 搭一个能写一辈子的博客"
date: 2026-05-28T14:30:00+08:00
draft: false
tags: ["Hugo", "GitHub Pages", "静态站点", "教程"]
categories: ["技术"]
description: "从零搭一个支持中英双语、自动部署的个人博客。"
ShowToc: true
TocOpen: false
cover:
  image: ""
  alt: ""
  hidden: true
---

第一篇技术文，就把这个博客自己是怎么搭起来的写了吧。

## 为什么选 Hugo

挑静态站点框架之前，我列了三个候选：Jekyll、Hexo、Hugo。最后选了 Hugo，原因很简单：

| 维度 | Jekyll | Hexo | Hugo |
|---|---|---|---|
| 语言 | Ruby | Node.js | Go（单二进制） |
| 构建速度 | 慢 | 中 | **极快**（毫秒级） |
| 环境配置 | 麻烦 | 中等 | **下载即用** |
| 中文支持 | 一般 | 好 | **好** |
| GitHub Pages 原生支持 | 是 | 否 | 否（需 Actions） |

Hugo 唯一的"缺点"是 GitHub Pages 不会自动给你构建，但配合 GitHub Actions 这个问题 5 分钟就能解决。

## 整体架构

```mermaid
flowchart LR
    A["📝 本地 Markdown"] -->|git push| B["🐙 GitHub 仓库 main"]
    B -->|GitHub Actions 构建| C["🌐 GitHub Pages"]
```

写完文章 push，剩下的事 GitHub 自动搞定。不需要本地构建，不需要折腾依赖。

## 几个我觉得值得记录的小决定

### 1. 双语用 `contentDir` 而不是文件名后缀

PaperMod 文档里两种都演示过。我选了目录分离：

```text
content/
  zh/posts/xxx.md
  en/posts/xxx.md
```

理由：以后中英文文章数量肯定不对称，混在一个目录里翻起来累。

### 2. 默认语言不放进 URL 子路径

```toml
defaultContentLanguageInSubdir = false
```

中文是默认语言，所以 `/posts/xxx/` 直接是中文；英文走 `/en/posts/xxx/`。
对国内读者更友好，对 SEO 也更干净。

### 3. 主题不进 Git 仓库

`.gitignore` 里直接忽略 `themes/`，让 GitHub Actions 构建时再 clone。
好处是仓库小、主题更新简单，不用维护 submodule 那一套。

### 4. 开 `hasCJKLanguage = true`

不开的话，中文文章的字数统计、摘要截断会全部出错。

## 写一篇新文章的流程

```bash
# 1. 拉个新文件
hugo new content zh/posts/my-new-post.md

# 2. 改完 draft: false，写内容

# 3. 提交
git add . && git commit -m "post: my new post" && git push
```

push 完，去 GitHub 看一眼 Actions 跑成功了，就完事了。

## 后续想加的东西

- [ ] 文章封面图自动生成
- [ ] 评论系统（Giscus）
- [ ] 阅读量统计
- [ ] 自定义域名

慢慢来。
