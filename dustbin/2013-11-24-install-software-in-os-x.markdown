---
layout: post
title: "我的OS X软件安装索引"
date: 2013-11-24 03:28
comments: true
categories: [tech]
tags: [技术, Mac, OS X, 软件]
description: "Mac OS X上装的软件"

---

更换硬盘重装系统时，由于备份数据失败，不得不重新配置系统环境（参见[《记对MBP一次失败的备份和重装》](http://biaobiaoqi.me/blog/2013/11/24/failed-in-replacing-hdd/)）。在此记录下自己所要在OS X上安装的软件的索引。整体分为三类：系统工具、个人和开发。


部分第三方下载的软件在安装时提示“无法打开，来自不受信任的开发者”。解决办法是：

系统偏好设置 －> 安全与隐私 －> 点左下角的小锁头图标然后输入自己的密码 －> 在“通用”标签下点选“任何来源”。

<!--more-->

##系统工具

[trim-enabler](http://www.groths.org/software/trimenabler/)：安装SSD的用户，需要用它开启TRIM机制，以提高SSD的性能。

[App cleaner](http://www.freemacsoft.net/appcleaner/)：用来彻底删除应用软件，包括各种相关的配置文件资料等。


##个人

[MplayerX](http://mplayerx.org/download.html)：视频播放软件。射手播放器也不错，不过是收费的。

[Self Control](http://selfcontrolapp.com/) ：时间控制软件，能添加网址黑名单，设定白名单，在规定时间里，以一定的策略阻碍用户访问某些网页，以排除这些网站的干扰，集中精力工作。

[iChm](https://code.google.com/p/ichm/)：chm文件浏览器。

[keka](http://www.kekaosx.com/zh-cn/)：解压缩软件。

[sougou拼音](http://pinyin.sogou.com/mac/?f=imemac&f=index&r=2015)：个人比较偏好的搜狗输入法。

[foxmail](https://itunes.apple.com/cn/app/foxmail/id617950461?mt=12)：国内的很不错的邮件客户端。

[迅雷](https://itunes.apple.com/cn/app/thunder/id463419485?mt=12)：下载工具。

[utorrent](http://www.utorrent.com/intl/zh_cn/downloads/complete/os/osx) ：BT下载工具。

[Windows远程桌面](http://www.microsoft.com/zh-cn/download/details.aspx?id=18140)

[VirtualBox](https://www.virtualbox.org/wiki/Downloads) ：有时候需要处理Office文档时，或者网银支付等相关事项，需要使用到虚拟机中的Windows。

[Evernote](https://itunes.apple.com/cn/app/yin-xiang-bi-ji/id406056744?mt=12)：个人离不开的效率工具。

[Alfred](http://www.alfredapp.com/)：让OS X在指尖滑动的神器。

[Dropbox](https://www.dropbox.com/downloading?os=mac)：方便快捷、无缝的同步数据。

[FileZilla](https://filezilla-project.org/download.php)：免费FTP客户端。

[GoAgent](https://code.google.com/p/goagent/)：没梯子会拖累生产效率的。

[Tunnelblick](http://code.google.com/p/tunnelblick/)：OpenVPN客户端，用途同上。

##开发


[Java7](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)： OS X 10.9开始系统默认不会安装Java了，需要自己安装。

[Eclipse](http://www.eclipse.org/downloads/)：Java IDE.

[Iterm2](http://www.iterm2.com/#/section/downloads)：一个不错的终端。

[Go2Shell](https://itunes.apple.com/cn/app/go2shell/id445770608?mt=12)：把它拖到Finder 工具栏上，点击后可开启终端到当前路径。可以配合Iterm2使用，设置方式如下：

`$open -a Go2Shell --args config`

[Sublimetext](http://www.sublimetext.com/2)：强大的编辑器。创建`subl`命令行指令：

`ln -s "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" ~/bin/subl`

[Mou](http://mouapp.com/)：Mac下最好的Markdown编辑器。

[XCode](https://itunes.apple.com/cn/app/xcode/id497799835?mt=12)：即使不做Objective-C项目开发，也必须安装。它的Command-Line-Tool是许多其他开发环境的预配置。

[Homebrew](http://brew.sh/)：OS X上主流的强大的包依赖管理工具。很多软件、环境都可以使用Homebrew来安装管理。

