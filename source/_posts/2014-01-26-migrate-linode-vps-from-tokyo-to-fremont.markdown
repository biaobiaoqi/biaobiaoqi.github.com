---
layout: post
title: "Linode跨节点迁移：从Tokyo到Fremont"
date: 2014-01-26 01:45
comments: true
categories: [tech]
tags: [垃圾邮件, 邮件服务, 技术, 服务器, Linode, 备份]
description: ""

---

##背景

[上一篇博客](http://biaobiaoqi.github.io/blog/2014/01/22/email-3/)交代了如何在Linode上搭建邮件服务器，并配置好各种协议、记录来投入实际使用。

由于实践过程中，曾经尝试使用明文协议与服务器交流数据，可能泄露了账号、密码信息，造成之后被攻击发送垃圾邮件(详细情况类似于如下链接：[链接1](http://linuxroad.blog.51cto.com/765922/1039676),[链接2](http://linuxroad.blog.51cto.com/765922/1039675))，IP被上了黑名单，在[mail-tester.com](http://www.mail-tester.com)上的测试评分为0分，同时还收到了Linode的警告。

为了能继续使用邮箱服务，我只好想着法子给Linode换一个IP。但原则上Linode是不支持换IP的。幸运的是，它支持VPS的迁移，而且方便快捷。从Tokyo节点迁移到Fremont节点后IP一般会发生变动（对于网络延迟，权衡了下[大家](http://www.v2ex.com/t/62721)的说法,Fremont还不错:[官方测速](https://www.linode.com/speedtest/)），这样就可以间接的更换IP了。

迁移过程很简单，这里做一下记录。

<!--more-->

##迁移准备

###发出迁移请求

Linode有比较完善的[Support](https://manager.linode.com/support)。对于迁移这种情况，可以在Support页面发出如下请求：

```
Hi,

I've met with some problems with my server. And I think it's a solution to migrate my server from Tokyo to Fremont.

Could you please do me a favor?

Thanks a lot!
```
1分钟之后，我就收到了技术支持的回复：

```
Hello,

Your migration to our Fremont datacenter has been configured. Please log into the Linode Manager, shut down, and click the migrate button to move to your new server. Your disk images will be moved with you. The migration should take approximately 10-15 minutes per gigabyte of data to complete. Please note that any existing backups for this Linode will be purged and will not be recoverable after you initiate the migration.

Your new IP address is: xxx.xxx.xxx.xxx

We ask that you begin this migration within 24 hours and let us know when it is complete. Thanks in advance!

Regards,
Jack Stitt

```

此时，Linode控制面板中已经多了一个迁移的提醒：`You have a migration pending!`。

不过先不要着急迁移，因为迁移过程是不可恢复的，我们需要首先将VPS中得重要数据备份到本地。注意如回复中所说，这种备份不同于Linode中的备份服务。

###备份数据

找到一份科学的全盘备份数据方式：[linode用户通过ssh+dd命令复制整个磁盘](http://www.linode.im/1590.html)。不可否认dd做传输比scp一个个拷贝文件快得多，但由于需要将整个盘5G数据全部通过网络传输，而家里网速慢，传输数据只有大概100KB/s的速度，需要等待太长时间。

实际上，我所需要备份的文件无非是`/home`目录下得所有数据和部分服务的配置数据（比如postfix、dovecot、nginx等），总共大概也就100MB，于是决定选择性的用scp传输备份数据：

`scp root@vps-ip:/backup /home/backup #vps-ip替换为服务器IP地址`

同时由于零散的传输文件效率不高，可以考虑先将服务器端所有小文件使用tar命令压缩到一个包里：

`tar zcvf backup.gz /home /etc/nginx/sites-enable `

在本地的解压缩命令如下：

`tar zxvf backup.gz`

当然，实际上我们都不会希望备份数据需要被使用到啦，而迁移vps丢失数据的概率应该也是很小的。


###修改DNS记录

由于迁移过程需要大概一个多小时，网站服务的不可访问是无法避免了。只好尽可能将迁移过程放在深夜没有用户访问需求的时候。

从这个角度讲，DNS的修改也没有特别的及时性要求。在前已完成前修改好DNS服务器中的A记录、MX记录等配置即可。

##迁移

在正式迁移之前，需要关闭服务器。

然后点击Linode控制面板中的migration按钮。接下来，就是一个多小时的等待。

##后续

完成迁移之后，开启VPS，还需要注意修改服务中IP相关的配置。比如shadowsocks里的json.config中的server ip。

一切顺利完成后，别忘了去Support界面回复Ticket =).

如果你考虑租用Linode机器，而又不吝啬使用[我的推荐码](https://www.linode.com/?r=06fc7f86359e92800c41177a80c5678ecfcb2568)，本博客不胜感激=).

