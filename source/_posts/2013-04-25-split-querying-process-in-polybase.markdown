---
layout: post
title: "PDW中的Split Querying Process"
date: 2013-04-25 22:59
comments: true
categories: [tech, distributed]
---
最近看了关于SQL Server的分布式处理方面的论文，觉得它提出的Polybase跟之前看过的HadoopDB有些神似，这里做个小总结（抽空再把HadoopDB的总结贴出来）。

不算翻译，只是挑出自己认为是重点的部分。详细情况，还请论文查阅原文，引用中有写明出处。文章末尾有我总结的slides，可以辅助查阅。

由于缺乏实践经验，很多东西未必能理解其本质。如有其他观点，还请多指教。

当下的计划就是开始自己搭环境，实践起来!~


背景
---
商业应用中，越来越多的需要将结构化数据和非结构化数据存储、处理混合起来。
目前，已经有很多公司、产品致力于这部分的研究，微软发的这篇论文，也正是基于PDW V2的这一新功能提出的新的解决方案。

<!--more-->

###Polybase简介：

是SQL Server PDW V2的一个新功能：通过使用SQL来管理和查询hadoop集群中的数据。
它同时能处理结构化和非结构化的数据，特点是结合了HDFS的外部表，使用基于开销的查询优化器来做分裂查询处理。


相关研究
---
* sqoop：用于在hadoop和结构化数据9比如关系型数据库之间传输数据。

* teradata& Asterdata& Greenplum& Vertica：通过外部表（external table）实现基于SQL的对hadoop中所存数据的操作。

* Orable：基本机制也是建立外部表；另外还开发了用于加载hadoop的大数据到Oracle自家数据库的工具OLH(Oracle loader for Hadoop)。

* IBM、Netezza:使用mapreduce方法获取分布式环境下各个节点的数据执行处理。

* Hadapt: (HadoopDB)：HadoopDB是来自耶鲁大学的创意，并商业化为Hadapt项目。这是首个提出使用类SQL语言、集合Hadoop系统实现对RDBMS的操作的想法。实现相对简单，源代码3千多行，在Hadoop中对其中的几个模块做了二次开发。


PDW
---
Polybase是PDW V2的一个新feature，那么，首先，让我们来看一下所谓的PDW是什么。

PDW是一个基于SQL Server的shared-nothing的并行数据库系统。

PDW（Parallel Data Warehouse）架构图：

{% img http://dl.dropboxusercontent.com/u/64021093/pdw/Image0.png %}


###PDW系统中的组件：
#####节点
* control node：

类似于Hadoop中的master节点。运行着PDW Engine，负责：查询语法分析，优化，生成分布式执行计划DSQL，控制计划实施

* compute node：

类似于Hadoop中的slave节点。数据存储和查询执行

####DMS

Data Moving Service，起功能有：

* 1.repartition rows of a table among SQL Server instances on PDW compute nodes

* 2.针对ODBC的类型转换。


Polybase
---

###Polybase使用场景
如图

{% img http://dl.dropboxusercontent.com/u/64021093/pdw/Image1.png %}


（a）中PDW与Hadoop一起完成了数据处理任务，并输出结果；

（b）中处理数据后，结果直接存储到HDFS中


充分利用SQL Server PDW的性能优势，特别是它的基于开销的并行查询优化器和执行引擎。


###Polybase的环境需求
* 1.PDW与Hadoop集群可以重叠，也可以分离。
* 2.windows 和 linux部署的hadoop集群都支持。
* 3.支持所有标准的HDFS文件格式，包括文本、序列化文件、RCFiles。只要定义好对应的Inputformat和outputFormat，所有定制文件格式也支持。


###核心组件
* 1.外部表：用于在PDW中实现对数据的操作语义。
* 2.HDFS Bridge：DMS中的组件，用于实现PDW节点域Hadoop的通信。
* 3.基于开销的查询优化器：将常规SQL查询语句转化为DSQL（分布式SQL查询语句），并结合集群状况（比如Hadoop和PDW集群规模，运行状况等），合理选择优化方式。



###1.外部表
PDW需要了解到Hadoop集群中数据的模型。于是就有了这个外部表。
实例如下：

创建集群：

```
CREATE HADOOP_CLUSTER GSL_CLUSTER

      WITH (namenode=‘hadoop-head’,namenode_port=9000,

      jobtracker=‘hadoop-head’,jobtracker_port=9010);
```


创建文件格式：

```
CREATE HADOOP_FILEFORMAT TEXT_FORMAT

  WITH (INPUT_FORMAT=‘polybase.TextInputFormat’,

  OUTPUT_FORMAT = ‘polybase.TextOutputFormat’,

  ROW_DELIMITER = '\n', COLUMN_DELIMITER = ‘|’);

```

根据集群和文件信息，创建外部表
```
CREATE EXTERNAL TABLE hdfsCustomer

  ( c_custkey       bigint not null,   

    c_name          varchar(25) not null,

     .......
    )

WITH (LOCATION='/tpch1gb/customer.tbl',

FORMAT_OPTIONS (EXTERNAL_CLUSTER = GSL_CLUSTER,

EXTERNAL_FILEFORMAT = TEXT_FORMAT));
```

###2.HDFS Bridge
结构如图：
{% img http://dl.dropboxusercontent.com/u/64021093/pdw/Image2.png %}

HDFS shuffle阶段：通过DMS从hadoop读取数据的阶段。
涉及到hdfs中的数据处理时，处理过程如下：

* 1.跟namenode通信，获得hdfs中文件的信息

* 2.hdfs中文件信息 +  DMS实例个数 -> 每个DMS的输入文件（offset、长度） #力求负载均衡

* 3.将DMS的输入文件信息传递给各个DMS，DMS通过 openRecordReader（）方法构建RecordReader实例，直接与对应的datanode通信，获取数据，并转换为ODBC格式（有时候类型转换提前到mapreduce中以利用hadoop集群的计算能力）。读取过程中，使用了buffer机制提高效率。有时候数据会被提前到从HDFS中读出时执行，而不是到DMS中执行。这是为了充分利用hadoop集群的计算能力，节约CPU秘籍的DMS shuffle的计算。

写入hadoop的过程与此类似。

###3.查询优化

* 1.PDW Parser(在PDW Engine的进程中完成)。

* 2.SQL Server Query Optimizer(在control node的SQL Server的进程中完成)：使用bottom-up的方式进行查询优化，并在合理的位置插入数据迁移的操作符（用于分布式环境的数据迁移指令），:生成查询计划，存储在Memo数据结构（http://www.benjaminnevarez.com/2012/04/inside-the-query-optimizer-memo-structure/）中 。

* 3.XML geneator(在control node的SQL Server的进程中完成)。接收Memo，并转换格式，往下传递。

* 4.Query Optimizer(在PDW Engine的进程中完成)：根据Memo生成DSQL。

* 5.基于开销的查询优化：判定是否将SQL语句推送到Hadoop中执行。

    考虑外部表的样本数据的直方图、集群的规模等因素...选择最优优化方案。

#####样本数据处理:
   
定义对应外部表列的详细样本数据：

```
CREATE STATISTICS hdfsCustomerStats ON
hdfsCustomer (c_custkey);
```

对样本数据的处理的方式如下：

* 1.通过DMS或者map job读取sample数据，
* 2.分发到不同的comute节点的暂存表。
* 3.每个节点分别计算直方图。
* 4.汇总直方图，存储到control node数据库的catalog中

缺点是在此过程中没有利用好hadoop集群的计算能力。


###语义兼容

涉及到Java和SQL以及之间的转换。包括这三个方面：

* 数据类型的语义.
* 表达式的语义
* 异常处理机制


例如："a+b"，其中a，b都为null，SQL结果为NULL，而Java则会抛出NullException。

处理原则是：能转化的类型则做好转化包装；不能转换的则标记为无法实现，仅限PDW实现。


###举例：

```
   SELECT count (*) from Customer
  WHERE acctbal < 0
  GROUP BY nationkey
```

如图所示为处理过程


{% img  http://dl.dropboxusercontent.com/u/64021093/pdw/Image4.png %}

{% img  http://dl.dropboxusercontent.com/u/64021093/pdw/Image5.png %}

{% img  http://dl.dropboxusercontent.com/u/64021093/pdw/Image6.png %}






### Polybase的MapReduce Join实现

使用distributed hash join实现（只有equi-join能被在mapreduce中完成）

小表作为build side ，并被物化（materialized）到HDFS，大表作为probe side。

在Hadoop的Map任务中：读取物化好的build side到内存，构成hash table。

probe side经过hash后对比hash表，做正确的链接。

为了让build side置于内存中，需要计算build side的大小、每个task拥有的内存大小，task中执行其他操作需要的内存空间。
当然，build side也可能被复制多分，以提高效率。


[本文演示slides下载链接，点击获取](http://dl.dropboxusercontent.com/u/64021093/pdw/Split%20Query%20Processing%20in%20Polybase.pptx)


引用
---
* Split Query Processing in Polybase(SIGMOD’13， June 22-27,2013,New York,USA.) Microsoft Corporation
* Polybase:  What, Why, How(ppt) Microsoft Corporation
* Query Optimization in Microsoft SQL Server PDW(SIGMOD'12, May 20-24,2012,Scottsdale,Arizona,USA) Microsoft Corporation