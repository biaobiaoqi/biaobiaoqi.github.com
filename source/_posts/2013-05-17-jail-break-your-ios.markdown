---
layout: post
title: "iOS的安全性和越狱"
date: 2013-05-17 00:10
comments: true
description: "本文讲解了iOS平台的安全性，越狱的注意事项等"
categories: [tech, ios, security, os]
---

![alt jailbreak](https://dl.dropboxusercontent.com/u/64021093/2013-5-16.jpg "Jailbrek")

提到[越狱](http://en.wikipedia.org/wiki/IOS_jailbreaking#Security.2C_privacy.2C_and_stability)，很多人第一反应大概是免费的游戏和app。

作为软件从业人员，深知中国的大环境的特殊性。内有用户想吃免费午餐的不良付费习惯，外有行业内大头诸如某讯对创新的绞杀。大家对越狱是为了免费、盗版软件的认识，也就不奇怪了。

还有另一派人。越狱对他们来说，意味着开放。个人认为这也是Hack精神的精髓之一。事实上，iOS越狱也有自己的生态圈：Cydia就是越狱设备上App Store。

<!--more-->
越狱的合法性
---

数字千年版权法对iphone的越狱进行了特赦，直到2015年，对iPhone、iPod touch的越狱依然有效。但注意，iPad就没这么幸运了。

详情参见博文[《Unlocking A New iPhone Is Now Illegal, But Jailbreaking Is Still Safe — What It All Means For You》](http://www.cultofmac.com/213144/unlocking-a-new-iphone-is-now-illegal-but-jailbreaking-is-still-safe-what-it-all-means-for-you/)


iOS安全性
---
由于iOS没有开源，学术界和工业界对它的安全机制的论述资料很少。我在网上找到了上交一位学长对ios安全机制的分析文章，是他的硕士学位[论文](http://www.doc88.com/p-405566264292.html)。作为参考，我整理了一些关键知识点。


####基于信任链的启动
iOS的信任机制从系统启动那一刻起已经开始。
系统可信启动[trustedboot](http://elinux.org/images/2/28/Trusted_Boot_Loader.pdf)：启动每一步都会检测签名，构成整个信任链。

还有另一种启动方式，是设备固件升级方式（DFU，Device Firmware Update），也是由签名构建信任链。


####程序签名
iOS应用的ipa压缩包中包含可执行文件和数据文件。可执行文件只有在已签名的前提下才能运行。确保应用经过苹果认证。

越狱提升运行权限到root，修改引用加载策略，接受任意签名的应用。
“通过软件保证软件安全是不可能的”，iOS使用了硬件来做保护，但硬件部分也遭到了越狱的破解。

####沙盒技术
iOS用沙盒技术实现访问控制
trustedBSD ：http://www.trustedbsd.org/ 
http://www.freebsd.org/doc/zh_CN/books/arch-handbook/mac-synopsis.html

####ASLR和PIE
使用地址空间布局随机化（ASLR， address space layout randomization）和位置无关可执行代码（PIE，position independent executable）编译用来防止经典的缓冲区溢出攻击。


####数据保护机制：
* 硬件加密：AES协处理器，存储着UID，GID
* 软件加密：系统中每个文件、数据都用一个唯一的秘钥来加密。秘钥是有UID、GID一起产生的，存在keybag中，keybag通过用户的4位密码来保护。 


越狱
---
越狱主要就是在信任链的根bootrom阶段攻击。由于系统不断升级，攻击的方式也在不断演进，这个[链接](http://bbs.gean.cn/archiver/showtopic-213.aspx)介绍了其中的一种情况。

####越狱后注意

总的来说，越狱打破了iOS封闭的生态环境，也打破了它特有的保护壳。手机获得了root权限，恶意代码有了可趁之机。不要轻易的使用来源不明的应用和插件。

* 非越狱手机：仅允许用户访问照片、视频数据；通过备份，可在pc端获取所有数据
* 越狱手机：拥有root权限。可以通过许多渠道如ssh，ftp获取系统数据。

更多细节参见
* [《浅谈iOS越狱前后的安全问题以及安全风险》](http://bbs.weiphone.com/read-htm-tid-1750886.html)
* [《iPad越狱不安全!安装应用/插件需谨慎》](http://www.pcpop.com/doc/0/890/890768_all.shtml)
* [《iOS完美越狱 - 福利还是阴谋？》](http://www.cnbeta.com/articles/229192.htm)

####SHSH

iPhone 3GS出来时候，苹果为加强对iPhone OS的控制对恢复(Restore)固件(Firmware)采用了验证过程，每次iTunes要恢复固件的时候都要连接苹果的服务器验证。手机的ECID和所刷系统版本号一起签名出一个SHSH文件，发送给服务器，服务器检测SHSH是否为新版本的系统所产生，如果是，则允许继续进行刷机，否则传回组织继续的信号。

SHSH是存储在苹果公司的服务器上的，用户需要通过备份原来的SHSH，并伪装一台苹果服务器来协助验证。　　

网络上SHSH备份方法的介绍很多，不了解的朋友自行Google吧。


附录
---

对于想开发iOS应用而又没有开发者账号的朋友，可以参考这篇文章[《Xcode 4.1~4.6 + iOS 5、iOS 6免证书(iDP)开发+真机调试+生成IPA全攻略》](http://kqwd.blog.163.com/blog/static/4122344820117191351263/)，Xcode4.6 iOS6.0 亲测有效。  