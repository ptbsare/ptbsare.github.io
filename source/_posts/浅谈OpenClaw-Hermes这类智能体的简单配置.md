---
title: 浅谈OpenClaw/Hermes这类智能体的简单配置
date: '2026-05-14 14:12:31'
updated: '2026-05-14 14:12:31'
tags:
- MCP 
- Hermes 
- Openclaw 
---
## 前言
&emsp;其实用Hermes和OpenClaw有一段时间了。一开始我们发现OpenClaw呢，响应速度极慢，然后切换到了Hermes。最终通过阅读session日志才发现，其实每次对话，不管是Hermes也好，还是OpenClaw也好，它会在system prompts里面塞进去大量的指令性质的上下文信息。很多信息呢，在你不用这些功能是完全没有必要的。而我在使用Pi Agents，尤其做代码任务的时候，会发现初始响应非常快。原因是这样的Pi Agent初始的是配置是非常精简的，也就是system prompt里面是比较少的，所以我就有了精简Hermes的想法。其实一开始我用这种大模型Agent只是方便，比如说微信这样的平台连接这种机器人一个助手的存在。所以我不需要它附带太过沉重的工具上下文，其实也不需要什么自我进化创建skill。需要精简一下。
## 工具
&emsp;首先当然是精简它的工具的数量。因为每一个工具其实会附带大量的上下文信息，包括工具描述以及参数描述，以调用方法、例子什么等之类的。个人目前其实非常遵循Pi agent的理念，也就是Pi agent在默认情况下，它其实只提供了少数三四个工具，比如说文件的读写以及执行Bash命令，仅此而已。我觉得这个已经满足了对一个Agent最核心的最小需求。正常来讲，默认的toolset其实是很多的一大类工具集，包含了附带的所有工具，这个是很大包袱。对于OpenClaw和Hermes这种Agent跟Pi Agent又不太一样。你如果作为一个微信助手的话，一个定时任务的工具还是有一点用处，以及这个图像处理的能力，也就是Vision。所以我对于微信呢，我只定义了这四个工具集，config的里面。
```yaml
platform_toolsets: 
  weixin:
    - terminal
    - file
    - vision
    - cronjob

```
实测，这种精简的config其实排除掉非常大一部分的工具描述上下文，简单需求的响应会提速。
## skill
因为我的主要工具主要集成在MCP Hub里面，通过MCP的智能路由只暴露给大模型两个工具，一个是search tool，一个是call tool，对于没有接入的，完全可以让大模型随顺手写一个MCP Server。所以对于 skill的需求不是太大，而且一旦开启了skill，哪怕你的只有一个skill的话，它也会塞一大堆的system prompt对skill的描述之类的，以及指引指导。所以这部分我不想太需要，所以我就把所有的skill都移除了。
## soul.md及memory.md
对于Hermes这类智能体来说，当然记忆以及用户画像是一个杀手级的功能。但是实测每个system prompt里面都会包含完整的这两个文件内容。所以为了精简起见，我这就去在soul的里面只是最小化，就说你叫什么，仅此而已。记忆这边留空就行了。

## 剩余
&emsp;精简到这个地步以后，实测这个prompt已经比较精简了，就只剩下平台相关内置的这些工具描述。比如说你在微信渠道，它会插入微信渠道的，包括发送文件的指引，这个还是有一点作用，暂且不删。还有以及当前的系统运行、操作系统的环境之类的，这个也比较少几个字。但是呢，我这边测下来其实还有一个又冗长的教你如何修复Hermes的skill prompt，这个是官方硬编码的，去不掉，我在GitHub已经提交了[bug report](https://github.com/NousResearch/hermes-agent/issues/24438)，待官方解决。其余就没啥了，实测下来其实这个响应速度和Pi agent它也差不了多少了。我的所有工具都在MCP服务器里面接入，禁用resource和prompt，通过MCP只暴露两个工具。
## 关于网络
&emsp;其实对于最小化agent来讲，现在这个时代，agent其实还有两个需要添加的核心工具，一个是网络搜索的能力。一个是爬取网页能力。到目前为止，其实这种好用的爬取工具其实并不太多。我们能看到像Codex这样的，通过浏览器扩展以及图像识别技术，非常快速地通过操纵浏览器的skill，这个真的让人眼前一亮。但是大量的脚本类的工具目前来讲呢，要么就是付费的，要么就是效果问题。我目前通过MCP接入的搜索工具是用我自建的Seaxng以及基于scapling写的一个MCP服务器，有兴趣可以看下[sscrapling-mcp- server](https://github.com/ptbsare/scrapling-mcp-server)在官方爬虫的基础上，支持了Cookie导入，方便爬取一些需要登录的网站，我的Hermes是部署在一个单独的虚拟机上，所以浏览器的Cookie完全都可以通过Cookie cloud扩展以及自建服务通过脚本，来定期同步即可。如果你用的是Pi Agent，我非常推荐这个插件，其实蛮不错的，集成了网页AIO能力[pi-webaio](https://github.com/apmantza/pi-webaio)。