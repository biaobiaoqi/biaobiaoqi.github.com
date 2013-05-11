---
layout: post
title: "全分布式的Hadoop初体验"
date: 2013-05-12 00:26
comments: true
description: "之前的时间里对Hadoop的使用都是基于学长所搭建起的实验环境的，没有完整的自己部署和维护过，最近抽时间初体验了在集群环境下装机、配置、运行的全过程，梳理总结到本文中。"
categories: [tech, distributed, linux, hadoop]
---

背景
---
之前的时间里对Hadoop的使用都是基于学长所搭建起的实验环境的，没有完整的自己部署和维护过，最近抽时间初体验了在集群环境下装机、配置、运行的全过程，梳理总结到本文中。

配置
---

* 内存:8G
* CPU：i5-2400 3.1GHz；
* 硬盘：960G
* 系统：windows 7旗舰 64bits
<!--more-->
* 虚拟机：VMware7.1.1
* 虚拟集群：
* * T （master节点）Ubuntu11.04 32 bits 内存512MB；硬盘100G；单核；
* * T2（slave节点） Ubuntu11.04 32 bits 内存512MB；硬盘100G；单核；
* * T3（slave节点） Ubuntu11.04 32 bits 内存512MB；硬盘100G；单核；
* * T4（slave节点） Ubuntu11.04 32 bits 内存512MB；硬盘100G；单核；

环境准备
---

#####1.节点机器的配置
配置固定IP:修改`/etc/nerwork/interfaces`
```
auto lo
iface lo inet loopback
address 192.168.108.131
gateway 192.168.108.2
netmask 192.168.108.0
broadcast 192.168.108.0
```

为了便于管理，建议按统一约定修改hostname：修改`/etc/hostname`；同时，Hadoop集群要求每个节点使用同一个账号来管理、运行，所以，也需要设置好公用账号。



#####2.集群ssh配置

ssh相关原理和操作，参见博文[《SSH原理和使用》](http://biaobiaoqi.me/blog/2013/04/19/use-ssh/)。

在每台机器上生成密钥对，并将所有机器的公钥集成到master的`~/.ssh/authorized_keys`中,之后将这个文件分发到集群所有机器上。
这样，所有机器之间都可以实现免密码的ssh访问了。

使用如下指令，可以将本机的公钥添加到master的authorized_keys文件末尾。当所有节点都执行一遍以后，再将master的authorized_keys发布到各个节点上。
```
#cat .ssh/id_rsa.pub | ssh T 'cat >> ~/.ssh/authorized_keys'
```

#####3.工具脚本

在分布式的环境里，运维工作的自动化很有必要。为了方便集群的运维，我写了两个简单的batch脚本。

######统一执行脚本

在所有节点上执行同样的动作。使用时，在master节点上调用batch脚本，参数为对应的batch执行语句。

```
#!/bin/bash
#Program:
# Execute instructions in hosts in slaveslist.
#Description:
#2013/5/8 biaobiaoqi First Release
if [ $# -lt 1 ]; then
   echo  "usage: $0 COMMAND"
   exit 0
fi

for i in `cat slaveslist`
do
   ssh biaobiaoqi@$i "$1"
done

```

脚本中使用的slaveslist文件保存着所有slave节点的hostname，需要与脚本放在同一个工作目录下。


######统一替部署脚本

将主节点的某文件或目录统一的更新部署替换到所有节点上（注意，所有节点拥有相同的目录结构，即替换的文件路径相同）。

遇到hadoop集群中节点的增删改动需要修改配置文件的，都可以通过这个脚本便捷的部署。

```
#!/bin/bash
#Program:
#    Put the dirctory into all nodes of the cluster as the same path.
#Description:
#2013/5/10     biaobiaoqi     First Release
if [ $# -lt 1 ]; then
   echo "Usage $0 DIR_PATH"
   exit 0
fi

for i in `cat slaveslist`
do
   ssh $i "rm ~/tmp -rf"
   scp -r $1 $i:~/tmp
   ssh $i "rm -rf $1;  mv ~/tmp $1"
done

```

#####4.配置hosts文件

由于hadoop体系在处理节点时，是使用的hostname，而非IP，所以必须先配置好hostname和IP的关系。
在一台机器上修改`/etc/hosts`
```
#/etc/hosts
127.0.0.1     localhost
192.168.108.128     T3
192.168.108.129     T2
192.168.108.130 T
192.168.108.131 T4
```
然后使用统一执行脚本，将它发布到所有节点上。

值得注意的是，在`/etc/hostsname`中修改了host name之后，如果不同步的修改`/etc/hosts`中的相关信息，则在sudo操作时出现 `sudo: unable to resolve host`  的提示。原因是机器无法解析主机名。

修改`/etc/hosts`时也要特别注意，如果改成`127.0.0.1 localhost HOSTNAME` (其中HOSTNAME是主机名)的形式，在开启hadoop集群时，会出现datanode无法正常访问namenode，算是个小bug吧。所以得把hosts文件写成如上的形式。


#####5.配置Java环境
Hadoop需要Java1.6或更高版本，记住Java的安装目录，之后需要在hadoop配置过程中用到。


安装Hadoop
---
#####1.下载Hadoop

从官网下载[Hadoop发布版](http://www.apache.org/dyn/closer.cgi/hadoop/common/)（博主使用的是较早的稳定版0.20.2）

关于版本选择，推荐阅读：[Hadoop版本选择探讨](http://dongxicheng.org/mapreduce-nextgen/how-to-select-hadoop-versions/)

#####2.部署

解压下载好的Hadoop，后放到合适的目录下。这里假定放置在/home/USER/ 的目录下

在`/home/USER/.bashrc`(其中USER为集群的用户名)文件中，增加如下语句，设定Hadoop相关的路径信息：
```
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk
export HADOOP_HOME=/home/hadoop/Hadoop
export HADOOP_CONF=$HADOOP_HOME/conf
export HADOOP_PATH=$HADOOP_HOME/bin
export PATH=$HADOOP_PATH:$PATH
export CLASSPATH=.:$JAVA_HOME/bin:$PATH:$HADOOP_HOME:$HADOOP_HOME/bin
```

######Hadoop核心配置修改

配置文件在`$HADOOP_HOME/conf`目录下，其中基础配置比较重要的有三个：core-site.xml, hdfs-site.xml, mapred-site.xml。（当然，每个配置文件都有其细节作用，不过在初步实践hadoop时，理解这三个配置文件中的几个重要配置项就够了）

一般的，有三种可选模式。即本地模式、伪分布式模式和全分布式模式。前两种只是在单机环境下，后一种才是生产环境下的常用方式。《Hadoop权威指南》和《Hadoop实战》等书中都有讲到不同方式的配置，这里博主仅描述实验环境下4节点的全分布式配置。


core-site.xml整个hadoop的顶层配置
```
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration> 
    <property>
         <name>hadoop.tmp.dir</name>
         <value>/home/biaobiaoqi/UDMS/hadoop-data/tmp-base</value>
         <description>
        存放临时目录的路径，默认也被用来存储hdfs的元数据和文件数据，值得注意的是，hadoop账户对所设定的本地路径是否有足够的操作权限。之后再hdfs-site.xml中设定的dfs.data.dir和dfs.name.dir也要注意同样的问题
        </description> 
    </property> 

     <property>   
          <name>fs.default.name</name> 
          <value>hdfs://T:9000/</value>
          <description>
        默认文件系统的标记。这个URI标记了文件系统的实现方式。UIR的协议决定了文件系统的实现类，而后面的值决定了文件系统的地址、端口等信息。
        </description>
     </property> 


</configuration>

```

hdfs-site.xml存储HDFS相关的信息

```
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration> 
    <property>   
          <name>dfs.replication</name>   
          <value>3</value>   
          <description>默认的块的副本数量。实际的副本数量可以在文件写入的时候确定，默认的副本数则是在没有指定写入副本时被使用。 </description> 
     </property>
    <property>
         <name>dfs.name.dir</name>
          <value>/home/hadoop/hadoop-data/meta-data</value>
        <description>
        设定hdfs的元数据信息存储地址。在namenode上。
        </description>
     </property>
     <property>
          <name>dfs.data.dir</name>
          <value>/home/hadoop/hadoop-data/data</value>
        <description>
        设定hdfs的数据存储地址。在datanode上。
        </description>
     </property>

</configuration>

```

mapred-site.xml存储mapreduce作业相关配置
```
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration> 
    <property>   
          <name>mapred.job.tracker</name>
          <value>T:9001</value>   
          <description> Mapreduce 的job tracker所在的节点和端口。</description> 
     </property>
</configuration>

```

hosts文件存储了master节点

```
T
```

slaves文件存储着所有的slaves节点
```
T2
T3
T4
```


启动集群
---

#####1.格式化namenode

如果是第一次起动集群，需要先格式化HDFS。

namenode存放了HDFS的元数据，故可以看成是对HDFS的格式化。

```
$HADOOP_HOME/bin/hadoop namenode -format
```


#####2.启动守护进程

```
$HADOOP_HOME/bin/start-all.sh 
```
等价于如下命令执行：
```
# start dfs daemons
$"$bin"/start-dfs.sh --config $HADOOP_CONF_DIR

# start mapred daemons
$"$bin"/start-mapred.sh --config $HADOOP_CONF_DIR

```
如果成功，打开 http://T:50070 (T为集群master节点)，可以看到HDFS的运行情况，包括节点数量、空间大小等。这是Hadoop自带的HDFS监控页面；同样的，http://T:50030 是Mapreduce的监控界面。

如果没有成功，根据$HADOOP_HOME/logs目录下的日志文件信息debug。

#####3.常见问题

* namenode无法启动：
* *  删除掉本地文件系统中HDFS的目录文件，重新格式化HDFS。
* * HDFS目录的权限不够，更改权限设置等。
* namenode启动成功，datanode无法连接：检查hosts文件是否设置正确；检查各个配置文件中地址值是否使用了IP而不是hostname。
* namenode启动成功，datanode无法启动：Incompatible namespaceIDs，由于频繁格式化，造成dfs.name.dir/current/VERSION与dfs.data.dir/current/VERSION数据不一致。
* SafeModeException： 分布式系统启动时，会进入安全模式，安全模式下，hadoop是无法执行的。一般的等待一会儿，就可以正常使用了。如果是由于之前集群崩溃造成的无法自动退出安全模式的情况，则需要如下特殊处理了
```
$/$HADOOP_HOME/bin/hadoop dfsadmin -safemode leave 
```


初体验
---

最简单的尝试就是使用Hadoop自带的wordcount程序了，参照[这篇文章](http://www.cnblogs.com/xia520pi/archive/2012/05/16/2504205.html)，描述很详细。

其他的一些尝试： [动态增删节点](http://www.cnblogs.com/rilley/archive/2012/02/13/2349858.html) 、 [修改备份数量](http://www.cnblogs.com/ggjucheng/archive/2012/04/18/2454696.html)


参考
---

[offical document: Cluster Setup](http://hadoop.apache.org/docs/stable/cluster_setup.html)
