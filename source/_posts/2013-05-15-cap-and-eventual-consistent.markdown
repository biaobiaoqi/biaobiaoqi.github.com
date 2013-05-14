---
layout: post
title: "CAP和最终一致性"
date: 2013-05-15 00:30
comments: true
description: "查阅资料整理了最终一致性、CAP相关的内容。由于图省事儿，没有做文字的整理记载，只有slides和一些查阅过的链接，大家将就着看。欢迎指正。"
categories: [tech, distributed, hadoop]
---

查阅资料整理了最终一致性、CAP相关的内容。由于图省事儿，没有做文字的整理记载，只有slides和一些查阅过的链接，大家将就着看。欢迎指正。

slides：
<script async class="speakerdeck-embed" data-id="cca07ce09e92013076c646310b996896" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

<!--more-->
slides链接：[请戳这里](https://speakerdeck.com/biaobiaoqi/cap-and-eventually-consistent)

背景
---

为什么系统要扩张？历史的发展路径是怎么样的？请看[《系统可扩展性演化》]( http://rdc.taobao.com/blog/cs/?p=614)

CAP理论
---
* CAP理论的提出：分布式系统的CAP理论是2000年左右被提出的概念，直到Dynamo的出现，开始在工业界被广泛实践：
[《Brewer's CAP Theorem》](http://www.julianbrowne.com/article/viewer/brewers-cap-theorem)/[中文翻译](http://code.alibabatech.com/blog/dev_related_728/brewers-cap-theorem.html)

* 对CAP的理解：[《谈正确理解CAP理论》](http://www.douban.com/group/topic/11765014/)\ [《CAP理论及分布式系统一致性》](http://rdc.taobao.com/blog/cs/?p=631)

BASE理论
---
* BASE的理论解释：[《分布式事务工程实现》](http://rdc.taobao.com/blog/cs/?p=637)

最终一致性
---
* amazon的CTO分析最终一致性：[Eventually Consistent - Revisited](http://www.allthingsdistributed.com/2008/12/eventually_consistent.html)/[中文翻译](http://blog.csdn.net/xiaoqiangxx/article/details/7566654)

* Dynamo论文：[Dynamo: Amazon’s Highly Available Key-value Store](http://www.read.seas.harvard.edu/~kohler/class/cs239-w08/decandia07dynamo.pdf)

  关于Dynamo的一篇中文简述：[《解读NoSQL技术代表之作Dynamo》](http://www.infoq.com/cn/articles/nosql-dynamo)

引申
---

* CAP原作者对CAP的反思和澄清：[《CAP十二年回顾：规则变了》](http://www.infoq.com/cn/articles/cap-twelve-years-later-how-the-rules-have-changed)