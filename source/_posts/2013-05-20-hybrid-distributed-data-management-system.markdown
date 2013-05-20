---
layout: post
title: "Hadoop和RDBMS的混合系统介绍"
date: 2013-05-20 14:52
comments: true
description: "现在大数据概念被时常提起，社会各界对其关注度越来越高。往往越是火热的东西，人们越容易忽略它的本质。在slides的背景中，我首先按照自己的理解，简单的理顺了数据处理领域的发展历程。之后，落脚点是两个比较有代表性的混合的分布式系统：HadoopDB和微软的Polybase。他们都是使用RDBMS与hadoop的MapReduce的有效混合。可能暂时技术还不成熟，但有着美好的前景。这里附上我的ppt/slides展示"
categories: [tech]
tags: [distributed, hadoop, mapreduce, rdbms]

---

现在大数据概念被时常提起，社会各界对其关注度越来越高。往往越是火热的东西，人们越容易忽略它的本质。在slides中，我首先按照自己的理解，简单的理顺数据处理领域的发展历程。之后，落脚点是两个比较有代表性的混合的分布式系统：[HadoopDB](http://biaobiaoqi.me/blog/2013/05/18/a-hybrid-system-hadoopdb/)和微软的[Polybase](http://biaobiaoqi.me/blog/2013/04/25/split-querying-process-in-polybase/)。由于缺乏实战经验，很多东西由各方论文和博文中得到，有不恰当的地方，欢迎大家拍砖讨论;)

slides的提纲如下：

<!--more-->

提纲
---

###背景
* RDBMS的出现
* 大数据时代到来
* NoSQL技术
* 新时代的挑战

###HadoopDB
* PB级数据分析
* HadoopDB是什么
* 框架和组件介绍
* 示例
* 总结

###Polybase
* Polybase总览
* PDW结构
* Polybase的实现
* 性能分析

slides在线展示：
<script async class="speakerdeck-embed" data-id="77bdc950a3460130c98a12e3c5740641" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

slides下载：
[请戳这里](https://dl.dropboxusercontent.com/u/64021093/slides/Hybrid%20system.pdf)

