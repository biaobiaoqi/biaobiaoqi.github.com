---
layout: post
title: "给女朋友的礼物"
date: 2013-06-11 17:12
comments: true
description: ""
categories: [tech, life]
tags: [Web, js, 狂想, 技术]

---

背景
---

一个月前发现了[V2EX](http://v2ex.com)这个网站，用创始人[Livid](http://www.v2ex.com/member/Livid)的话来说，『这是一个主要关于做事儿的地方』。确实如此，我在这里收获了很多想法和灵感。

本文所记的，也是得益于某天的对[某个主题](http://www.v2ex.com/t/69145)的浏览。帖子中，大家分享了很多给女朋友做的网页，说『技术宅改变世界』太过了，但拥有这样一个礼物，确实是一种属于程序员的快乐和程序员的女友的幸福。

快到我跟我妹子恋爱四周年的日子了，也正逢她本科毕业，无论如何都是个有趣的时间点。受了那个帖子的刺激，我也筹划着给女朋友做一个小网页，以示纪念。

遗憾的是，我自己从来没有写过网页，javascript和css只知道概念，html也只是知道一些简单的标签，这些可是完成一个小网页所必备的技能呢。技术能力直接阻碍了创造性成果出现的可能:(。于是，解决方案只能是搜集开源代码，然后自己做定制了。实际上，最后的产出，也就是三份代码的拼接。

资料搜集
---

通过各方搜寻，我找到了如下几个网页：

* 1.[复旦的学长hackzhou的爱心动画](http://love.hackerzhou.me/)，[github托管代码](https://github.com/hackerzhou/Love)。

网页用到了html5的一些特性实现了动态的心形花的绘制和类似程序代码敲击的文字呈现形式。由于内容仅仅是文字的，可定制性强。如下图：
![hackerzhou's love project](https://dl.dropboxusercontent.com/u/64021093/Pics/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202013-06-11%20%E4%B8%8B%E5%8D%888.12.01.png "hackerzhou's page")

* 2.[一对异国情侣的Google地图应用](http://carfieldloverita.sinaapp.com/)，[github托管代码](https://github.com/wong2/lovegift)。

网页调用了Google地图的API，可以定义聚焦的地理位置和坐标尺，显示照片，像日记一样记录了点点滴滴，有背景音乐。最后还以地点输入框的形式做了表白。很有创意！
![Google map app](https://dl.dropboxusercontent.com/u/64021093/Pics/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202013-06-11%20%E4%B8%8B%E5%8D%888.12.18.png "Googlemap app")

* 3.[v2ex上某童鞋基于百度地图的应用](http://liumeijun.com/)。

跟2类似，调用了百度API，配上『Lemon tree』的背景音乐，很有调调！
![baidumap app](https://dl.dropboxusercontent.com/u/64021093/Pics/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202013-06-11%20%E4%B8%8B%E5%8D%888.16.00.png "baidumap app")

定制计划
---
限于没有前端的基础，开发效率会很低，只能硬顶着拿着前面的三个项目做混搭了。其中项目1和2都有在github上开源代码，而3则在v2ex的帖子里被作者授权直接查源码使用了。

我做了简单的混搭修改计划：

* 1.以hackzhou的项目为基础，修改文字内容和基本布局。
* 2.添加加载等待过程，加载背景音乐。
* 3.加载完成后，出现开始按钮，按开始按钮播放背景音乐，进入动画效果。
* 4.增加全屏效果。

实施
---
#####1.项目启动

我在github上fork了[hackerzhou的代码](https://github.com/hackerzhou/Love)。([我fork的版本](https://github.com/biaobiaoqi/Love))

clone到本地，尝试阅读js代码，尝试做小改动，找到动画开始的调用。

#####2.尝试添加背景音乐

网上查资料，找到了`<embeded>`可以用来添加背景音乐，测试成功。但这个音乐播放无法支持同步的加载，不可控，在网络环境差的情况下，如果没有配乐动画过程会缺少表现力。放弃这种方案。

在[v2ex上某童鞋基于百度地图的应用](http://liumeijun.com/)源码中找到了一个第三方音乐播放库：[soundmanager2](http://www.schillmania.com/projects/soundmanager2/)。查看官方文档，确认能满足项目需求，于是加入到代码中。

为了让页面展现更加顺畅，需要音乐文件越小越好。我尝试了MIDI格式，但是很多浏览器并不支持，作罢。而soundmanager似乎对wma的支持有问题，于是只剩下mp3文件。我选择了JJ的『小酒窝』做背景音乐，在mac下使用ocenaudio将原来3MB的mp3文件截取了前一半，并导出为不同设定采样率的版本，经过测试，发现56kb采样率下，音质没有受到大的影响，且大小也足够小了，于是确定用这种格式的mp3。最终MP3文件的大小为500KB！

#####3.加载逻辑和开始按键

需求：加载过程需要隐藏前景内容，在音乐加载完成后，显示开始按钮，开始按钮能触发动画效果。

通过Google找到了使用js隐藏和显示内容的方式

```
	document.getElementById('hint').style.display = "none"; //hide hint
	document.getElementById('start_btn').style.display = ""; //show start button
```

虽然不是特别理解js引擎的单线程运作机制，但经过简单的试错、调试后，就完成了加载等待和开始按钮触发的原型。

之后是对按钮和加载提示配置css。由于懒得理解css的一些细节，直接使用了[这份项目](https://github.com/wong2/lovegift)中的css代码。




#####4.部署

github为每个项目提供了静态网页展示的功能，应付这个项目的网页展示完全够了。具体操作流程参见[《GotGithub》3.5.2. 创建项目主页](http://www.worldhello.net/gotgithub/03-project-hosting/050-homepage.html#project-homepage)。实际上，链接中介绍的几种创造干净的gh-pages分支的方法，在这个项目的发布里是不必的。因为项目主页的展示代码跟master分支里的代码本身就是一样的，那么需要做的就只是开启gh-pages分支，并提交代码了。

项目成果：[请戳这里](http://biaobiaoqi.me/Love)



结语
---

感谢v2ex，感谢hackerzhou、loo2k和wong2童鞋，我参考了你们很多代码。

创造力需要靠技术手段实现。混迹在互联网上，没有自己建站的能力实在是很苦逼的一件事情。之后自己准备花些时间在RoR上。积累技术实力，努力做出好产品;)
