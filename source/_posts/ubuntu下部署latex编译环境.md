---
title: Ubuntu下部署Latex编译环境
date: '2014-05-12 14:54:33'
updated: '2015-11-28 09:56:16'
tags: 
- "GNU Tools"
- Linux
- Ubuntu
- Latex
---
[1]: (http://mirrors.xmu.edu.cn/CTAN/systems/texlive/Images/)
[2]: (http://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/Images/)
[3]: (http://mirrors.ustc.edu.cn/CTAN/systems/texlive/Images/)

[c1]: (http://bbs.sjtu.edu.cn/bbstcon,board,TeX_LaTeX,reid,1248243108.html)
[c2]: (http://zzgthk.iteye.com/blog/994662)
[c3]: (http://www.linuxidc.com/Linux/2012-07/64146.htm)
[c4]: (http://bbs.ctex.org/forum.php?mod=viewthread&tid=63418)
[c5]: (http://blog.sina.com.cn/s/blog_90444ed201016iq6.html)

<!--[todo]: (http://latex的入门1.快速2.ishort3.参考|latex在sublime text2 的配置)-->

## Latex是什么
* Latex是一种基于TEX的排版系统，用于生成高印刷质量的文档。
* Latex有很多发行版，Linux下推荐使用Texlive。

## Latex在Ubuntu下的安装
### 安装方法一

#### 1 .从站点下载ISO镜像安装

这样可以得到较新的发行版版本，同时有丰富的包支持及更新。
ISO安装文件可以从下面几个开源镜像站点的CTAN同步镜像下载：
* 中科大开源镜像站
(http://mirrors.ustc.edu.cn/CTAN/systems/texlive/Images/)
* 清华大学开源镜像站
(http://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/Images/)
* 厦门大学开源镜像站
(http://mirrors.xmu.edu.cn/CTAN/systems/texlive/Images/)

#### 2 .挂载镜像并安装

```bash
sudo mount /path_to_iso/texlive20*.iso /mnt
cd /mnt
sudo ./install-tl
```

#### 3 .安装Windows的字体

* 从Windows下拷贝这么几个字体（C:\Windows\fonts）（或从网上下载）

|宋体|仿宋|黑体|楷体|隶书|幼圆|
|---|---|--|--|--|---|
|simsun.ttf|simfang.ttf|simhei.ttf|simkai.ttf|simli.ttf|simyou.ttf|


* 拷贝到指定目录下
```bash
sudo mkdir /usr/share/fonts/WinFonts
cp -r /path_to_fonts/* /usr/share/fonts/WinFonts/
```
* 赋予可执行权限
```bash
sudo chmod 644 /usr/share/fonts/WinFonts/*
```
* 刷新字体缓存
```bash
 sudo mkfontscale
 sudo mkfontdir
 sudo fc-cache -fsv
 ```
* 配置环境变量（以texlive2013及操作系统为32位为例）
```bash
echo "PATH=/usr/local/texlive/2013/bin/i386-linux:$PATH; export PATH" >> ~/.bashrc
```
#### 4 .使用xelatex中文方案
修改ctex-xecjk-winfonts.def以解决找不到字库的问题（以texlive2013为例）
原文件:ctex-xecjk-winfonts.def
```bash
cd /usr/local/texlive/2013/texmf-dist/tex/latex/ctex/fontset/
cat ctex-xecjk-winfonts.def
% ctex-xecjk-winfonts.def: Windows 的xeCJK 字体设置，默认为六种中易字体
% vim:ft=tex
 
/setCJKmainfont[BoldFont={SimHei},ItalicFont={[simkai.ttf]}]
  {SimSun}
/setCJKsansfont{SimHei}
/setCJKmonofont{[simfang.ttf]}
 
/setCJKfamilyfont{zhsong}{SimSun}
/setCJKfamilyfont{zhhei}{SimHei}
/setCJKfamilyfont{zhkai}{[simkai.ttf]}
/setCJKfamilyfont{zhfs}{[simfang.ttf]}
 
/newcommand*{/songti}{/CJKfamily{zhsong}} % 宋体
/newcommand*{/heiti}{/CJKfamily{zhhei}}   % 黑体
/newcommand*{/kaishu}{/CJKfamily{zhkai}}  % 楷书
/newcommand*{/fangsong}{/CJKfamily{zhfs}} % 仿宋
/newcommand*{/lishu}{/CJKfamily{zhli}}    % 隶书
/newcommand*{/youyuan}{/CJKfamily{zhyou}} % 幼圆
 
/endinput
```
修改文件:
```bash
sudo mv ./ctex-xecjk-winfonts.def ./ctex-xecjk-winfonts.def.backup
sudo gedit ctex-xecjk-winfonts.def
```
修改后如下：（复制粘贴即可）
```bash
% vim:ft=tex
 
/setCJKmainfont[BoldFont={SimHei},ItalicFont={KaiTi_GB2312}
  {SimSun}
/setCJKsansfont{SimHei}
/setCJKmonofont{FangSong_GB2312}
 
/setCJKfamilyfont{zhsong}{SimSun}
/setCJKfamilyfont{zhhei}{SimHei}
/setCJKfamilyfont{zhkai}{KaiTi_GB2312}
/setCJKfamilyfont{zhfs}{FangSong_GB2312}
/setCJKfamilyfont{zhli}{LiSu}
/setCJKfamilyfont{zhyou}{YouYuan}
 
 
/newcommand*{/songti}{/CJKfamily{zhsong}} % 宋体
/newcommand*{/heiti}{/CJKfamily{zhhei}}   % 黑体
/newcommand*{/kaishu}{/CJKfamily{zhkai}}  % 楷书
/newcommand*{/fangsong}{/CJKfamily{zhfs}} % 仿宋
/newcommand*{/lishu}{/CJKfamily{zhli}}    % 隶书
/newcommand*{/youyuan}{/CJKfamily{zhyou}} % 幼圆
 
/endinput
```
### 安装方法二
#### 1 .从源里面安装

（Ubuntu13.04源中texlive版本为2012 Ubuntu14.04源中texlive版本为2013）
```bash
sudo apt-get install texlive-latex-base texlive-latex-extra latex-cjk-all
sudo apt-get install texlive-lang-cjk #此一步安装了ctex宏包
sudo apt-get install texlive-xetex #此一步安装xelatex排版
sudo apt-get install latexmk #此一步安装latexmk构建引擎

cd /tmp
git clone https://github.com/CTeX-org/ctex-kit.git
cd ctex-kit/CJKpunct/tex/latex/CJK
sudo cp -r ./CJKpunct /usr/share/texmf/tex/latex/CJK/
sudo texhash #安装CJKpunct宏包 
```
#### 2 .解决中文字体问题

此处采用自行为tex增添设置unixfonts的选项(修改源代码)的方式。
a.
```bash
cd /usr/share/texlive/texmf-dist/tex/latex/ctex/opt
sudo cp ./ctex-common-opts.def ./ctex-common-opts.def.backup
```
打开文件，找到相应位置，增加unixfonts选项，修改后的`部分代码`如下：
```tex
% fonts
\newif\ifCTEX@nofonts \CTEX@nofontsfalse
\newif\ifCTEX@winfonts \CTEX@winfontstrue
\newif\ifCTEX@adobefonts \CTEX@adobefontsfalse
\newif\ifCTEX@unixfonts \CTEX@unixfontsfalse

\DeclareOption{nofonts}{\CTEX@nofontstrue
  \CTEX@unixfontsfalse
  \CTEX@winfontsfalse
  \CTEX@adobefontsfalse}
\DeclareOption{winfonts}{\CTEX@winfontstrue
  \CTEX@unixfontsfalse
  \CTEX@nofontsfalse
  \CTEX@adobefontsfalse}
\DeclareOption{adobefonts}{\CTEX@adobefontstrue
  \CTEX@unixfontsfalse
  \CTEX@nofontsfalse
  \CTEX@winfontsfalse}
\DeclareOption{unixfonts}{\CTEX@unixfontstrue
  \CTEX@adobefontsfalse
  \CTEX@nofontsfalse
  \CTEX@winfontsfalse}
```
b.
按照ctex-xecjk-winfonts.def的格式,写一个ctex-xecjk-unixfonts.def,存与ctex-xecjk-winfonts.def同一个目录下,以下是我的设置（前提系统是已经安装了文泉驿中文字体），你可以修改字体名称用你自己的字体。

首先，确保系统已经安装文泉驿中文字体
```bash
sudo apt-get install ttf-wqy-microhei ttf-wqy-zenhei
```
写一个ctex-xecjk-unixfonts.def
```bash
cd /usr/share/texlive/texmf-dist/tex/latex/ctex/fontset
sudo gedit ctex-xecjk-unixfonts.def
```
```tex
% ctex-xecjk-nofonts.def: Linux 的 xeCJK 字体设置，默认为文泉驿字体
% vim:ft=tex

%WenQuanYi Bitmap Song:style=Bold
%WenQuanYi Bitmap Song:style=Regular
%WenQuanYi Zen Hei Mono,文泉驛等寬正黑,文泉驿等宽正黑:style=Medium,中等
%WenQuanYi Zen Hei,文泉驛正黑,文泉驿正黑:style=Medium,中等
%WenQuanYi Micro Hei Mono,文泉驛等寬微米黑,文泉驿等宽微米黑:style=Regular
%WenQuanYi Micro Hei,文泉驛微米黑,文泉驿微米黑:style=Regular

\setCJKmainfont[BoldFont=WenQuanYi Micro Hei,ItalicFont=WenQuanYi Micro Hei]{WenQuanYi Micro Hei}
\setCJKsansfont{WenQuanYi Micro Hei}
\setCJKmonofont{WenQuanYi Micro Hei Mono}

\setCJKfamilyfont{zhsong}{WenQuanYi Zen Hei}
\setCJKfamilyfont{zhhei}{WenQuanYi Zen Hei}
\setCJKfamilyfont{zhkai}{WenQuanYi Micro Hei}
\setCJKfamilyfont{zhfs}{WenQuanYi Micro Hei Mono}

\newcommand*{\songti}{\CJKfamily{zhsong}} % 宋体
\newcommand*{\heiti}{\CJKfamily{zhhei}}   % 黑体
\newcommand*{\kaishu}{\CJKfamily{zhkai}}  % 楷书
\newcommand*{\fangsong}{\CJKfamily{zhfs}} % 仿宋
\newcommand*{\lishu}{\CJKfamily{zhli}}    % 隶书
\newcommand*{\youyuan}{\CJKfamily{zhyou}} % 幼圆

\endinput
```
c.
现在ctex知道了自己多了一个选项，也知道了字体定义，现在需要用engine将其连起来。在engine/ctex-xecjk-engine.def文件中定义着，找到相应位置，修改后`部分代码`如下：
```bash
cd /usr/share/texlive/texmf-dist/tex/latex/ctex/engine
sudo cp ./ctex-xecjk-engine.def ./ctex-xecjk-engine.def.backup
sudo gedit ctex-xecjk-engine.def
```
```tex
\ifCTEX@nofonts\else
  \ifCTEX@winfonts
    \input{ctex-xecjk-winfonts.def}
  \else\ifCTEX@adobefonts
    \input{ctex-xecjk-adobefonts.def}
  \else\ifCTEX@unixfonts
    \input{ctex-xecjk-unixfonts.def}
  \fi\fi\fi
\fi
```
d.
将这三个文件都保存好，然后在tex文件中，添加documentclass的选项[unixfonts]，用xelatex编译，就可以了。
e.
最后，刷新Texlive文件数据库：
```
sudo texhash
```
至此问题彻底解决。
## 安装后的测试

#### 1 .在/tmp下新建一个.tex文件
```bash
cd /tmp
gedit test.tex
```
#### 2 .粘贴如下测试代码
a.
安装方法一的测试代码
```tex
\documentclass{ctexart}  
\begin{document}  
你好， Latex！\\
Welcome to the world of Tex!\\  
{\heiti 这是黑体}\\  
{\songti 这是宋体}\\  
{\fangsong 这是仿宋}\\  
{\kaishu 这是楷书}\\  
{\lishu 这是幼圆}\\  
{\youyuan 这是幼圆}\\  
\end{document}  
```
b.
安装方法二的测试代码（区别就在于加了个[unixfonts]参数）
```tex
\documentclass[unixfonts]{ctexart}  
\begin{document}  
你好， Latex！\\
Welcome to the world of Tex!\\  
{\heiti 这是黑体}\\  
{\songti 这是宋体}\\  
{\fangsong 这是仿宋}\\  
{\kaishu 这是楷书}\\  
{\lishu 这是幼圆}\\  
{\youyuan 这是幼圆}\\  
\end{document}  
```
#### 3 .编译，输出pdf
```bash
xelatex test.tex
```
这样在当前目录生成了一个test.pdf文件
打开即可看到效果

## 配置Latex的编辑器

现在我们已经有了Latex的基本编译环境，需要配置一个合适的编辑器，Ubuntu下，在这里提供下面几种方案可选

* Texmaker
```bash
sudo apt-get install texmaker
```
* Sublime Text 2
```bash
sudo add-apt-repository ppa:webupd8team/sublime-text-2
sudo apt-get update
sudo apt-get install sublime-text-dev
```
选Tools->Build System-New Build System
粘贴入以下内容
```
{
  "cmd": ["xelatex","$file"],
  "working_dir": "$file_path"，
}
```
保存即可，这样在sublime text 2中写后可Ctrl+B一键编译。
* Sublime Text 3 (推荐)
```
sudo add-apt-repository ppa:webupd8team/sublime-text-3
sudo apt-get update
sudo apt-get install sublime-text-installer
```
然后安装`Package Control`，同时推荐安装下面两个插件：`Latexing`和`Latex Tools` 这样的话，自动补全将会非常给力。当然，由于默认情况下`Latex Tools`是用`latexmk`来进行构建的,因此，倘若用此法，需要在每个文件的第一行写上这么一句来指定用`xelatex`来作为我们的排版引擎而不是默认的`pdflatex`:
```tex
%!TEX program = xelatex
```
* Vim+xelatex命令行模式（以下以此种方法为例）
```bash
sudo apt-get install vim
```

## Latex从零入门教程

这里提供两套教程可选，一种为简明的快速入门，另一种为较全面的学习。

### 简明快速入门

#### 首先是Latex的特点（了解即可初学者可以略过）

* LaTeX编辑和排版的核心思想在于，通过\section和\paragraph等语句，规定了每一句话在文章中所从属的层次，从而极大方便了对各个层次批量处理。
* LaTeX具有方便美观的数学公式编辑、不会乱动的退格对齐的特性。

#### 下面是教程正文

1 .第一个文档（注意保存的编码格式应为UTF8格式）
```bash
cd /tmp
vim new.tex
#内容如下，保存
\documentclass{article} 
\begin{document} 
  hello, world 
\end{document} 

xelatex new.tex #编译生成pdf
```
打开生成的pdf查看。

2 .标题、作者和注释
编辑tex文件内容如下，并编译，查看生成的pdf并思考
```bash
\documentclass{article} 
  \author{My Name} 
  \title{The Title} 
\begin{document} 
  \maketitle 
  hello, world % This is comment 
\end{document}
```
3 .章节和段落
编辑tex文件内容如下，并编译，查看生成的pdf并思考
```bash
\documentclass{article} 
  \title{Hello World} 
\begin{document} 
  \maketitle 
  \section{Hello China} China is in East Asia. 
    \subsection{Hello Beijing} Beijing is the capital of China. 
      \subsubsection{Hello Dongcheng District} 
        \paragraph{Tian'anmen Square}is in the center of Beijing 
          \subparagraph{Chairman Mao} is in the center of Tian'anmen Square 
      \subsection{Hello Guangzhou} 
        \paragraph{Sun Yat-sen University} is the best university in Guangzhou. 
\end{document} 

```
4 .加入目录
编辑tex文件内容如下，并编译，查看生成的pdf并思考
```bash
\documentclass{article} 
\begin{document} 
  \tableofcontents 
  \section{Hello China} China is in East Asia. 
    \subsection{Hello Beijing} Beijing is the capital of China. 
      \subsubsection{Hello Dongcheng District} 
        \paragraph{Hello Tian'anmen Square}is in the center of Beijing 
          \subparagraph{Hello Chairman Mao} is in the center of Tian'anmen Square 
\end{document} 
```
当然你也可以写成以下形式（去掉所有行前退格）
```bash
\documentclass{article}
\begin{document}
\tableofcontents
\section{Hello China} China is in East Asia.
\subsection{Hello Beijing} Beijing is the capital of China.
\subsubsection{Hello Dongcheng District}
\paragraph{Hello Tian'anmen Square}is in the center of Beijing
\subparagraph{Hello Chairman Mao} is in the center of Tian'anmen Square
\end{document}
```
* 加入行前的退格以在编辑时显得有条例，结构清晰
* 行前的退格与个人爱好习惯有关，以下不再做另行示例
* 行前退格不影响编译生成pdf的格式效果，编译时会被自动忽略


5 .换行
编辑tex文件内容如下，并编译，查看生成的pdf并思考
```bash
\documentclass{article} 
\begin{document} 
  Beijing is 
  the capital 
  of China. 

  Washington is 

  the capital 

  of America. 

  Amsterdam is \\ the capital \\ 
  of Netherlands. 
\end{document}
```
    空一行为另起一段，\\为段内强制换行
6 .数学公式
编辑tex文件内容如下，并编译，查看生成的pdf并思考
```bash
\documentclass{article} 
  \usepackage{amsmath} 
  \usepackage{amssymb} 
\begin{document} 
  The Newton's second law is F=ma. 

  The Newton's second law is $F=ma$. 

  The Newton's second law is 
  $$F=ma$$ 

  The Newton's second law is 
  \[F=ma\] 

  Greek Letters $\eta$ and $\mu$ 

  Fraction $\frac{a}{b}$ 

  Power $a^b$ 

  Subscript $a_b$ 

  Derivate $\frac{\partial y}{\partial t} $ 

  Vector $\vec{n}$ 

  Bold $\mathbf{n}$ 

  To time differential $\dot{F}$ 

  Matrix (lcr here means left, center or right for each column) 
  \[ 
    \left[ 
      \begin{array}{lcr} 
        a1 & b22 & c333 \\ 
        d444 & e555555 & f6 
      \end{array} 
    \right] 
  \] 

Equations(here \& is the symbol for aligning different rows) 
\begin{align} 
  a+b&=c\\ 
  d&=e+f+g 
\end{align} 

\[ 
  \left\{ 
    \begin{aligned} 
      &a+b=c\\ 
      &d=e+f+g 
    \end{aligned} 
  \right. 
\] 

\end{document} 
```
    $...$是开启行内数学模式，用于和文本合在一起使用。

    $$...$$和\[...\]是另起一行居中开启数学模式。通常用起来差别不是很大，不过$$会修改默认的公式行间距，有时可能会对文章的整体效果有影响。

具体细节可以自行搜索LaTeX的数学符号表或别人给的例子。
7 .插入图片
先搜索到一个将图片转成eps文件的软件，很容易找的，然后将图片保存为一个名字如figure1.eps。
建立一个新文档，将以下内容复制进入文档中，保存，保存类型选择为UTF8，放在和图片文件同一个文件夹里。

编辑tex文件内容如下，并编译，查看生成的pdf并思考
```bash
\documentclass{article}
  \usepackage{graphicx}
\begin{document}
  \includegraphics[width=4.00in,height=3.00in]{figure1.eps}
\end{document}
```
在老版本的LaTeX中是只支持eps图片格式的，现在的LaTeX对jpg、bmp、png等等常见图片都可以支持
待插入的图片姑且先命名为figure1.jpg
```bash
\documentclass{article} 
  \usepackage{graphicx} 
\begin{document} 
  \includegraphics[width=4.00in,height=3.00in]{figure1.jpg} 
\end{document}
```
8 .简单表格
编辑tex文件内容如下，并编译，查看生成的pdf并思考
```bash
\documentclass{article} 
\begin{document} 
  \begin{tabular}{|c|c|} 
    aaa & b \\ 
    c & ddddd\\ 
  \end{tabular} 

  \begin{tabular}{|l|r|} 
    \hline 
    aaaa & b \\ 
    \hline 
    c & ddddd\\ 
    \hline 
  \end{tabular} 

  \begin{center} 
    \begin{tabular}{|c|c|} 
      \hline 
      a & b \\ \hline 
      c & d\\ 
      \hline 
    \end{tabular} 
  \end{center} 
\end{document}
```
    注意观察有无\hline和有无\begin{center}的区别。注意观察\begin{tabular}后的lcr的区别，分别是left对齐，center对齐和right对齐
9 .中文支持
只需要把开头的\documentclass{atricle}换成\documentclass{ctexart}就可以了（第二种安装方法的需换成\documentclass[unixfonts]{ctexart}）。
示例

```bash
\documentclass{ctexart}
\begin{document}
你好，世界
\end{document}
```
到目前为止，你已经可以用LaTeX自带的article模板来书写一篇基本的论文框架了，至少你已经能够用得起来LaTeX了。
在论文从框架到完整的过程中，必然还存在许多的细节问题，比如字体字号，比如图片拼合，比如复杂的表格等等。
那些问题，就请咨询google吧。通常来说我们作为初学者会提出的问题，早就已经有许多的先辈们在网络上提过同样的问题了，看看别人的回答就可以。
LaTeX在国内的普及率并不高，因此许多时候如果搜英文关键词，会获得更好的效果。

**附录**
A .宏包
\package{}就是在调用宏包，对计算机实在外行的同学姑且可以理解为工具箱。
每一个宏包里都定义了一些专门的命令，通过这些命令可以实现对于一类对象（如数学公式等）的统一排版（如字号字形），或用来实现一些功能（如插入图片或制作复杂表格）。
通常在\documentclass之后，在\begin{document}之前，将文章所需要涉及的宏包都罗列上。
对于新人而言比较常用的宏包有

编辑数学公式的宏包：\usepackage{amsmath}和 \usepackage{amssymb}
编辑数学定理和证明过程的宏包：\usepackage{amsthm}
插入图片的宏包：\usepackage{graphicx}
复杂表格的宏包：\usepackage{multirow}

差不多了，对于新人来说，这五个宏包已经基本够用了。如果有其他的特殊需求，就通过google去寻找吧。
补充说明一下，现在ctexart模板里集成了中文支持，所以CJK宏包并不是必需品。

B .模版
模板就是在\documentclass{}后面的大括号里的内容。
在这一份教程中，我们使用的是LaTeX默认自带的模板article，以及中文模板ctexart。
模板就是实现我之前所介绍的LaTeX的经验总结的第二点的实现方式。
一篇文章，我们定义了section，定义了paragraph，就是没有定义字体字号，因为字体字号这一部分通常来说是在模板中实现的。
一个模板可以规定，section这个层级都用什么字体什么字号怎么对齐，subsection这个层级用什么字体什么字号怎么对齐，paragraph又用什么字体什么字号怎么对齐。
当然模板里还可以包含一些自定义的口令，以及页眉页脚页边距一类的页面设置。
由于模板的使用，在我的使用经验里来看，绝对不可能算是基本入门级的内容，所以在正文里当然不会提及。
如果有人实在想学，如果LaTeX已经接触到这个程度上了，那么再去翻其他厚一些的教材，也不亏了。

C .参考文献和制作幻灯片
做参考文献的时候，文章也已经快写到尾声了，而幻灯片更不是进阶一些的需求。对这两个功能有需求的LaTeX user，使用LaTeX也已经相当熟练了，自己去google一下或查阅其他厚教程是很理所当然的，一点也不冤枉。
在此我就只提供两个搜索关键词，参考文献可以搜bibtex，制作幻灯片可以搜beamer。

### 较全面的学习
下载参考lshort，Latex的较全面的官方文档。
中文pdf下载（中科大镜像站）
(http://mirrors.ustc.edu.cn/CTAN/info/lshort/chinese/)



参考：
(http://bbs.sjtu.edu.cn/bbstcon,board,TeX_LaTeX,reid,1248243108.html)
(http://zzgthk.iteye.com/blog/994662)
(http://www.linuxidc.com/Linux/2012-07/64146.htm)
(http://bbs.ctex.org/forum.php?mod=viewthread&tid=63418)
(http://blog.renren.com/blog/237934623/892726074)
