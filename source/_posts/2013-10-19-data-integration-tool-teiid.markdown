---
layout: post
title: "数据集成工具：Teiid实践"
date: 2013-10-19 23:58
comments: true
categories: [tech]
tags: [技术, 数据集成, 技术, Teiid]
description: "数据集成，Teiid,通过抽象和联邦技术，实现分布式数据源的实时数据访问和集成，无需从记录系统中复制或移动数据。XML，MySQL，CSV 多数据源"

---

数据集成是把不同来源、格式、特点性质的数据在逻辑上或物理上有机地集中，从而为企业提供全面的数据共享。数据集成的方式多种多样，这里介绍的[Teiid](http://www.jboss.org/teiid/)是其中的一种：通过抽象和联邦技术，实现分布式数据源的实时数据访问和集成，无需从记录系统中复制或移动数据。

[链接](http://blogs.ejb.cc/archives/3552/teiid-scalable-information-integration-program)是一篇关于Teiid的中文介绍，比较详细。

由于适配不同数据源和生成虚拟数据库（VDB）需要维护好几个配置文件，直接手动部署Teiid比较难受。好在Teiid提供了辅助工具[Teiid Designer](http://www.jboss.org/teiiddesigner)，这是一个Eclipse插件，能帮助用户可视化的管理数据的集成过程。

* 安装配置

	参见官网的Downloads界面的详细介绍（注意：环境配置中，各组件需严格遵循官网指定版本，实践经验表明，Teiid本身并不够鲁棒，容不得小差错）。

接下来，我们用一个简单的应用场景实践Teiid的数据集成功能。

<!--more-->

##应用场景

书店主营图书销售，并维护者一个用户对图书评价的数据库。技术上说，书店拥有三个数据模块：

* MySQL数据库，存储用户信息和用户对某书的评价

	表结构如下：
	
```
create database library;
use library;
create table users (
     id int primary key,
     name char(20) not null,
     passwd char(20)) not null,
);
create table comments(
     cid int primary key,
     uid int ,
     bookid int not null,
     content char(255),
     foreign key (uid) references users(id)
);
```
* EXCEL表格，店主用于记录销售量、记录销售单价

```
book_id,price,sales
1,89.00,1000
2,52.00,9999
3,30.00,10000
4,9800,5555
5,69.00,1234
```

* XML文件记录书籍信息，包括

``` xml
<?xml version= "1.0" encoding ="UTF-8"?>
<BooksInfo>
        <Book id = "1" >
               <Title> Hadoop: The Definitive Guide </Title>
               <Author> Tom White</Author >
               <publisher> O'Reilly</ publisher>
        </Book>
        <Book id = "2" >
               <Title> Effective Java</Title >
               <Autorh> Joshua Bloch</Autorh>
               <publisher> HZ Books</ publisher>
        </Book>
        <Book id = "3" >
               <Title> C Programming Language</Title >
               <Autorh> Kernighan, Ritchie </Autorh>
               <publisher> HZ Books</ publisher>
        </Book>
        <Book id = "4" >
               <Title> Head First: Design Pattern</Title >
               <Autorh> Freeman</ Autorh>
               <publisher> Turning Education</publisher >
        </Book>
        <Book id = "5" >
               <Title> Refactoring: Improving the Design of Existing Code </Title>
               <Autorh> Martin Fowler </Autorh>
               <publisher> O'Reilly</ publisher>
        </Book>
</BooksInfo>
```

##实践

###1.创建工程

打开配置好Teiid Designer插件的Eclipse，在Teiid Designer视图的Guides中，找到Define Teiid Model Project选项，如下图：

![img](http://biaobiaoqi.u.qiniudn.com/teiid1.png)

一路点击next，在如下界面勾选sources和views即可，designer guid会帮助生成这两个目录，其他目录在此项目中不需要。

![img](http://biaobiaoqi.u.qiniudn.com/teiid2.png)


###2.导入MyQL数据源

在Guides界面，选择JDBC数据源

![img](http://biaobiaoqi.u.qiniudn.com/teiid3.png)

第一个步骤Define Teiid Model Project在上一步中已经完成了，现在需要创建一个JDBC链接，选择Create JDBC connection，在弹出的窗口中，选择Mysql数据库，然后点下一步

![img](http://biaobiaoqi.u.qiniudn.com/teiid4.png)


选择mysql驱动，配置好Mysql数据源的的url、用户名、密码，点下一步。（在这里，mysql的端口为默认的3306，library为之前配置好的mysql数据库）。点击test connection测试与mysql的链接能否建立。

![img](http://biaobiaoqi.u.qiniudn.com/teiid5.png)

接下来需要给数据源创建源模型（source model）了。同样在Guides试图上双击Create source model for JDBC data source，一路下一步，直到选择数据库和表，选择library数据库中的所有表，如下图：

![img](http://biaobiaoqi.u.qiniudn.com/teiid6.png)

创建源模型的最后一步如下图，可以自定义Model Name，为了让之后的sql查询过程更可读，我将以数据源类型命名它（mysql.xmi）。其他无关配置暂时不用理会。

![img](http://biaobiaoqi.u.qiniudn.com/teiid7.png)

finish后，就生成了一个元模型，如下图。图中可视化的显示了数据库所建的两张表

![img](http://biaobiaoqi.u.qiniudn.com/teiid8.png)


接下来可以测试数据是否可读，双击Guides中的Preview Data，在弹框中选择需要preview的表或者precedure（procedure在本工程里这里不会被用到）查询结果显示在了eclipse下方的SQL Result框中，如下图：

![img](http://biaobiaoqi.u.qiniudn.com/teiid9.png)

接下先来不用着急Define VDB，我们先把所有数据源配置完成后再一起来定义虚拟数据库。

###3.导入FlatFile数据源（CSV）

跟之前一个步骤一样，只需要沿着Guides里的路线一步一步操作。

![img](http://biaobiaoqi.u.qiniudn.com/teiid10.png)

首先创建连接，配置好后test connection确保链接无误

![img](http://biaobiaoqi.u.qiniudn.com/teiid12.png)

链接建立后，需要创建元模型。如下图，提示有错，只需要选定Source Model Definition的文件的存储位置即可。存放在项目的sources目录中

![img](http://biaobiaoqi.u.qiniudn.com/teiid13.png)

按照默认配置，不断下一步，在 Flat File Demilited Columns Parser Settings 这一步，可以注意到下方有生成一串SQL语句。这些语句告诉Teiid需要如何将csv文件中的数据映射为关系型数据。

![img](http://biaobiaoqi.u.qiniudn.com/teiid14.png)


继续下一步，view model definition界面，提示创建的tableview名字包含不合法字符。原来由于将flat file命名为sales.csv,它自动生成了price.csvView作为table name，但名字中是不能出现`.`的，于是修改为salesview，finish。

![img](http://biaobiaoqi.u.qiniudn.com/teiid15.png)

之后测试数据能否读取。在选择所要preview的数据时，需要选择相应的table，而不是模型（这里需要选择salesView，而不是上层的price_view.xmi）。如下图：

![img](http://biaobiaoqi.u.qiniudn.com/teiid16.png)

###4.导入xml数据

大部分步骤跟之前的步骤类似，在设定源模型时，需要注意配置好xml数据到关系型数据的映射关系，如下图：

![img](http://biaobiaoqi.u.qiniudn.com/teiid17.png)

XML File Contents中会根据xml文件中的数据解析出整体的层次结构。我们需要将其中的Book里的信息，添加到右边的Column Info中。虽然有很多Book数据列表显示在左边一栏里，但实际上只需要添加一次相关信息到右边的列信息中。值得注意的是，这里自动生成的Root Path是错误的，需要修改为BooksInfo/Book。其他没有什么特别的，一路下一步。

现在整个项目如下图：

![img](http://biaobiaoqi.u.qiniudn.com/teiid18.png)

###5.生成虚拟数据库

点击Guides中的Define VDB，将三个数据源的模型加入到VDB中:MySQL的源模型，XML和CSV的视图模型（注意：不可以加入另外两个源模型的xmi文件，博主如此操作后遇到了一些莫名其妙的问题）。

如此就完成了在Teiid Designer中的多数据源集成的配置了。

###6.部署和使用

通过Teiid Designer，我们能方便的部署VDB到Jboss服务器。

在Guides界面下，有execute vdb选项，双击即可。正式运行之前，需要运行Jboss server，如果没有启动服务器，Teiid Designer会弹框提醒的。

最后，尝试一下通过Teiid集成查询多个数据源。将sql语句输入到执行框中，刷蓝->右键->执行选中的语句。

```
> select * from "csv"."sales" as A join "xml"."booksinfo" as B on A.book_id = B.id

```

结果如图：

![img](http://biaobiaoqi.u.qiniudn.com/teiid19.png)


