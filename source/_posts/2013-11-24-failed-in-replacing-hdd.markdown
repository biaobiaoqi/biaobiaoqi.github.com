---
layout: post
title: "记对MBP一次失败的备份和重装"
date: 2013-11-24 02:08
comments: true
categories: [tech]
tags: [技术, Mac, mbp, SSD, IO]
description: "主要依据王自如的视频指导双SSD组件RAID0的MBP，TimeMachine使用方法不对，造成无法将备份数据迁移到重装后的系统上。"

---
##背景

大概一年前，给我11年底款的13寸MBP的光驱位替换上了一块M4 128G的SSD，用做系统盘，而机器原本的HDD则退化为数据存储盘。

前两天发现MBP间歇性的变得很慢，查看CPU和内存都没有异常，使用[SMART Utility](http://www.volitans-software.com/smart_utility.php)检查发现有坏道出现，如下图：

![bad sector](http://biaobiaoqi.u.qiniudn.com/ssdhdd%20bad%20sector.png?imageView/2/w/800/h/800)

硬盘出现坏道后，会给坏道的数据重新分配备用sector，而这种sector是有限的，再者坏道可能会扩散蔓延，这基本意味着HDD生命的结束了。只能换硬盘了。

这才意识到自己的使用习惯的不当：平时没有关机的习惯，一般合上盖子就将笔记本放到书包里走人了，而运行状态的HDD在颠簸的环境里是很容易出现机械损伤的（相比之下SSD则不会）。

考虑到自己没有太大存数据的需求（以前700G+的HDD只存了200G不到，其中很多数据还是存了之后几乎没有使用的），决定再入一块M4 128G的SSD，两块SSD组[RAID0](http://zh.wikipedia.org/zh-cn/RAID#RAID_0)。

<!--more-->

##过程

总体计划如下：

1. 使用Time Machine 备份原来系统的数据。
2. 购买SSD，组RAID0(原来SSD中的数据会被擦除)
3. 做一个U盘系统恢复盘，用于重装系统。
4. 重装系统后，通过系统工具迁移助理将备份的数据还原到新系统中。

主要参考了[王自如的RAID0装配教程](http://v.youku.com/v_show/id_XNDAxODk3MTUy.html)。

###1.备份数据

使用移动硬盘来做数据备份。

用OS X的系统工具“磁盘工具”将移动硬盘格式化为MBP支持的文件系统格式。启动Time Machine，设定移动硬盘为备份路径，在Time Machine的偏好中，设定备份源排除HDD。接下来就等系统自动做好备份了。

理论上，通过Time Machine合理备份的系统，再也不用担心硬盘挂掉的情况。即使换新机器，也能在新系统中还原出根原来一样的环境（暂不支持跨系统版本的还原）。意外的是，当然企图通过数据迁移还原系统时，发现我备份的数据块无法识别-，-。

###2.拆机，组装

在天猫上从上次购买的商家处直接又下了一单，买了同样一款的SSD。（注意，这里必须要使用同款SSD）。

拆后盖驾轻就熟，倒是在拆卸硬盘时，意外的发现自己没有六角形的T6星型螺丝刀，而这是笔记本固定硬盘的四颗螺丝钉的规格。~~~（裤子都脱了，总不能又穿上吧）~~~幸运的是，我在自行车修车摊问师傅借到了老虎钳，顺利拧下了那几颗螺丝。

![img](http://biaobiaoqi.u.qiniudn.com/ssdmbp.JPG?imageView/2/w/800/h/800)

![img](http://biaobiaoqi.u.qiniudn.com/ssdspike.JPG?imageView/2/w/800/h/800)

换上SSD后，需要使用[RecoveryDiskAssistant](http://support.apple.com/kb/HT4848?viewlocale=zh_CN)制作的U盘给两块SSD做RAID0设定。详情参见王自如的视频。

###3.重装系统

有两种重装系统的方式：

1. 使用RecoveryDiskAssistant的U盘，联网安装OS X系统；
2. 根据系统安装文件，制作U盘安装盘，参见[《如何製作 Mac OS X 專屬 USB 系統安裝》](http://briian.com/8534/mac-usb-installer.html)

我使用后者安装了系统。

###4.还原备份

在安装系统的过程中，系统会询问用户是否需要迁移数据，如果跳过这一步，还可以在安装完成系统后，运行“迁移助理”来还原备份。

由于我的操作失误，没有完全备份下整个系统，造成“迁移助理”无法识别备份数据。只能从备份数据中将有用的数据手工的迁移到新系统中，应用软件都得重新下载安装。全是泪啊=(。

##总结

备份数据只有60G，而我原来系统的数据总量（包括操作系统本身）大概有120G，即使考虑有压缩，60G也相差的很远了。备份时急于求成，没有意识到这一点，造成备份不成功，提醒自己谨小慎微。

顺着这次重配系统环境，我整理了自己的Mac OS X软件安装索引，参见博文：[《我的OS X软件安装索引》](http://biaobiaoqi.github.io/blog/2013/11/24/install-software-in-os-x/)，当然，希望自己再也不会用到。

