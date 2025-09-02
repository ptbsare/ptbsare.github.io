---
title: 门口的“动态便签”：我如何“魔改”开源墨水屏并接入 Home Assistant
date: '2025-09-02 21:00:00'
updated: '2025-09-02 21:00:00'
tags:
- Home Assistant
- E-Paper
- BLE
- Python
- Reverse Engineering
- DIY
- Gemini
---

## 前言：一个“贴心”的快递提醒装置

&emsp;自从住进现在的小区，如何有效地提醒快递和外卖小哥，就成了一个不大不小的烦恼。在门上贴纸条吧，不美观还容易掉；用智能门铃吧，又不是每次都方便接听。我一直在想，能不能在门口放一个“动态便签”，根据家里的情况，自动给他们显示不同的提醒？

&emsp;于是，我淘了一块巴掌大的蓝牙墨水屏。把它贴在门上，显示“快递请放门口，外卖请按门铃”，简直完美。但作为一个热爱“折腾”的智能家居玩家，我的野心不止于此。我发现，这块墨水屏的固件居然是开源的！项目地址在 [https://github.com/pengwon/epd42](https://github.com/pengwon/epd42)。

&emsp;一个大胆的想法瞬间点燃了我：既然固件是开源的，那通信协议肯定也能搞明白。我是不是可以自己写个程序，通过蓝牙控制它，然后把它接入我的 Home Assistant 系统，让它真正“智能”起来？说干就干！

## 技术探索：“庖丁解牛”般的协议分析

&emsp;我火速 clone 了 `pengwon/epd42` 的源码。通过分析其 C++ 代码，我很快就摸清了它与手机 App 之间的蓝牙 EPD（Electronic Paper Display）通信协议。这套协议的核心，就是通过一个特定的 BLE 服务（UUID: `62750001-...`）下的一个特征（UUID: `62750002-...`）进行数据读写。

&emsp;所有的操作都由一个命令字节（Command Byte）开头，后面跟着相应的数据。我将这些命令整理成了一个枚举类 `EpdCmd`：

```python
# src/main.py
class EpdCmd:
    INIT = 0x01      # 初始化设备，建立连接后第一步
    CLEAR = 0x02     # 清空屏幕
    REFRESH = 0x05   # 刷新屏幕，将缓冲区内容显示出来
    WRITE_IMG = 0x30 # 写入图像数据
    SET_TIME = 0x20  # 设置时间或切换模式（时钟/日历）
```

&emsp;其中最复杂的是 `WRITE_IMG` 命令。图像数据需要被分割成小的数据包（Chunk）进行传输，每个包的第一个字节是一个头部，用于标记这是不是一帧的开始（`0x00` vs `0xF0`）以及颜色信息。搞清楚了这一点，剩下的事情就是用我更熟悉的 Python，把这些操作复现一遍。

## 我的核心工具：`epd-ble-sender`

&emsp;为了方便地在我的 Home Assistant 主机（一台 x86 小服务器）上控制这块墨水屏，我开发了一个功能完善的命令行工具：[`epd-ble-sender`](https://github.com/ptbsare/epd-ble-sender)。这个工具是我这次“魔改”的核心，里面包含了不少值得分享的技术细节。

### 蓝牙通信的“快车道”：交错应答

&emsp;与墨水屏这种低功耗设备通信，效率至关重要。如果每发送一小段数据都等待设备确认（with response），那传一张图可能要等到天荒地老。通过分析源码和抓包，我发现了一个提高传输效率的关键：**交错应答（Interleaved Acknowledgement）**。

&emsp;在我的 `write_image_data` 函数中，我实现了一个 `interleaved_count` 参数。它的作用是，让我可以连续向墨水屏“投喂” N 个无需应答（without response）的数据包，然后再发送一个需要应答的包来“喘口气”，确保设备没有“噎着”。这样一来，数据传输就从“走一步，等一下”变成了“跑一程，歇一脚”，在保证稳定性的前提下，极大地提升了传输速度。

### 图像处理的“艺术”：颜色抖动

&emsp;要在只有黑白（或黑白红）两三种颜色的墨水屏上，显示出层次丰富的图像，可不是简单地把图片二值化那么简单。为了达到最佳的显示效果，我在脚本里集成了多种经典的**颜色抖动（Dithering）算法**。

```python
# src/main.py
def dither(image: Image.Image, palette: np.ndarray, algorithm: str):
    # ...
    matrices = {
        'floyd': ([[0, 0, 7], [3, 5, 1]], 16),
        'jarvis': ([[0,0,0,7,5],[3,5,7,5,3],[1,3,5,3,1]], 48),
        'stucki': ([[0,0,0,8,4],[2,4,8,4,2],[1,2,4,2,1]], 42),
        'atkinson': ([[0,0,1,1],[1,1,1,0],[0,1,0,0]], 8)
    }
    # ... 算法实现 ...
```

&emsp;比如 `Floyd-Steinberg` 算法，它会在处理每个像素时，把当前像素与调色板中最接近颜色的误差，按照一定的比例扩散给周围还未处理的像素。这样一来，即使只有黑白两色，也能在宏观上模拟出细腻的灰度过渡，让图片看起来不再生硬。这个小小的算法，是让墨水屏显示效果“从能看到能看好”的关键一步。

### 一个“小小”的文本排版引擎

&emsp;除了显示图片，我更希望墨水屏能动态显示文本。为此，我写了两个函数 `render_text_to_image` 和 `parse_line_markup`，它们构成了一个轻量级的文本排版引擎。

&emsp;我设计了一种简单的标记语言，可以在文本行首用方括号来定义样式，比如：

`[size=40, color=red, align=center] 快递请放门口`

&emsp;`parse_line_markup` 函数负责解析这些标记，而 `render_text_to_image` 则根据解析出的样式（字体、大小、颜色、对齐方式），使用 `Pillow` 库将文本绘制到一张空白的图片上。这样，我就能通过简单的文本输入，生成样式丰富的图片，极大地增强了动态显示的灵活性。

### 智能的命令行接口（完整版）

&emsp;为了方便在 Home Assistant 中调用，我用 `click` 库为这个工具打造了一个强大的命令行接口。核心的 `send` 命令几乎可以控制所有参数：

```bash
Usage: main.py send [OPTIONS]

  将图像或文本发送到设备。

Options:
  --address TEXT                  [必选] 设备的蓝牙地址。
  --adapter TEXT                  使用的蓝牙适配器，例如 hci0。
  --image PATH                    要发送的图片文件路径。
  --text TEXT                     要发送的文本内容，支持排版标记。
  --font TEXT                     渲染文本时使用的默认字体文件路径。
  --size INTEGER                  默认字体大小。
  --color TEXT                    默认文本颜色 (black, red, or white)。
  --bg-color [white|black|red]    渲染文本时的背景色。
  --width INTEGER                 手动指定屏幕宽度。
  --height INTEGER                手动指定屏幕高度。
  --clear / --no-clear            发送前是否清屏。
  --color-mode [bw|bwr]           颜色模式：bw (黑白) 或 bwr (黑白红)。
  --dither [auto|none|floyd|atkinson|jarvis|stucki|bayer]
                                  颜色抖动算法。'auto' 模式下，图片默认使用 'floyd'，文本不使用。
  --resize-mode [stretch|fit|crop]
                                  图片缩放模式：stretch (拉伸), fit (适应), crop (裁剪)。
  --interleaved-count INTEGER     发送多少个包后等待一次确认。
  --retry INTEGER                 连接失败时的最大重试次数。
  --save PATH                     将最终处理好的图片保存到指定路径，方便调试。
  -h, --help                      显示帮助信息。
```

&emsp;除了强大的 `send` 命令，我还编写了几个方便的辅助命令：

*   **`scan`**: 扫描附近的蓝牙设备。在第一次使用时，可以用它来找到你的墨水屏的 MAC 地址。
*   **`clear`**: 发送清屏指令，让屏幕恢复一片纯净的白。
*   **`clock`**: 切换墨水屏到时钟显示模式。
*   **`calendar`**: 切换墨水屏到日历显示模式。

&emsp;这些命令让 `epd-ble-sender` 成为了一个完整的、多功能的墨水屏控制台。

### 打包成“绿色软件”

&emsp;为了让部署过程尽可能简单，我使用了 `PyInstaller`。它可以将整个 Python 项目，连同所有依赖，打包成一个免安装的二进制可执行文件。这样做的好处是，我的 Home Assistant 主机上无需安装 Python 环境，也无需处理烦人的依赖问题。我只需要把这个打包好的文件上传上去，赋予它执行权限，就可以直接在 HA 的 `command_line` 集成中调用了，非常干净利落。

## 接入 Home Assistant：让墨水屏“活”起来

&emsp;有了这个打包好的命令行工具，接入 Home Assistant 就只剩下最后一步了。我通过 `command_line` 集成，创建了一个 `shell_command` 服务，它能接收模板化的文本内容，并调用我的 `epd-ble-sender` 程序将其显示在墨水屏上。

&emsp;这一下，墨水屏彻底“活”了过来，成为了我家庭信息中心的一个智能终端。

### 场景展示

*   **智能迎宾/送客**：通过检测每个家庭成员的 `device_tracker` 状态，当所有人都离家时，墨水屏自动刷新显示：“家中无人，快递请放门口，外卖请电话联系”；当有人回家时，则显示：“欢迎回家！今天也要元气满满哦！”。

*   **动态快递提醒**：结合快递查询的集成，当有新的快递信息时，墨水屏可以显示：“您有新的顺丰快递，派送中，请注意查收”。

*   **天气与提醒**：每天早上，自动获取当天的天气信息和日历上的首个日程，显示在墨水屏上，提醒我出门前带伞或准备会议。

*   **个性化留言板**：通过 HA 的输入框，家人可以随时给我留言，内容会立刻显示在门口的墨水屏上，增添了一份生活的小情趣。

## 开源与总结

&emsp;这次对墨水屏的“魔改”，再一次让我感受到了 DIY 和开源的魅力。一块普通的硬件，因为开放的生态和一点点“折腾”精神，就能迸发出无限的可能性。

&emsp;这个 `epd-ble-sender` 工具我已经完全开源，并发布在了我的 GitHub 上，欢迎有同样兴趣的朋友们一起交流和完善它：[https://github.com/ptbsare/epd-ble-sender](https://github.com/ptbsare/epd-ble-sender )。

&emsp;当然，这篇文章的诞生，也离不开我的 AI 伙伴 Gemini 的帮助，哈哈哈！