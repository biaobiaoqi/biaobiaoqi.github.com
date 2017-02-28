---
layout: post
title: "用Ruby实现的论坛灌水工具：CC98 Post Machine"
date: 2013-11-05 15:20
comments: true
categories: [tech]
tags: [技术, ruby, http, 工具]
description: "使用HTTP的POST请求，自动对CC98论坛发帖"

---

ZJU的校网论坛CC98比较活跃。论坛只对校内网开放，而且账号跟学生绑定，每个学生注册的账号数量有限。『十大』是CC98的经典页面：基于关注的人数（回帖的用户数而不是回帖的数量）用算法求出24小时内最火爆的十个发帖。很多同学都会浏览十大，关注论坛动态。

故事就是从十大引出的。有的社团在宣传活动时，为了扩大宣传面，会发动成员的小马甲顶贴上十大。这种违背社区自然发展轨迹的手段，强奸了关注十大贴的用户的意愿，阻碍了信息的自由流动。

于是萌生了完成一个批量发帖的机器，以其人之道还治其人之身的想法。在下次十大被宣传贴攻占时，能有反击的工具。

工具的用途很简单：使用不同的用户身份模拟真人论坛回帖，增加帖子关注度，以抵抗宣传贴。流程如下：提前收集各路亲朋好友的用户信息作为『预备水军』，『灌水』时，在评论内容文件中输入自定义的评论内容，在命令行参数中制定目标贴，即可实现随机顺序的用户自动顶贴。鉴于现在的功能是顶贴竞争十大，而十大排名是根据关注人数也就是独立用户评论数量做排序的，这里设计的顶贴策略是一个马甲发一条评论。以后可以考虑增加灵活的配置方案，实现更多功能。

项目Github地址：[https://github.com/biaobiaoqi/CC98PostMachine/](https://github.com/biaobiaoqi/CC98PostMachine/)

介于这个工具本身的罪恶的攻击属性，在此强调，工程仅供学习交流和对抗宣传贴。

<!--more-->
##使用说明

###1.准备顶贴用户

发帖的HTTP请求为POST请求。系统验证信息中需要有发帖用户的username，userid和hash后的password，这些都能从cookie中获得。

有两种方式设置水军的信息：

####(1)浏览器中获取cookie

在浏览器中，找到cookie的内容。将对应的三项信息抽取出来后，填入`water_army.yml`文件，由于该文件涉及用户隐私信息，项目中设置了.gitignore，不会上传到repo中。可以参照`water_army.yml.example`的格式自行修改。

####(2)使用`RegWaterArmy`工具导入

如果不想手动的查找cookie信息，也可以将账号、密码输入到`pre_water_army.txt`文件中，执行命令来获取相关信息。

在`pre_water_army.txt`文件中，一行为单位输入用户名和密码，中间用空格隔开。同样由于隐私原因，repo中没有上传该文件，可以自行将`pre_water_army.txt.example`改为`pre_water_army.txt`，然后填入内容。

填入账号、密码后，在src目录下运行如下命令：
```
$CC98POSTMACHINE/src/ruby RegWaterArmy.rb
```
即可自动获取用户的cookie信息，并导入`water_army.yml`文件中。注意，安全起见，完成这一步后，尽量删除账号、密码等隐私信息。


###2.准备评论

在`comments.txt`文件中，设置用户评论的内容，每行一条。现在的设计是保证回帖的顺序与文件中的内容顺序一致。如果用户数量超过了文件中的评论条数，则回复时循环使用`comments.txt`中的评论。建议自行设计评论，且评论数大于等于水军数量。同样需要用户自行修改`comments.txt.example`为`commnets.txt`后使用。

###3.执行

来到CC98PostMachine的src目录，执行：

```
$CC98POSTMACHINE/src/ruby  PostMachine.rb  POST_URL [SPEED]
```

其中`POST_URL`为响应帖子的网址，`SPEED`是设定的两个回帖之间的间隔时间，实际回帖时间做了如下的模糊：`SPEED + random(SPEED)`。


```

Usage: $CC98POSTMACHINE/src/ruby  PostMachine.rb  POST_URL [SPEED].

    POST_URL is the url address of target post.

    SPEED is the time gap unit between two posts, it may be 1(s), 10(s) or any other number

```

##下一步：

* 修复bug：第一次执行命令时，都只有一个用户能成功回复。（是服务器端的对cookie的记录？）

* 整理代码结构，解耦，增加配置灵活性，写的更ruby一点
