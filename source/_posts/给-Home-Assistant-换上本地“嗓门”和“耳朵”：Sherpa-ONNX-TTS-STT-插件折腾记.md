---
title: 给 Home Assistant 换上本地“嗓门”和“耳朵”：Sherpa-ONNX TTS/STT 插件折腾记
date: '2025-09-02 20:44:04'
updated: '2025-09-02 20:44:04'
tags:
- Home Assistant
- TTS
- STT
- Voice Assistant
- Offline
- Add-on
- Gemini
---

## 前言

&emsp;书接上回，在我为 Home Assistant 打造了一个强大的 MCP 代理服务，让它成功接入了 AI “大脑”之后，一个新的念头又冒了出来：一个真正智能的家居中枢，不仅要会“思考”，还应该能“听”会“说”，对吧？

&emsp;Home Assistant 的语音助手功能虽然越来越完善，但默认的方案大多依赖云服务。这不仅意味着我的语音指令需要在大洋彼岸绕一圈再回来，带来了恼人的延迟，更重要的是，一想到家里日常的对话可能会被送到某个服务器上，心里总觉得不太踏实。

&emsp;作为一个热爱“折腾”的 DIY 玩家，解决方案当然是：本地化！我要给我的 Home Assistant 换上完全离线的“嗓门”（TTS，文本转语音）和“耳朵”（STT，语音转文本）。经过一番研究，我发现了 `sherpa-onnx` 这个宝藏项目，并把它打包成了我现在要介绍的这个 Home Assistant 插件：[`sherpa-onnx-tts-stt`](https://github.com/ptbsare/home-assistant-addons/tree/main/sherpa-onnx-tts-stt) (https://github.com/ptbsare/home-assistant-addons/tree/main/sherpa-onnx-tts-stt)。

## ✨ 主要特性

&emsp;这个插件的核心就是“离线”和“高性能”，旨在为你的智能家居提供一个既快又私密的语音交互中枢。

*   **完全离线，保护隐私**：所有的语音识别和语音合成都在你的本地设备上完成，语音数据足不出户，完美解决了隐私顾虑。

*   **极速响应，告别延迟**：没有了网络传输的延迟，语音助手的响应速度得到了质的飞跃。无论是执行指令还是语音播报，都如行云流水般顺畅。

*   **标准协议，无缝集成**：插件通过 Wyoming 协议与 Home Assistant 对接，这是 HA 官方推荐的语音集成方式，确保了最佳的兼容性和稳定性。

*   **兼容 OpenAI API**：除了 Wyoming，我还为它添加了兼容 OpenAI 格式的 TTS/STT API 接口。这意味着，你不仅可以在 HA 中使用它，还可以将它作为一个独立的、可供其他应用调用的本地语音服务。

*   **丰富的模型选择**：插件内置了多种预训练的 `sherpa-onnx` 模型，包括中文、中英混合甚至多语言模型，你可以根据自己的硬件性能和偏好，选择最适合你的“嗓音”和“听力”。当然，也支持加载自定义模型。

## 开发动机

&emsp;开发这个插件的动机，源于我对智能家居体验的极致追求。我认为，一个真正“智能”的家，应该是可靠、迅速且尊重隐私的。将语音交互这个核心功能本地化，是实现这一目标的关键一步。

&emsp;有了本地的 TTS 和 STT，我的 Home Assistant 才算真正拥有了属于自己的“嘴巴”和“耳朵”，而不再是一个依赖云端的“传声筒”。现在，无论是让它播报天气，还是通过语音指令控制全屋灯光，都变得更加自然和可靠。

## 总结

&emsp;如果你也想让你的 Home Assistant 拥有一个更私密、更高效的语音助手，不妨来试试这个插件。它同样收录在我的 Home Assistant 插件仓库 [`home-assistant-addons`](https://github.com/ptbsare/home-assistant-addons) (https://github.com/ptbsare/home-assistant-addons) 中。

&emsp;这篇文章当然也是在我的好伙伴 Gemini 的帮助下完成的，哈哈哈！