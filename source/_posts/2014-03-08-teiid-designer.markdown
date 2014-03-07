---
layout: post
title: "数据集成工具Teiid Designer的环境搭建"
date: 2014-03-08 01:07
comments: true
categories: [tech]
tags: [技术, 数据集成, 技术, Teiid]
description: "数据集成工具Teiid Designer 的环境搭建。Teiid，通过抽象和联邦技术，实现分布式数据源的实时数据访问和集成，无需从记录系统中复制或移动数据。XML，MySQL，CSV 多数据源"

---

由于实验室项目要求的关系，看了些数据汇聚工具Teiid的相关知识。这里总结下Teiid的可视化配置工具Teiid Designer的部署过程。

##背景知识

数据集成是把不同来源、格式、特点性质的数据在逻辑上或物理上有机地集中，从而为企业提供全面的数据共享。数据集成的方式多种多样，这里介绍的[Teiid](http://www.jboss.org/teiid/)是其中的一种：通过抽象和联邦技术，实现分布式数据源的实时数据访问和集成，无需从记录系统中复制或移动数据。

[《Teiid 基于数据联邦的集成方案》](http://blogs.ejb.cc/archives/3552/teiid-scalable-information-integration-program)是一篇关于Teiid的中文介绍，比较详细。

由于适配不同数据源和生成虚拟数据库（VDB）需要维护好几个配置文件，直接手动部署Teiid比较难受。好在Teiid提供了辅助工具[Teiid Designer](http://www.jboss.org/teiiddesigner)，这是一个Eclipse插件，能帮助用户可视化的管理数据的集成过程。

接下来记录了Teiid 和 Teiid Designer的环境配置步骤，如有纰漏，多谢指出=)。

##环境准备

* 操作系统：OS X 10.9.1
* 语言版本：Java6
* 下载IDE： [Eclipse Kepler](https://www.eclipse.org/downloads/packages/eclipse-standard-431/keplersr1)
* 下载[Jboss EAP6.1 Alpha](http://www.jboss.org/jbossas/downloads.html)
* 下载[Teiid Runtime 8.4](http://sourceforge.net/projects/teiid/files/teiid/8.4/Final/teiid-8.4.0.Final-jboss-dist.zip/download)
* [Teiid Designer](http://www.jboss.org/teiiddesigner.html)：作为Eclipse插件，将使用Eclipse的install new software功能在线安装。

<!--more-->

##Jboss配置

配置环境变量 JBOSS_HOME，指向Jboss的根路径。在我的shell配置文件~/.zshrc中增加如下行：

`JBOSS_HOME=~/Development/jboss #jboss的根路径`

执行$JBOSS_HOME/bin/add-user.sh，给Jboss添加账号，执行过程如下：
```
What type of user do you wish to add?
 a) Management User (mgmt-users.properties)
 b) Application User (application-users.properties)
(a): b

Enter the details of the new user to add.
Realm (ApplicationRealm) :
Username : biaobiaoqi
Password :
Re-enter Password :
What roles do you want this user to belong to? (Please enter a comma separated list, or leave blank for none)[  ]:
About to add user 'biaobiaoqi' for realm 'ApplicationRealm'
Is this correct yes/no? yes
Added user 'biaobiaoqi' to file '/Users/shenyapeng/Development/jboss/standalone/configuration/application-users.properties'
Added user 'biaobiaoqi' to file '/Users/shenyapeng/Development/jboss/domain/configuration/application-users.properties'
Added user 'biaobiaoqi' with roles  to file '/Users/shenyapeng/Development/jboss/standalone/configuration/application-roles.properties'
Added user 'biaobiaoqi' with roles  to file '/Users/shenyapeng/Development/jboss/domain/configuration/application-roles.properties'
Is this new user going to be used for one AS process to connect to another AS process?
e.g. for a slave host controller connecting to the master or for a Remoting connection for server to server EJB calls.
yes/no? no

```

##Teiid配置

解压下载好的Teiid Runtime 8.4 文件，注意到其目录格式跟JBoss很相似。直接将这些文件覆盖到Jboss的根目录下。

##Teiid Designer配置

* 1.打开Eclipse，选择Help > Install New Software
* 2.在弹出的界面中选择 Add，名称输入Enter JBossASTools（其他的名称也无所谓啦），地址栏输入如下地址，并点击确认。
 
`http://download.jboss.org/jbosstools/updates/release/kepler/integration-stack/`

* 3.接下来展开Data Virtualization，选择4个Teiid Designer的功能。
* 4.然后点击下一步，直到安装完毕，重启Eclipse就可以看到Teiid Designer的界面啦。

##创建Teiid server

Teiid 依托于Jboss服务器，在Teiid Designer中可以方便的创建Teiid服务器，如下图
![img](http://biaobiaoqi.u.qiniudn.com/0CD17B0C-7A6C-425B-A12C-0FDA82FDE8F5.png?imageView/2/w/800/h/800)

创Teiid Server期间需要的配置有：

* Jboss的版本号（不要选错，这里使用Jboss EAP6.1，而不是Jboss AS 6.x）
* Jboss的根路径；
* 启动的配置文件是：standalone-teiid.xml（而不是standalone.xml，参见[社区提问](https://community.jboss.org/message/790461)）
* 在Jboss服务器的配置页面配置Management Login Credentials，使用之前注册的账号和密码。如下图
![img](http://biaobiaoqi.u.qiniudn.com/A6E53DAD-703B-4D9A-AAFA-39C2AC19A02F.png?imageView/2/w/800/h/800)

配置完成后，即可启动服务器。

现在，可以在Teiid Server的页面（双击创建的server）测试管理账号的连接和JDBC访问方式的连接是否通畅，如下图：（Test Administration Connection & Test JDBC Connection）

![img](http://biaobiaoqi.u.qiniudn.com/B13BC18B-AF6C-44DB-96C9-B18D70EDA1AA.png?imageView/2/w/800/h/800)

JDBC的用户名和密码默认是user:user, 在`$JBOSS_HOME/standalone/configuration/teiid-security-users.properties`中配置。

接下来，就可以配置数据源，享受Teiid的数据虚拟化了 =)。可以参见另一篇博文：[《数据集成工具：Teiid实践》](http://biaobiaoqi.me/blog/2013/10/19/data-integration-tool-teiid/)

##雷区

* 如果是使用Windows安装配置，需要使用32位的JVM运行Eclipse。
* 整个体系耦合比较多，而且暂时多版本兼容不够，下载的各个组件版本号一定要对应。



