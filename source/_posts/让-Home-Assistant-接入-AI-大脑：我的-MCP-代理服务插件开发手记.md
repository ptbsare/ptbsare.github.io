---
title: 让 Home Assistant 接入 AI 大脑：我的 MCP 代理服务插件开发手记
date: '2025-09-02 20:44:04'
updated: '2025-09-02 20:44:04'
tags:
- Home Assistant
- MCP
- AI
- Docker
- Add-on
- Gemini
---

## 前言

&emsp;自从上一篇博文分享了我用 Gemini 开发的一系列 MCP 服务器小工具后，我越发觉得 MCP 协议的潜力巨大。它就像一个“万能插座”，能让 AI 大脑轻松地连接上各种各样的“电器”（服务）。但很快，一个新的问题摆在了我面前：随着我开发的 MCP 服务器越来越多，管理它们成了一件麻烦事。每个服务器都需要单独配置、单独运行，AI 客户端也要配置好几个连接，这显然不够优雅。

&emsp;作为一个智能家居爱好者和 Home Assistant 的重度用户，我自然而然地想到了：能不能把这些 AI “超能力”都集中起来，然后接入到我的 Home Assistant 系统里呢？这样，我不仅能通过 HA 的自动化来调用这些 AI 工具，还能让我的智能家居真正拥有一个强大的“大脑”。

&emsp;于是，[`mcp-proxy-server`](https://github.com/ptbsare/home-assistant-addons/tree/main/mcp-proxy-server) (https://github.com/ptbsare/home-assistant-addons/tree/main/mcp-proxy-server) 这个 Home Assistant 插件应运而生。它不仅仅是一个简单的代理，更是一个 MCP 服务器的“大管家”。

## ✨ 主要特性

&emsp;这个插件的核心目标，就是“化繁为简，统一管理”。它作为一个 Home Assistant Add-on 运行，可以让你在熟悉的 HA 环境中，轻松管理所有的 MCP 服务器。

*   **MCP “大管家”**：它可以连接和管理各种类型的后端 MCP 服务器（无论是 Stdio、SSE 还是 HTTP 协议），然后将它们所有的工具聚合起来，通过一个统一的入口提供服务。从此，AI 客户端只需要连接这一个代理，就能使用所有的工具。

*   **直观的 Web UI 管理**：我为它开发了一个独立的 Web 管理界面。通过这个界面，你可以轻松地添加、编辑、启用或禁用后端的 MCP 服务器和它们提供的每一个工具，甚至可以重写工具的名称和描述，让它们更符合你的使用习惯。

*   **一键安装与实时日志**：对于那些需要安装步骤的 Stdio 服务器，你可以在 Web UI 里直接触发安装命令，并实时查看安装过程的日志输出，一切尽在掌握。

*   **灵活的接入方式**：代理服务本身也提供了多种协议（Stdio, SSE, HTTP）供 AI 客户端连接，你可以根据自己的需求选择最合适的方式。

*   **Home Assistant 无缝集成**：作为 HA 插件，它能很好地融入现有的系统，你可以通过 HA 的 `rest_command` 或其他集成来调用它提供的 AI 工具，实现各种有趣的自动化。

## 开发动机

&emsp;开发这个插件的动机其实很简单。一方面，是为了解决我自己“工具太多，管理不过来”的痛点。另一方面，我坚信，未来的智能家居，一定是以一个强大的 AI 大脑为核心，通过类似 MCP 这样的协议，去协调和控制各种设备与服务。

&emsp;这个 `mcp-proxy-server` 插件，就是我朝着这个方向迈出的一小步。它让 Home Assistant 不再仅仅是一个自动化规则的执行者，更成为了一个能够接入和管理 AI能力的平台。

## 总结

&emsp;如果你也和我一样，既是 Home Assistant 的爱好者，又对 AI 和 MCP 的世界充满好奇，那么我强烈推荐你试试这个插件。它收录在我的 Home Assistant 插件仓库 [`home-assistant-addons`](https://github.com/ptbsare/home-assistant-addons) (https://github.com/ptbsare/home-assistant-addons) 中，欢迎大家安装和体验！

&emsp;本博文由 Gemini 辅助，哈哈哈
