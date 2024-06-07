---
title: 使用Latex排版一篇高印刷质量文章
date: 2016-03-08 23:53:11
updated: 2016-03-09 11:54:44
tags: 
- Latex
---

## 引言
　　本篇作为一篇初学者的指南，高级用户则完全可以跳过。因为笔者本身也是一名新手。
## 从模板说起
　　`Latex`的模板让使用者无需考虑格式问题，从而将注意力更多地投入到内容而非形式上，这便是`Latex`的一大优势所在，对于不同的格式要求，排版者只需在文件头部修改所使用的模板即可（只需修改一行的内容），而剩下的文本则无需变动，非常方便。
　　本文以`IEEE`期刊官方所提供的模板作为示例。
## 开始
　　下面笔者逐步介绍如何排版一篇符合`IEEE`标准规范的论文。
### 模板的指定
　　由于`IEEE`模板作为`Texlive`中的集成模板，在安装完成后就已经包含在发行版中，在新建的`.tex`空白文件的第一行，用以下语句指定即可：
```tex
\documentclass[conference]{IEEEtran}
```
#### 此处可以使用的参数（方括号内的参数）
* 字号大小
　　有四种可能的字号，分别是9pt, **10pt**, 11pt, 12pt, 加粗的为默认值，默认值适用于大多数paper，无需修改。
* 草稿模式
　　同样此处有四种可能的模式，分别是draft, draftcls, draftclsnofoot, **final**, 倘若使用draft模式则文章的行距被调整为二倍行距以方便加批注，默认为final即最终稿模式，此处也无需修改，保持默认即可。
* 模板类型
　　此处有５种可能的类型，分别是conference, **journal**, technote, peerreview, peerreviewca。journal以及technote得到的论文会和大多数`IEEE TRANSACTIONS journals`的格式非常吻合。`peerreview`得到的论文与`journal`非常相近，唯一的不同是`peerreview`会多排版出来一个单栏的封面，专门展示标题，作者，摘要以及关键词，以方便同行的审查。在封皮页之后的正文还会有标题，但是正文不再有作者以及摘要等。`peerreviewca`与`peerreview`非常接近，不同的是其作者的格式与conference的（多栏分开多个作者）保持一致。此处我们先以conference为例子。
* 纸张类型
　　此处有三个可选项：**letterpaper**, a4paper, cspaper，本文暂且以a4paper(A4纸张)为例。
* 单双面
　　**oneside**, twoside，默认为单面，暂且保持默认即可。
* 单双栏
　　onecolumn, **twocolumn**，默认为双栏，暂且保持默认即可。
* 其他杂项暂不介绍
　　1）`romanappendices`，默认不启用，启用此项会使得Appendices的编号以罗马数字，而非大写的A.B.C等编号。
　　2）`captionsoff`，默认不启用，启用此项会使得图表等里面的标注文字首字母不再大写。
　　3）`nofonttune`，默认不启用，启用此项会禁用IEEEtran为改善阅读而做的字间距微调。
　　4）`comsoc`, `compsoc`, `transmag`，默认不启用，启用这些选项则也可以使用此`IEEEtran`模板排版符合`IEEE Communications Society`, `IEEE Computer Society`和`IEEE TRANSACTIONS ON MAGNETICS`等这些机构的格式的论文。
* 一个基本示例
```
\documentclass[10pt,final,conference,a4paper,oneside,twocolumn]{IEEEtran}
```
　　对于选项是默认值的也可略去不写，所以上述可简写为：
```
\documentclass[conference,a4paper]{IEEEtran}
```
### 中文支持
　　默认的`IEEEtran`是不支持中文的，此处使用`ctex`包提供中文支持。
```
\usepackage[fontset=mac,scheme=plain]{ctex}
```
* `fontset`选项
　　依据你操作系统而定，此选项为了规避不同操作系统预装中文字体不一样导致的找不到字体的问题。
　　1）若你在使用**Windows**，则`fontset=windows`。
　　2）若你在使用**Ubuntu**，则`fontset=ubuntu`。
　　3）若你在使用**Mac OS**，则`fontset=mac`。
　　4）其他`fontset`选项详见`ctex`文档。
* `scheme`选项
　　此处`scheme=plain`以使得`ctex`仅仅提供中文支持，而不改变文章的行距和缩进等。
　　此处只用到`ctex`这两个选项，更多选项强烈推荐参阅`ctex`官方文档：
在Mac OS或Linux中执行：`texdoc ctex`即可。Windows下有相应的`Texdoc`图形查找工具。

### 增强的数学公式输入
```
\usepackage{amsmath}
```
`amsmath`由`American Mathematical Society`编写和维护，提供了更强大的数学公式排版。
### 列表支持
　　形如下面的格式都被称作列表，此处为有序列表，可被自动编号，还有一种叫做无序列表，这两种环境都被`enumitem`这个包提供
```
1.xxxx
2.xxxx
3.xxxx
```
以下一行引入此包：
```
\usepackage{enumitem}
```
### 并列插图支持
　　在一些论文中可能会用到子图，使用subfig包支持：
```
\usepackage{subfig}
```
### 文档内链接跳转支持
　　引入此包以支持链接跳转，尤其是单击目录或者引用等元素则会直接跳转到相应目标或者出处。
```
\usepackage{hyperref}
```
### 其他杂项
　　修正连字符使用：
```
\hyphenation{op-tical net-works semi-conduc-tor}
```
## 文档正文部分
　　到此为止，以上`.tex`头部的指定语句结束，下面开始文档的正文部分，也即在`\begin{document}`之后的部分。
### 标题指定
　　以下语句：
```
\title{你的文章标题}
```
### 作者信息
　　以下语句（示例）：
```
\author{\IEEEauthorblockN{韩小涛，徐 雁}
\IEEEauthorblockA{电气与电子工程学院\\
华中科技大学\\
武汉, 中国\\
邮箱: xthan@mail.hust.edu.cn}\\
\and
\IEEEauthorblockN{傅闯, 饶 宏}
\IEEEauthorblockA{电科院\\
中国南方电网公司\\
广州, 中国\\
邮箱: fuchuang@csg.cn}
}
```
　　其中，一个`IEEEauthorblockN`代表一方作者。
　　在指定了`title`和`author`后，用`\maketitle`即可生成标题。
### 摘要
　　使用`Latex`的`abstract`环境即可：
```
\begin{abstract}
你的摘要
\end{abstract}
```
### 关键词
　　使用`IEEEkeywords`环境即可：
```
\begin{IEEEkeywords}
你的关键词
\end{IEEEkeywords}
```
### Section部分
　　使用`secttion`命令执行一级标题，其中一篇文章一般要分为好几个`section`。
```
\section{该section的标题}
```
　　如果有必要，还可以使用`subsection`以及`subsubsection`执行二级和三级标题。
### Paragraph段落
　　使用`par`命令执行段落。每个段落首行均有缩进。
```
\par 这是第一段。
\par 这是第二段。

```
### Citation引用
　　使用`cite`命令来在引用处进行引用：`\cite{1}`代表此处引用参考文献的第一项。
　　此处以及以上各部分可以使用以下图片展示其对应关系：
![](使用latex排版一篇高印刷质量文章/1.png)
<a href="1.png" target="_blank">点击此处查看大图</a>
### 图片的插入
#### 单一图片的插入
　　一个标准的插入图片的代码如下：
```
\begin{figure}[!t]
  \includegraphics[width=0.3\textwidth]{fig1.png}
  \centering
  \caption{直流电流测量系统内部原理图}
  \label{fig1}
\end{figure}
```
　　其效果如下：
![](使用latex排版一篇高印刷质量文章/14.png)
#### 并列子图的插入
　　插入多个子图：
```
\begin{figure}[!t]
\centering
\subfloat[10A，8/20$\mu s$]{
\label{fig:fig9-1}
\includegraphics[width=0.43\columnwidth]{fig9-1}%
}
\subfloat[17A，8/20$\mu s$]{
\label{fig:fig9-2}
\includegraphics[width=0.43\columnwidth]{fig9-2}%
}\\
\subfloat[22A，8/20$\mu s$]{
\label{fig:fig9-3}
\includegraphics[width=0.43\columnwidth]{fig9-3}%
}
\subfloat[35A，8/20$\mu s$]{
\label{fig:fig9-4}
\includegraphics[width=0.43\columnwidth]{fig9-4}%
}
\caption{分流器的冲击电流时域响应}
\label{fig9}
\end{figure}
```
　　其效果如下：
![](使用latex排版一篇高印刷质量文章/2.png)
### 表格的插入
　　下面的代码可以插入一个简单的表格：
```
\begin{table}[!t]
\renewcommand{\arraystretch}{1.3}
\caption{An Example of a Table}
\label{table_example}
\centering
\begin{tabular}{|c||c|}
\hline
One & Two\\
\hline
Three & Four\\
\hline
\end{tabular}
\end{table}
```
### 有序列表与无序列表
* 有序列表示例：
```
\begin{enumerate}
\item 分流器的电气参数
\item 分流器的物理结构参数
\item 子区间积分变量设定
\end{enumerate}
```
![](使用latex排版一篇高印刷质量文章/3.png)
* 无序列表示例：
```
\begin{itemize}
\item 一次侧电流：3KA
\item 阻抗：$50\mu\Omega$
\item 额定电流时的输出电压信号：150mV
\item 带宽：65-3kHZ
\item 给定保护动作门槛值：7.5mV
\end{itemize}
```
![](使用latex排版一篇高印刷质量文章/4.png)
* 值得注意的是，有序列表和无序列表可以互相嵌套，如下图所示：
![](使用latex排版一篇高印刷质量文章/5.png)
<a href="5.png" target="_blank">点击此处查看大图</a>

### 数学方程式的输入
　　此部分是可以讲很长都讲不完的，在此精简地介绍一下。
* 基本的数学符号
　　参见此图，里面囊括了常用的所有符号对应的`Latex`代码：
![](使用latex排版一篇高印刷质量文章/6.jpeg)
牢记基本的：
上标：`^`
下标：`_`
* 矩阵
　　参见此图，不同矩阵的写法：
![](使用latex排版一篇高印刷质量文章/7.jpg)
* 分数
　　分数是最常用的，一定要牢记，例如：
![](使用latex排版一篇高印刷质量文章/8.png)
* 方程及方程组（包括编号）
　　首先，对于此部分，**非常强烈**推荐先通读一遍`amsmath`的官方文档，里面对于每种方程的对齐方式都有详尽的描述。
1. 不参与编号的方程环境有`gather`,`flalign`,`multline`,`split`
2. 参与编号的方程环境有：
`equation`:单独方程（常用）。
示例：
![](使用latex排版一篇高印刷质量文章/9.png)
<a href="9.png" target="_blank">点击此处查看大图</a>
`align`:多个方程写在一起，有对齐，参与对齐的每个方程均有编号（非常常用）。
示例：
![](使用latex排版一篇高印刷质量文章/10.png)
<a href="10.png" target="_blank">点击此处查看大图</a>
`subequations`:同样编号下面分裂出来的子方程，其以3-a，3-b等编号。
示例：
![](使用latex排版一篇高印刷质量文章/11.png)
<a href="使用latex排版一篇高印刷质量文章/11.png" target="_blank">点击此处查看大图</a>
3. （较复杂，可略去不看，仅供参考）单独方程与分裂子方程对齐且连号。
　　首先在头部定义：
```
% Tweak subequations
\usepackage{etoolbox}
\AtBeginEnvironment{align}{\setcounter{subeqn}{0}}
\newcounter{subeqn} \renewcommand{\thesubeqn}{\theequation\alph{subeqn}}%
\newcommand{\subeqn}{%
  \refstepcounter{subeqn}% Step subequation number
  \tag{\thesubeqn}% Label equation
}
```
　　在正文处的写法：
```
\begin{align}
E_x={}&\begin{bmatrix}1&0\end{bmatrix}^T,E_y=\begin{bmatrix}0&1\end{bmatrix}^T\\
M^f_{\lambda/4}={}&\frac{1}{\sqrt{2}}\begin{bmatrix}1&-i\\-i&1\end{bmatrix}e^{i(\pi/2)}\refstepcounter{equation}\subeqn\\
M^b_{\lambda/4}={}&\frac{1}{\sqrt{2}}\begin{bmatrix}1&i\\i&1\end{bmatrix}e^{i(\pi/2)}\subeqn\\
M_m={}&\begin{bmatrix}-1&0\\0&1\end{bmatrix}\\
M_p^x={}&=\begin{bmatrix}1&0\end{bmatrix},M_p^y=\begin{bmatrix}0&1\end{bmatrix}
\end{align}
```
示例：
![](使用latex排版一篇高印刷质量文章/12.png)
<a href="12.png" target="_blank">点击此处查看大图</a>
### 参考文献
* `bib`文件的写法
　　首先，推荐先通读`bibtex`官方的文档。
```
texdoc bibtex
```
下面是一个示例：
```tex
@incollection{1,
  title={Fiber-optic current sensor for the electro-chemical in- dustry},
  author={K.Bohnert,P.Gabus,H.Brandle,M.Brunzel,R.Bachle,M.Wendler, and S. Ebner},
  booktitle={Tech. Dig. Sensoren Und Messysteme 2006 (ITG-/GMA- Fachtagung)},
  volume = {13-14},
  pages = {103-106},
  year={2006},
  month={Mar.},
  publisher={Freiburg},
  address={Germany}
}
@article{2,
  title={Fiber-optic current transducer optimized for power metering applications},
  author={J. N. Blake and A. H. Rose},
  journal={2003 IEEE PES Transmission Dis- tribution Conf. Exposition},
  volume = {Jan.},
  pages = {405-408},
  year={2003},
  month={12},
  note={Dallas, TX}
}
@manual{3,
  title={Waveplate polarization rotator},
  author={R. A. Reeder},
  organization={U.S. Patent 6,437,904 B1},
  year={2002},
  month={Aug.},
}
@manual{4,
  title={Elimina- tion of birefringence induced scale factor errors in the in-line sagnac interferometer current sensor},
  author={S. X. Short, J. U. Arruda, A. A. Tselikov, and J. N. Blake},
  journal={J. Lightw. Technol},
  volume = {16},
  number = {10},
  pages = {1844-1859},
  year={1998},
  month={Oct.}
  }
```
　　将其保存为`bibfile.bib`后，在文章的tex文件中，最后引用：
```tex
\bibliographystyle{IEEEtran}
\bibliography{IEEEabrv,bibfile}
```
　　即可在此处排版参考文献：
![](使用latex排版一篇高印刷质量文章/13.png)
<a href="13.png" target="_blank">点击此处查看大图</a>
### 结束文档
```
\end{document}
```
　　此处与开头的`\begin{document}`遥相呼应。
### 其他杂项
* 作者生平信息，尚未用到，暂不介绍。

## 后记
　　本文初稿写于`2016`年`3`月，文中命令均依照此时的`Texlive`发行版以及参考文档，若后面有变动，则文中部分命令可能会失效。
　　本文力求以最通俗简单的方式阐述一篇论文的基本`Latex`排版方法，同时鉴于笔者水平极其有限，文中一些用词称呼可能并非准确。文中一些部分存在过于简略的问题，尤其是插入表格的部分也是可以深入挖掘的部分，因此，本文内容也会在不断修订和更新之中，后面希望加入编辑和排版页眉页脚的部分。
## 一些模板（持续更新）
* 华中科技大学学位论文模板（第三方）：（http://hust-latex.github.io/download/ ）
* 华中科技大学本科毕业论文模板（第三方）：（https://github.com/Qinnn/LaTeX-ThesisTemplatesForHUSTer ）
* 高校`Latex`论文模板：（http://blog.sciencenet.cn/blog-287062-882353.html ）
* 另一个合集：（http://www.xuebuyuan.com/2110936.html ）
* 访问此网站可以得到大量模板：（http://www.latexstudio.net/ ）

参考：
（http://omega.albany.edu:8008/Symbols.html ）
（http://jingyan.baidu.com/article/f3e34a128c53aef5ea653542.html ）
文中图中的文章为笔者的中文译稿，英文原文出自于：
（http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=4303187 ）
（http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=4918651 ）
