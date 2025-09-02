---
title: 最近我用 Gemini “造” 的几个 MCP 服务器小工具
date: '2025-09-02 18:30:05'
updated: '2025-09-02 18:30:05'
tags:
- MCP
- Gemini
- AI
- Python
- Node.js
- Tools
---

## 前言

&emsp;最近一段时间，我迷上了探索大语言模型（LLM）的能力边界，特别是如何让它们与真实世界的各种服务进行交互。模型上下文协议（Model Context Protocol, MCP）为我们提供了一个绝佳的框架，可以将各种功能封装成 AI 可调用的工具。在 Gemini 的强大辅助下，我集中开发了一系列五花八门的 MCP 服务器，将一些有趣或实用的小功能“AI 化”。这既是一次有趣的技术探索，也让我对未来 AI Agent 的形态有了更深的思考。

&emsp;下面就来逐一介绍一下这些新鲜出炉的小工具。

## 德州扑克赔率计算器

([`texas-pokker-odds-mcp-server`](https://github.com/ptbsare/texas-pokker-odds-mcp-server)) (https://github.com/ptbsare/texas-pokker-odds-mcp-server)

&emsp;和朋友玩德州扑克时，你是否也曾好奇过，自己手上的这把牌，在翻牌或转牌后，究竟有多大的胜算？这个小工具就是为此而生。它通过蒙特卡洛模拟，可以快速计算出多手牌在给定公共牌情况下的胜、负、平概率。

&emsp;我将它封装成 MCP 服务后，现在可以直接问我的 AI 助手：“我的手牌是 AsKd，对手是 7c8h，公共牌是 2h3d4s，帮我算算胜率”，它就能立即调用工具并给出精确的概率。这无疑为游戏增添了更多的策略和乐趣。

## 搜狗微信文章搜索

([`sogou-weixin-mcp-server`](https://github.com/ptbsare/sogou-weixin-mcp-server)) (https://github.com/ptbsare/sogou-weixin-mcp-server)

&emsp;微信公众号无疑是一个巨大的信息源，但其封闭的生态也造成了信息检索的困难。为了让 AI 能够触及到这部分信息，我利用搜狗微信搜索的接口，开发了这个 MCP 服务器。

&emsp;现在，我可以让 AI 帮我搜索特定主题的微信文章，并对结果进行总结和分析，极大地拓宽了 AI 的信息获取范围。

## 离线加密货币地址生成器

([`gen-blockchain-addr-mcp-server`](https://github.com/ptbsare/gen-blockchain-addr-mcp-server)) (https://github.com/ptbsare/gen-blockchain-addr-mcp-server)

&emsp;在 Web3 的世界里，私钥和助记词的安全至关重要。任何在线的地址生成器都存在私钥泄露的风险。因此，我开发了这个完全离线的加密货币地址生成工具。

&emsp;它支持 BTC、ETH、TRX 等多种主流加密货币，并且所有操作都在本地完成，确保你的资产绝对安全。通过 MCP 封装，我可以让 AI 在需要时安全地生成地址，而无需担心助记词在网络中传输。

## 远程/本地命令执行器

([`terminal-mcp-server`](https://github.com/ptbsare/terminal-mcp-server)) (https://github.com/ptbsare/terminal-mcp-server)

&emsp;这可以说是这次开发的工具中最强大的一个。它让 AI 具备了直接操作服务器的能力。这个 MCP 服务器可以：

*   通过 SSH 在远程主机上执行命令，并能自动解析 `~/.ssh/config` 配置。
*   在运行服务器的本地机器上执行命令。

&emsp;这意味着我可以让 AI 帮我完成一些简单的运维任务，比如“帮我登录到我的 NAS，查看 Docker 容器的状态”，或者“在本地运行一下 `ls -la` 看看当前目录的文件”。这为实现更复杂的 AI Agent 自动化工作流打开了大门。

## 邮件客户端

([`email-mcp-server`](https://github.com/ptbsare/email-mcp-server)) (https://github.com/ptbsare/email-mcp-server)

&emsp;邮件至今仍然是重要的沟通工具。这个 MCP 服务器让 AI 拥有了收发邮件的能力。它通过 POP3 读取邮件，通过 SMTP 发送邮件，并且支持 TLS 加密。

&emsp;现在，我可以让 AI 帮我“检查一下收件箱里有没有新邮件”，或者“帮我给 xxx 写一封邮件，内容是...”，让 AI 成为我真正的个人助理。

## Overseerr 接口

([`overseerr-mcp-server`](https://github.com/ptbsare/overseerr-mcp-server)) (https://github.com/ptbsare/overseerr-mcp-server)

&emsp;如果你和我一样，也是个 NAS 玩家，并且使用 Overseerr 来管理家庭影音库的请求，那么这个工具你一定会喜欢。它将 Overseerr 的 API 封装成了 MCP 工具。

&emsp;我可以随时问 AI：“帮我看看最近有哪些电影请求已经可以播放了？”，或者“帮我搜索一下《沙丘2》，然后为用户 ptbsare 请求这部电影”。这让家庭媒体中心的管理变得前所未有的简单和智能。

## 总结

&emsp;这次集中的开发过程，Gemini 扮演了至关重要的角色。从代码实现、调试，到编写 `README` 文档，它都为我提供了极大的帮助，让我能够将精力更集中在功能设计和整体架构上。

&emsp;通过这些小工具，我真实地感受到了 MCP 协议的强大之处。它像一座桥梁，连接了大型语言模型的“大脑”和我们现实世界中各式各样的“手脚”（服务）。我相信，随着 MCP 生态的不断发展，未来将会涌现出更多、更有趣的 AI Agent 应用，让我们的数字生活变得更加智能和便捷。

本博文由Gemini辅助，哈哈哈