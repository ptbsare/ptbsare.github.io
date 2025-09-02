---
title: Anx Calibre Manager：一个现代化的电子书库管理工具
date: '2025-09-02 18:07:00'
updated: '2025-09-02 18:07:00'
tags:
- Calibre
- Docker
- Web
- Ebook
- KOReader
- Kindle
- Python
- Flask
- Anx Reader
- Tips
---

## 前言

&emsp;作为一名电子书爱好者，多年来我一直使用 Calibre 来管理我日益增长的书库。Calibre 功能强大，无愧于“瑞士军刀”的称号。然而，在移动设备上管理和访问书库一直是个痛点。官方的 Calibre Content Server 界面略显陈旧，在手机上的体验不佳；而市面上的第三方应用，要么功能有限，要么界面不符合我的审美。

&emsp;后面测试对比了几款读书APP看中了Anx Reader这款读书APP主要看中了它可以免费提供webdav同步的功能，有听书和大模型总结功能可以在上下班路上没事听听书比看书更快；

&emsp;因此，我经常在不同的设备上阅读，比如手机、平板上的Anx Reader阅读听书； KOReader 和 Kindle。如何在这些设备之间同步阅读进度，并将书籍方便地推送到特定设备，也是一个长期困扰我的问题。为了解决这些痛点，我决定自己动手，借助Gemini开发一款现代化的、移动优先的电子书库管理工具——Anx Calibre Manager。

&emsp;现在大模型写代码已经非常方便，基本是提出需求-撰写代码-自行测试-修复bug-提交代码；其中要将一个大的目标逐渐分解模块化分成一个个小任务让大模型解决，然后不断审核代码，提出改进，测试bug，修复问题，如此往复。

## ✨ 主要功能

&emsp;Anx Calibre Manager 的核心设计理念是“移动优先”和“一体化”。它不仅是一个漂亮的 Calibre 前端，更是一个集成了多种实用功能的服务端应用。

- **多语言支持**：完整的国际化支持，界面提供英语、简体中文、繁体中文、西班牙语、法语和德语。
- **移动优先界面**：一个简洁、响应式的用户界面，专为在手机上轻松使用而设计。
- **PWA 支持**：可作为渐进式 Web 应用安装，提供类似原生的体验。
- **Calibre 集成**：连接到你现有的 Calibre 服务器，以浏览和搜索你的书库。
- **KOReader 同步**：与 KOReader 设备同步你的阅读进度和阅读时间。
- **智能发送到 Kindle**：在发送到 Kindle 时自动处理格式。如果存在 EPUB 格式，则直接发送。否则，应用会根据你的偏好将最佳可用格式**转换为 EPUB** 再发送，确保最佳兼容性。
- **推送到 Anx**：将你的 Calibre 书库中的书籍直接发送到你的个人 Anx-reader 设备文件夹。
- **集成的 WebDAV 服务器**：每个用户都有自己安全的 WebDAV 文件夹，与 Anx-reader 和其他 WebDAV 客户端兼容。
- **MCP 服务器**：一个内置的、兼容的 MCP（模型上下文协议）服务器，允许 AI 代理和外部工具安全地与你的书库互动。
- **用户管理**：简单的内置用户管理系统，具有不同的角色：
    - **管理员**：完全控制用户、全局设置和所有书籍。
    - **维护者**：可以编辑所有书籍的元数据。
    - **用户**：可以上传书籍，管理自己的 WebDAV 书库、MCP 令牌，发送书籍到 Kindle，并**编辑自己上传的书籍**。
- **用户可编辑上传的书籍**：普通用户现在可以编辑他们上传的书籍的元数据。此功能依赖于一个名为 `#library` 的 Calibre 自定义列（类型为 `Text, with commas treated as separate tags`）。当用户上传一本书时，他们的用户名会自动保存到此字段中。然后，用户可以编辑 `#library` 字段中列为所有者的任何书籍。
    - **对 Docker 用户的建议**：要启用此功能，请确保你的 Calibre 书库中有一个名为 `#library`（区分大小写）的自定义列，类型为 `Text, with commas treated as separate tags`。
- **轻松部署**：可作为单个 Docker 容器部署，内置多语言区域设置支持。
- **阅读统计**：自动生成个人阅读统计页面，包括年度阅读热力图、正在阅读的书籍列表和已读完的书籍列表。该页面可以公开分享或保持私有。

## 📸 界面截图

<p align="center">
  <em>主界面</em><br>
  <img src="Anx-Calibre-Manager：一个现代化的电子书库管理工具/Screen Shot - MainPage.png">
</p>
<p align="center">
  <em>设置页面</em><br>
  <img src="Anx-Calibre-Manager：一个现代化的电子书库管理工具/Screen Shot - SettingPage.png">
</p>

| MCP 聊天 | MCP 设置 |
| :---: | :---: |
| <img src="Anx-Calibre-Manager：一个现代化的电子书库管理工具/Screen Shot - MCPChat.jpg" width="350"/> | <img src="Anx-Calibre-Manager：一个现代化的电子书库管理工具/Screen Shot - MCPSetting.png" width="650"/> |

| Koreader 书籍状态 | Koreader 同步 |
| :---: | :---: |
| <img src="Anx-Calibre-Manager：一个现代化的电子书库管理工具/Screen Shot - KoreaderBookStatus.jpg" width="400"/> | <img src="Anx-Calibre-Manager：一个现代化的电子书库管理工具/Screen Shot - KoreaderSync.jpg" width="400"/> |

| Koreader 设置 | Koreader WebDAV |
| :---: | :---: |
| <img src="Anx-Calibre-Manager：一个现代化的电子书库管理工具/Screen Shot - KoreaderSetting.png" width="750"/> | <img src="Anx-Calibre-Manager：一个现代化的电子书库管理工具/Screen Shot - KoreaderWebdav.jpg" width="250"/> |

<p align="center">
  <em>统计页面</em><br>
  <img src="Anx-Calibre-Manager：一个现代化的电子书库管理工具/Screen Shot - StatsPage.png">
</p>

## 🚀 部署指南

&emsp;与我之前的许多项目一样，Anx Calibre Manager 也被打包成了 Docker 镜像，可以轻松地一键部署。

### 先决条件

-   你的服务器上已安装 [Docker](https://www.docker.com/get-started)。
-   一个现有的 Calibre 服务器（可选，但大部分功能需要它）。

### 使用 Docker 运行

1.  **获取你的用户和组 ID (PUID/PGID):**
    在你的主机上运行 `id $USER` 来获取你的用户的 UID 和 GID。这对于避免挂载卷的权限问题至关重要。

    ```bash
    id $USER
    # 示例输出: uid=1000(myuser) gid=1000(myuser) ...
    ```

2.  **创建用于持久化数据的目录：**
    你需要为配置/数据库和 WebDAV 数据分别创建目录。

    ```bash
    mkdir -p /path/to/your/config
    mkdir -p /path/to/your/webdav
    mkdir -p /path/to/your/fonts # 可选：用于自定义字体
    ```

3.  **运行 Docker 容器：**
    你可以使用 `docker run` 或 `docker-compose.yml` 文件。

    **使用 `docker run`:**

    ```bash
    docker run -d \
      --name anx-calibre-manager \
      -p 5000:5000 \
      -e PUID=1000 \
      -e PGID=1000 \
      -e TZ="America/New_York" \
      -v /path/to/your/config:/config \
      -v /path/to/your/webdav:/webdav \
      -v /path/to/your/fonts:/opt/share/fonts \ # 可选：挂载自定义字体
      -e "GUNICORN_WORKERS=2" \ 
      -e "SECRET_KEY=your_super_secret_key" \
      -e "CALIBRE_URL=http://your-calibre-server-ip:8080" \
      -e "CALIBRE_USERNAME=your_calibre_username" \
      -e "CALIBRE_PASSWORD=your_calibre_password" \
      --restart unless-stopped \
      ghcr.io/ptbsare/anx-calibre-manager:latest
    ```

    **使用 `docker-compose.yml`:**

    创建一个 `docker-compose.yml` 文件：
    ```yaml
    version: '3.8'
    services:
      anx-calibre-manager:
        image: ghcr.io/ptbsare/anx-calibre-manager:latest
        container_name: anx-calibre-manager
        ports:
          - "5000:5000"
        volumes:
          - /path/to/your/config:/config
          - /path/to/your/webdav:/webdav
          - /path/to/your/fonts:/opt/share/fonts # 可选：挂载自定义字体
        environment:
          - PUID=1000
          - PGID=1000
          - TZ=America/New_York
          - GUNICORN_WORKERS=2 # 可选：自定义 Gunicorn 工作进程数
          - SECRET_KEY=your_super_secret_key
          - CALIBRE_URL=http://your-calibre-server-ip:8080
          - CALIBRE_USERNAME=your_calibre_username
          - CALIBRE_PASSWORD=your_calibre_password
          - CALIBRE_DEFAULT_LIBRARY_ID=Calibre_Library
          - CALIBRE_ADD_DUPLICATES=false
        restart: unless-stopped
    ```
    然后运行：
    ```bash
    docker-compose up -d
    ```

### 自定义字体

&emsp;书籍转换工具 `ebook-converter` 会扫描 `/opt/share/fonts` 目录以查找字体。如果你在转换带有特殊字符（例如中文）的书籍时遇到字体相关问题，可以通过将包含字体文件（例如 `.ttf`、`.otf`）的本地目录挂载到容器的 `/opt/share/fonts` 路径来提供自定义字体。

## 📖 KOReader 同步

&emsp;你可以在你的 Anx 书库和 KOReader 设备之间同步你的阅读进度和阅读时间。设置过程包括两个主要步骤：设置 WebDAV 以访问你的书籍，以及配置同步插件以处理进度同步。详细步骤请参考项目 [README](https://github.com/ptbsare/anx-calibre-manager/blob/main/README_zh-Hans.md#koreader-sync)。

## 🤖 MCP 服务器

&emsp;本项目包含一个兼容 JSON-RPC 2.0 的 MCP（模型上下文协议）服务器，允许外部工具和 AI 代理与你的书库进行交互。你可以通过生成 Token，并向 `http://<your_server_address>/mcp` 端点发送请求来使用它。

支持的工具包括：

- `search_calibre_books`: 使用 Calibre 强大的搜索语法搜索书籍。
- `get_recent_calibre_books`: 获取 Calibre 书库中的最近书籍。
- `get_calibre_book_details`: 获取特定 Calibre 书籍的详细信息。
- `get_recent_anx_books`: 获取 Anx 书库中的最近书籍。
- `get_anx_book_details`: 获取特定 Anx 书籍的详细信息。
- `push_calibre_book_to_anx`: 将 Calibre 书籍推送到 Anx 书库。
- `send_calibre_book_to_kindle`: 将 Calibre 书籍发送到 Kindle。

## 配套 Calibre 插件

&emsp;除了 `Anx Calibre Manager` 这个服务端应用，我还开发了一个配套的 Calibre 客户端插件：[`anx-reader-calibre-plugin`](https://github.com/ptbsare/anx-reader-calibre-plugin)。

&emsp;这个插件可以让你在 Calibre 客户端中创建一个“ANX 虚拟设备”，从而直接管理位于 NAS 或服务器上的 `ANX 阅读器` 书库。你可以利用 Calibre 强大的元数据编辑功能，来维护 `ANX 阅读器` 的数据库和文件，并通过“发送到设备”和“从设备删除”功能，方便地同步书籍。

&emsp;这两个项目相辅相成，为你提供了一个完整的电子书管理生态：

*   **在 PC 端**：使用 `anx-reader-calibre-plugin` 插件，在 Calibre 客户端方便地整理书籍、编辑元数据。
*   **在移动端**：通过 `Anx Calibre Manager`，在手机、平板等设备上随时随地访问、阅读和同步这些书籍。

## 总结

&emsp;Anx Calibre Manager 是我为了解决个人在电子书管理和阅读中的痛点而开发的项目。它将 Calibre 的强大功能与现代 Web 技术相结合，提供了一个美观、易用且功能丰富的解决方案。无论你是希望在手机上更方便地管理书库，还是希望在不同设备间无缝同步阅读进度，抑或是希望通过 API 与你的书库进行交互，Anx Calibre Manager 都能满足你的需求。

&emsp;欢迎大家试用，并在 [GitHub](https://github.com/ptbsare/anx-calibre-manager) 上提出你的宝贵意见和建议！

这篇博文也由Gemini辅助，哈哈哈

## 📊 我的实时阅读统计

&emsp;最后，再展示一下 Anx Calibre Manager 自动生成的阅读统计页面，是不是很炫酷？下面就是我个人的实时阅读统计数据：

<div style="position: relative; padding-bottom: 120%; height: 0; overflow: hidden;">
<iframe src="https://v.ptbsare.org:33888/stats/ptbsare" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none;"></iframe>
</div>