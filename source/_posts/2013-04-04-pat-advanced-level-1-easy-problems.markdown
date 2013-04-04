---
layout: post
title: "PAT Advanced Level (1) easy problems"
date: 2013-04-04 20:58
comments: true
categories: [algorithm, pat, java, tech]
---

今天做的这批题目，总的来说几乎不需要数据结构基础。几个小时刷完。

> * 1001: 数字的格式转换。第一次做的时候，将正负数分两种情况处理了，其实负数可以拆成正数加上一个负号。太简单的道理，竟然没注意。另外，Java完全可以使用NumberFormat实现格式转换。好简单的说。

<!-- more -->

> * 1002：一元多项式求导问题。有三点需要注意：1.输出中的小数精确的位数；2.浮点数操作过程中需要使用到eps做判定；*3.在我的实现中，主循环逻辑中，将判定游标越界的逻辑统一的提出到最外层，让代码更加简洁，利于维护。*

> * 1005: 简单的hash。注意Java可以直接实现int转string，string转int。

> * 1006: 简单的找最大最小。用到了Java中String的split方法划分子串和Integer.parseInt()转String为int。

> * 1008: 纯水题。

> * 1009: 一元多项式相乘。基于桶排序的思想，将子项相乘的结果加到数组中去实现。第一次提交时，算错了“桶”的大小。。

> * 1011: 水题，求组最大值的问题。

> * 1027: 水题，hash求解。

资料
---
[题目列表](http://pat.zju.edu.cn/contests/pat-a-practise)

[我的代码](https://github.com/biaobiaoqi/biaobiaoqiCode/tree/master/src/biaobiaoqi/pat/advancedlevel)



PS
---
除了这几道题，其他的题目似乎都需要树、图、DP的思想。明天开干！


用了那么久eclipse，其实对eclipse的掌握并不好。比如他对（）和“”等的支持方式：

>**只需要输入左单边括号，即可获得一个完整的括号，并定位到括号内输入内容。完成内容输入后，回车即可跳到反括号外，继续输入。同理于调用方法时参数的输入等。**
