---
layout: post
title: "Facebook学长交流分享"
date: 2014-05-22 22:24
comments: true
categories: [tech]
tags: [facebook, 讲座, career]
description: ""

---

印象中这似乎是Facebook第一次来浙大校园做交流。

前不久，也参加了Google的校园宣讲，G的两大宣讲主题是Google介绍和模拟面试。印象最深的是无敌的一家三口每年100w封顶的豪华医保（配偶不限男女LOL）。这次Facebook的结构类似：

> Tech Talk: Ranking News Feed for 1.2 Billon People
> 
> Workshop: Crush Your Coding Interview

两位主讲人都很棒，下面是自己的简要记录。

<!--more-->

##Crush Your Coding Interview


主讲人： Frank Qixing Du。本科复旦，研究生清华、在fb做mobile开发。

Frank主要介绍了如何针对性准备Facebook的面试，从中可以看得出F的企业文化。


面试准备：流程，资料，沟通。主要分四块：

1. 简历
2. 获得面试
3. coding，过去的项目
4. 面试之后

####简历

* 基础信息：blabla，填写GPA最好附上满绩比重（据说有的学校满分是4，而ZJU就是5），毕业时间（便于hr筛选简历）……

* 个人的故事：展现经验、个人影响和对事物的激情。

	经验方面：包括工业界经验，兴趣经验项目，github等等。侧重三点：

	1. 做了什么；
	2. 做的东西的影响；
    3. 具体，简短，一页之内
                
	一些常用表达词汇：build，optimize，improve等。

* 诚恳的highlight自己的成就~

####获得面试

1. chat with recruiter
2. 一到两轮
3. on site ／ 电面 （2015年会有一批facebook员工到中国来现场面试）



####面试：stay clam and think out loud

* tackle hard problem的能力
* trade-offs的权衡能力
* 沟通能力，表达代码的思路
* 检测limits：知识的深度、广度。要坦诚的说自己不知道


不会考脑经急转弯，着重在 数据结构、算法实现上。

1. 学会提问题：明确题目的条件限制等
2. 写出能运行的代码
3. 不断优化

现场出题感受下处理过程： 数组的size是N，存1－N之间的数，判断是否有重复。

* 不要立即写代码，先明确思路，再写代码。
* Done is better than perfect


关于项目：

* 要准备的常见问题：最近做的项目，最有挑战的项目，最喜欢的项目
* context：一两句话交代背景，action：做了什么，result：项目带来的影响


####面试之后

准备一到两个问题：

* you are interviewing the company as well
* Focus on what you concerned most


####总结
* think out loud
* 问许多问题
* 检测代码能否运行！corner case等，debug。清晰，健壮。
* be yourself


##Ranking News Feed for 1.2 Billon People

主讲人：Meihong Wang。本科浙大，现在是Engineering Manager，团队在做New Feed。

Meihong学长从项目组的动机、News Feed架构以及企业文化三个角度做了介绍。

####MOTIVATION

一些数据：

* 550M daily user
* 5B page loads／day
* publish <1s
* Fetch Rank time < 200ms
* 2000 candidate stories per day per user -> rank them

####ARCHITECTURE

Actor －logging －> user action storage <－ query －> viewer

Pull model：push 耗资源太多

Feed Evaluation：机器学习，概率模型，预测

####Culture

* Make the world more open and connected
* 6k员工，3k工程师。世界四个工程办公室：Menlo Park，Seattle，New York， London
* THE HACKER WAY：在一个产品上，不断的改进迭代。
* We move fast
* Hackthons：一两个月有一场
* 工作一年以上，可以跳到另一个team做一个月。鼓励去不同组，了解整个公司。
* 公司的架构是扁平、网状的，工程师的title一样，就是Software Engineer
* 职业发展：为期8周的Bootcamp；English 1v1辅导；各种camp，方便了解公司技术；免费洗衣服，免费食物等……


##问题环节

只摘录了一些来得及和自己感兴趣的问题：

* 我问道Facebook怎么看待“全栈工程师”，Frank透露了他对业界流行full-stack的看法：“full stack is bull shit”，是一个噱头，startup公司更需要。fb对此没有特别的倾向性。当然，他们也有厉害的同事确实是full-stack的。
* 工作强度，比国内大多数公司要清闲，币硅谷大多数公司要强。
* 一周一次组会，一周一次manger半小时约谈
* 2015年，只要合格就招，没有人数限制。中国学生在F的口碑很好。
* 工程师级别：3－8。研究生是3，博士4， 5开始是senior级别，但是大家title都一样。
* 工程师文化
* 21天年假





