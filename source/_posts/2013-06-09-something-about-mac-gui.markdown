---
layout: post
title: "Mac的GUI哲学"
date: 2013-06-09 01:00
comments: true
description: "前些日子，看了Tinyfool老师的一篇文章[《开发人员为何应该使用 Mac OS X 兼 OS X 小史》](http://blogread.cn/it/article/1089?f=wb)，才恍然Mac系统可不仅仅是UI上与Windows大相径庭，而是自底而上的区别。这种区别渗透到了整个系统框架的设计理念中。作者在此推荐了一些较高自由度的mac桌面控制程序"
categories: [tech]
tags: [mac, os, gui]

---

GUI哲学
---

前些日子，看了Tinyfool老师的一篇文章[《开发人员为何应该使用 Mac OS X 兼 OS X 小史》](http://blogread.cn/it/article/1089?f=wb)，才恍然Mac系统可不仅仅是UI上与Windows大相径庭，而是自底而上的区别。这种区别渗透到了整个系统框架的设计理念中。

简单概括下我的认识：相比Windows和Linux两大阵营，Mac OS X除了『品味』上的优势之外，最重要的两点是：1.对GUI应用程序脚本化的有力支持；2.能实现GUI程序之间快捷的进程间通信。

####GUI程序之间的进程间通信

IPC对于多用户分时系统的重要性不言而喻。其中从用户视角来看，如何让多个程序之间能更友好的交互是非常重要的。C++语言虽然面向对象，但在底层来看，其实依旧是冷冰冰的汇编代码，没有更整体的对象环境支撑，而以此构建的Linux也无法对进程间通信形成强力的支持。相比之下，乔布斯的团队借助于SmallTalk的消息传递机制创造了Objective-C，并搭建了自己的运行时和类库框架Cocoa，让系统无论从自身的迭代开发还是应用开发，得到了很大提升。值得一提的是，Objc虽然最近才由于iOS、Mac平台的开发的火热进入热门编程语言的行列，其实它比Java还早十年出生。像最近由于Rails框架而火爆起来的Ruby和持续坚挺的Java，都从SamllTalk中吸收了很多设计理念，就别提C#了。

####GUI应用程序的脚本化

图形的交互方式确实人性化，但应用程序脚本化控制的方式在一些特定的场景里也可以大大提高生产效率。比如微软Office的VBScript。即使是一般用户，不愿意自己写脚本，脚本化的方式也能让开发人员更方便快捷的开发出新颖的功能和产品。

让应用全部统一开放脚本很难，特别是从市场的层面而言，如果没有一直贯彻这一战略，造成平台很多应用不支持这一功能，则很难推广。苹果九十年代已经开始积累这方面的基础，有先见之明。

GUI工具
---
下面是我接触过的一些Mac下的GUI工具。它们大都散发着对开发者的自由开放的态度:)

###Quicksilver
『为了不把Mac当Windows用』，可以从[Quicksilver](http://qsapp.com/)入手。它能将双手从触摸板中解脱出来，或许这是很多开发者的梦想吧;)。只需用热键激活输入框，输入简单的匹配字符串，就可召唤出某个应用，或者执行某些搜索、查找任务，快哉！


简单说说配置和使用方式：

* 1.安装好后，在preference -> command中可以设置HotKey（唤醒的虚拟按键），我的习惯设置是`control+enter`。preference -> application可以设置是否需要在dock中显示，以及登入时自动启动。
* 2.基本功能：快捷打开应用。按下Quicksliver的HotKey（我的是`control+enter`）,在弹出的输入框中输入所需应用的头几个字母或者缩写，Quicksliver会自动匹配最可能的应用，并显示出来，如果不是自己想要的，可以移动「上下光标」打开下拉菜单选择。选中后回车即可，如图。

![Quicksilver](https://dl.dropboxusercontent.com/u/64021093/Pics/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202013-06-09%20%E4%B8%8B%E5%8D%881.23.22.png "Quicksilver示例")

* 3.还有很多其他的细节功能，通过Quicksliver的插件实现，可以根据自己的需求来定制。

###Shortcat

[shortcat](http://shortcatapp.com/)是Mac下的快捷操作利器。相比Quicksilver，Shortcat有不同的定位：通过键盘定位到屏幕上某窗体内的某个位置。其官网的示例就是如何通过Shortcat使用键盘更改DNS设置，注意，是完全不用鼠标噢。有人可能会想那为什么卜直接使用cmd呢？我想答案是Shortcat就是基于GUI的解决方案，是GUI和键盘快捷键的完美组合，与cmd并不冲突。

下面简单的交代下Shortcat的使用方式：

* 1.快捷键`Cmd+Shift+Space`用来激活输入框。使用关键字的定位方式类似于Quicksilver。比如：如果目的是『Language & Text』，那么输入『lt』、『lang』；『sa』代表show all，显示所能用于文字定位的区域。『.』能展示出所有可控制区域，包括没有文字定位的区域。
* 2.输入了关键字后，界面中被匹配到的模块会被套上不同颜色的方框。接下来，可以使用`control+key`重定位到对应位置，其中key为对应的匹配上的模块的字符标识。


![Shortcat](https://dl.dropboxusercontent.com/u/64021093/Pics/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202013-06-09%20%E4%B8%8B%E5%8D%881.42.39.png "Shortcat示例")

* 3.定位到合适的位置后，按下`enter`，可执行单击动作；对应的，双击`enter`为鼠标双击动作；如果需要配合其他按键的点击，比如`command+click`，执行`command+enter`即可；鼠标悬浮为`control`；双击`control`可实现聚焦。

###GeekTool

[GeekTool](http://projects.tynsoe.org/en/geektool/)类似于Windows下的widget，可以个性化的定制自己的桌面，添加插件，将CPU、HDD信息直接展示在桌面上，正如其名，Geek而又文艺!如下效果图：

![GeekTool](http://bbs.dgtle.com/data/attachment/album/201111/10/011505943pmpmm68enxwwd.png "GeekTool示例桌面")

详细配置可参考这篇文章[《教你装小清新—— Geektool && Rainmeter 桌面皮肤推荐》](http://www.dgtle.com/article-797-1.html)

###Nocturne

[Nocturne](http://code.google.com/p/blacktree-nocturne/downloads/detail?name=Nocturne.2.0.0.zip)这是桌面颜色控制的工具，与Quicksilver同为blacktree公司的产品。

使用方式：下载Nocturne2.0.0，解压后拖入应用程序文件夹，打开。在preference中可很直观的配置各项属性。其中，switch to night功能可以将Mac界面切换到黑夜模式，很好玩;)。

###参考：

* [矮矬穷Mac桌面美化得瑟教程](http://ksmx.me/blog/2012/03/18/customize-mac-desktop/)

