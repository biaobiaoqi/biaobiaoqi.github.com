---
layout: post
title: "分布式系统：HadoopDB"
date: 2013-05-18 17:58
comments: true
description: "HadoopDB是一个Mapreduce和传统关系型数据库的结合方案，以充分利用RDBMS的性能和Hadoop的容错、分布特性。2009年被Yale大学教授Abadi提出，继而商业化为[Hadapt](http://hadapt.com/)，据称从VC那儿拉到了10M刀投资。本文是对HadoopDB论文的总结。其中不免掺杂些自己的不成熟想法，更详细的内容，还请参见原论文 HadoopDB: An Architectural Hybrid of MapReduce and DBMS Technologies for Analytical Workloads"
categories: [tech, distributed, hadoop]
---
HadoopDB是一个Mapreduce和传统关系型数据库的结合方案，以充分利用RDBMS的性能和Hadoop的容错、分布特性。2009年被Yale大学教授Abadi提出，继而商业化为[Hadapt](http://hadapt.com/)，据称从VC那儿拉到了10M刀投资。

本文是对HadoopDB论文的总结。其中不免掺杂些自己的不成熟想法，更详细的内容，还请参见原论文 HadoopDB: An Architectural Hybrid of MapReduce and DBMS Technologies for Analytical Workloads

<!--more-->

背景
---
###PB级数据分析系统的能力要求

* 1.性能：节省开销（时间、资金）。
* 2.容错：数据分析系统（即使有故障节点也能顺利工作） 不同于 事务型的系统的容错（从故障中无损的恢复）。节点故障时，原来的查询操作不需要重启。
* 3.在异构型环境中运行的能力。即使所有机器硬件一样，但某些机器在某些时候可能因为软件原因、网络原因也会性能降低。分布式操作时，要防止木桶效应。
* 4.活的查询接口：商业化的数据分析一般建立在SQL查询上，UDF等non-SQL也是需要的。


#####并行数据库
满足1,4：利用分表的方式，扩散到多个节点。一般情况下节点最多为几十个，原因：1.每增加一个节点，失败率增加；2.并行数据库假设各个机器都是同质化的，但这往往不太可能

#####MapReduce
满足2,3,4：Map - repartition - Reduce原为非结构化数据，但也可以适用结构化数据。

* 2：（错误节点）动态的规划节点执行任务，将错误节点任务发放给新节点。并在本地磁盘做checkpoint存储。
* 3：（拖后腿的节点）节点间冗余的执行。执行慢的节点的任务交付给速度快的节点执行
* 4：Hive的HQL

#####HadoopDB
融合了之前两者，做出系统层面的改进，而不仅仅是语言和接口层面。

这三个解决方案对4个指标的关系如下图：

![alt compare](http://dl.dropboxusercontent.com/u/64021093/hadoopDB/QQ%E6%88%AA%E5%9B%BE20130518135802.png "compare")


架构
---
如图
![alt framework]( https://dl.dropboxusercontent.com/u/64021093/hadoopDB/QQ%E6%88%AA%E5%9B%BE20130518135814.png "framework")


组件介绍
---
#####Databse Connector:
* 作用
   
    hadoopTask <-通信-> Database on Node。节点上的DB类似于Hadoop中的数据源HDFS
* 实现
   
    扩展了Hadoop的InputFormat

#####Catalog：
* 作用

    1.链接参数如数据库位置，驱动类和证书；
    2.一些元数据如数据簇中的数据集，副本的位置，数据的划分。
* 实现
   
    HDFS上的XML。希望做成类似于Hadoop的namenode。

#####Data Loader
* 作用
   
    将数据合理划分，从HDFS转移到节点中的本地文件系统
* 实现

    global hasher：分配到不同节点
    local hasher：继续划分为不同chunks

#####SQL to MapReduce to SQL (SMS) Planner

* 作用

    将HiveQL转化为特定执行计划，在hadoopDB中执行。原则是尽可能的讲操作推向节点上的RDBMS上执行，以此提高执行效率。
* 实现
   
    扩展Hive：
    1.执行查找前，用catolog的信息更新Hive的metastore，定向到节点数据库的表
    2.执行前，决定划分的键；将部分查询语句推到节点的数据库中执行。

示例
---
示例参见下文的slides

总结
---

对hadoopDB的一些看法：

* 其数据预处理代价过高：数据需要进行两次分解和一次数据库加载操作后才能使用；
* 将查询推向数据库层只是少数情况，大多数情况下，查询仍由Ｈive完成．因为数据仓库查询往往涉及多表连接，由于连接的复杂性，难以做到在保持连接数据局部性的前提下将参与连接的多张表按照某种模式划分；
* 维护代价过高．不仅要维护Ｈadoop系统，还要维护每个数据库节点；
* 目前尚不支持数据的动态划分，需要手工一次划分好

slides：

<script async class="speakerdeck-embed" data-id="48c5e680a1ab0130e1707290244918d4" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>


下载slides，请猛戳[这里](https://dl.dropboxusercontent.com/u/64021093/hadoopDB/%5B2013-05-18%5DHadoopDB.pptx)

参考资料
---
* HadoopDB: An Architectural Hybrid of MapReduce and DBMS Technologies for Analytical Workloads
* [《HadoopDB》 —— Fenng](http://dbanotes.net/database/hadoopdb.html)
* 《架构大数据:挑战、现状与展望》 计算机学报 王珊