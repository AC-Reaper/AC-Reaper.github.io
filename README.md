# Eric's Blog

我的个人博客，托管在 GitHub Pages。

- 网址（推送之后即生效）：<https://AC-Reaper.github.io/>
- 框架：[Hugo](https://gohugo.io/) v0.139+ extended
- 主题：[PaperMod](https://github.com/adityatelange/hugo-PaperMod)
- 部署：GitHub Actions，推送 `main` 即自动构建发布
- 语言：中文（默认）+ English

---

## 一、首次部署到 GitHub Pages（**只做一次**）

### 1. 在 GitHub 创建仓库

仓库名必须严格写成 **`AC-Reaper.github.io`**（用户名 + `.github.io`，这是 GitHub Pages 的约定）。

可见性建议 **Public**（Public 仓库的 Pages 是完全免费的）。

> 创建仓库时**不要勾选** "Add a README" / "Add .gitignore" / "Add a license"，
> 直接生成一个空仓库就行 —— 本地的文件会推上去。

### 2. 把本地这个文件夹推到 GitHub

在 **本博客文件夹** 里打开终端，依次执行：

```bash
git init
git branch -M main
git add .
git commit -m "init: hugo + papermod blog"
git remote add origin https://github.com/AC-Reaper/AC-Reaper.github.io.git
git push -u origin main
```

> 如果是第一次用 git 推到 GitHub，可能要登一下：
> - 简单做法：用 [GitHub Desktop](https://desktop.github.com/) 或 [gh CLI](https://cli.github.com/) 完成认证一次即可
> - 或者用 SSH key：[官方教程](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

### 3. 在仓库设置里打开 GitHub Pages

打开 GitHub 仓库 → **Settings** → 左侧 **Pages** → 找到 **Build and deployment** 这一栏 →
**Source** 下拉选 **`GitHub Actions`**（不是 "Deploy from a branch"）。

保存后第一次推送会自动触发构建。

### 4. 看构建结果

在仓库主页点 **Actions** 标签页，你会看到一个 "Deploy Hugo site to Pages" 在跑。
绿勾出现后，访问 <https://AC-Reaper.github.io/> 就能看到博客了（首次部署可能要等 1-2 分钟生效）。

---

## 二、之后写新文章的流程

### 方式 A — 让 Claude 帮你写

直接告诉 Claude："**写一篇关于 XXX 的文章**"，Claude 会：

1. 在 `content/zh/posts/` 下新建 `.md`
2. 自动加好 frontmatter（标题、日期、标签等）
3. 写完后告诉你 `git push` 一下就发布了

### 方式 B — 自己写

```bash
# 1. 新建文章（如果本地装了 hugo）
hugo new content zh/posts/我的新文章.md

# 或者纯手动：复制一份现成文章改一下
cp content/zh/posts/hello-world.md content/zh/posts/my-new-post.md

# 2. 编辑文件，把 frontmatter 改一下：
#    title: 新标题
#    date:  改成今天
#    draft: false      ← 这一行很重要，true 的话不会发布
#    tags:  [...]
#    categories: [...]
#
# 3. 推送
git add .
git commit -m "post: 新文章标题"
git push
```

push 之后 30~60 秒，新文章就出现在博客上了。

### 中英双语？

把同名文件分别放到两个目录就行：

```
content/zh/posts/my-post.md     ← 中文版
content/en/posts/my-post.md     ← 英文版
```

只写一种语言也完全可以，Hugo 只会在对应语言下显示有内容的那部分。

---

## 三、本地预览（可选，但强烈推荐）

如果你想在推送之前看看效果：

### 安装 Hugo

**macOS（Homebrew）**：
```bash
brew install hugo
```

**Windows（Scoop）**：
```bash
scoop install hugo-extended
```

**或下载二进制**：<https://github.com/gohugoio/hugo/releases>（一定要选 **extended** 版本）

### 第一次跑：先拉主题

```bash
git clone --depth=1 https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
```

（主题在 `.gitignore` 里，不进 git 仓库，所以每个本地副本要自己拉一次）

### 启动预览服务器

```bash
hugo server -D
```

浏览器打开 <http://localhost:1313>，改 markdown 文件会自动热刷新。`-D` 表示连 draft 一起预览。

---

## 四、目录结构说明

```
blog/
├── hugo.toml                       # 主配置：双语、菜单、主题参数
├── archetypes/default.md           # `hugo new` 用的文章模板
├── content/
│   ├── zh/                         # 中文内容
│   │   ├── _index.md               # 中文首页
│   │   ├── about.md                # 关于
│   │   ├── archives.md             # 归档页
│   │   ├── search.md               # 搜索页
│   │   └── posts/                  # 文章
│   └── en/                         # 英文内容（结构同上）
├── static/                         # 直接拷到站点根的静态文件（favicon、图片等）
├── assets/                         # 需要 Hugo 处理的资源（SCSS 等）
├── layouts/                        # 自定义模板覆盖（一般不用动）
├── themes/                         # PaperMod 主题（被 .gitignore，本地自行拉取）
├── .github/workflows/hugo.yml      # GitHub Actions 自动部署
├── .gitignore
└── README.md
```

---

## 五、常用调整

| 想改什么 | 改哪儿 |
|---|---|
| 博客标题 | `hugo.toml` 里的 `title` |
| 首页问候语 | `hugo.toml` → `languages.zh.params.profileMode` |
| 导航菜单 | `hugo.toml` → `languages.zh.menu.main` |
| 社交图标 | `hugo.toml` → `[[params.socialIcons]]` |
| 头像图片 | 放到 `static/img/avatar.jpg`，再把 `profileMode.imageUrl` 设成 `/img/avatar.jpg` |
| favicon | 放一个 `favicon.ico` 到 `static/` |
| 主题深浅 | `params.defaultTheme` 改 `dark`/`light`/`auto` |

---

## 六、之后可以加的功能（按需）

- **评论系统**：[Giscus](https://giscus.app/zh-CN)（GitHub Discussions 驱动，纯免费）
- **统计**：Umami / Plausible / 简易版 Google Analytics
- **自定义域名**：在 `static/` 放 `CNAME` 文件，去域名注册商配 CNAME 记录
- **文章封面图自动生成**：用 Hugo 的 image processing + OG image 生成模板

---

## 七、常见问题

**Q: push 之后 Actions 失败了？**
点进失败的那次 Action，看红色那一步的报错。最常见的原因是 `hugo.toml` 写错了符号（少了引号、多了逗号）。

**Q: 文章没出现在网站上？**
检查文章 frontmatter 里 `draft: false`（不是 `true`），并且 `date` 不是未来时间。

**Q: 想换主题？**
1. 改 `hugo.toml` 里的 `theme = "新主题名"`
2. 改 workflow 里那行 `git clone` 的仓库地址
3. 推送，搞定

**Q: 中文字数统计为 0？**
`hugo.toml` 里必须有 `hasCJKLanguage = true`（已配置好）。

---

写于 2026-05-28 · 祝你写得开心 ✍️
