---
layout: post
title: "JVM参数调优：Eclipse启动实践"
date: 2014-01-17 11:16
comments: true
categories: [Java, JVM, Eclipse]
tags: [技术]
description: ""

---

本文主要参考自[《深入理解Java虚拟机》](http://book.douban.com/subject/6522893/)。这本书是国人写的难得的不是照搬代码注释的且不是废话连篇的技术书，内容涵盖了Java从源码到字节码到执行的整个过程，包括了JVM（Java Virtual Machine）的架构，垃圾收集的介绍等。这里摘录出关于配置JVM基本参数来调优Eclipse启动的过程，比较初级，供初学者参考。
<!--more-->
##基础知识

针对JVM的参数调优主要集中在数据区大小的控制和垃圾回收策略的选择。关于JVM运行机制等更多内容可参考[其他博文](http://biaobiaoqi.me/tags/jvm/)

###JVM的运行时数据区

运行时JVM的数据区主要包括各线程私有的栈和程序计数器，线程共享的方法区，以及管理对象的堆（又称回收堆）等。程序运行时，类信息、常量、静态变量等会被加载到方法区。运行过程中几乎所有对象都在堆里，内存占用的空间最大，这也是最值得优化得部分。

###JVM的垃圾回收策略

Java程序中，除了基本类型（primitive types），其他的数据都是以对象的形式存在。对象生命周期有长有短，如果无区别的保留在内存中，会造成内存超载。内存垃圾回收(Garbage Collection, 缩写GC)就是解决这一问题的策略。

*注意：JVM不仅仅只对对象进行垃圾回收，实际上也会对废弃常量和无用的类做回收。*

垃圾回收首先得找到需要被回收的对象，一般采用根搜索算法来标记处这些过时的对象（另外有一种简单的实现：[引用计数](http://zh.wikipedia.org/wiki/%E5%BC%95%E7%94%A8%E8%AE%A1%E6%95%B0)，但存在明显的弊端，即循环引用）。

回收垃圾的过程会消耗计算资源和时间。根据不同的处理方式，垃圾回收有不同的策略，现在常用的是分代收集算法：根据对象的存活周期将堆划分为几代：新生代（Young Generation或New Generation）和老生代（Tenured Generation），[HotSpot虚拟机](http://en.wikipedia.org/wiki/HotSpot)里还分出了永生代（基本等同于方法区）。不同代采用不同的垃圾回收策略。

####HotSpot虚拟机

HotSpot虚拟机中，Perm代指永生代，Old代指老年代，而新生代使用复制算法，将区域划分为三块：Eden，S0和S1（S是Survivor的缩写）。

IBM研究表明，新生代中的对象98%是朝生夕死的，三者的比例划分是8：1：1。对象先分配到Eden，如果Eden中内存占用量达到一定得比例，触发Minor GC，JVM会将Eden和S0(或S1)中存活的对象复制到S1（或S0），并清空Eden和S0(或S1)。如果同时老年代的内存占用量打达到一定比例，会触发Major GC（也称Full GC）。通常Major GC比Minor GC慢10倍以上。

###编译过程

Java一直号称“Write once, run anywhere”，这个特性正是由JVM这一虚拟层来支撑的。

Java源代码首先编译为Java字节码，字节码再被JVM加载运行。运行的过程可以是直接针对字节码的解释执行，也可以是经过了[JIT](http://zh.wikipedia.org/wiki/%E5%8D%B3%E6%99%82%E7%B7%A8%E8%AD%AF)（Just in time）编译为机器码后的执行。另外，还有[静态提前编译器]((http://en.wikipedia.org/wiki/AOT_compiler)(Ahead Of Time，也缩写为AOT)，能将源码直接编译为机器码。

[HotSpot虚拟机](http://en.wikipedia.org/wiki/HotSpot)的JIT编译器有：Client Complier（简称C1）、Server Complier（简称C2）以及在Java7中堆出的[分层编译器](http://docs.oracle.com/javase/7/docs/technotes/guides/vm/performance-enhancements-7.html)。C1编译器做一些快速的优化，C2做一些更耗时的优化但是产生更高效的代码，而分层编译器则结合了两者的优点：快速的启动和逐步的优化（brings client startup speeds to the server VM）。

###性能监控和故障处理工具

对于系统调优和问题定位，周志明在《深入Java虚拟机》中总结到

> 给一个系统定位问题的时候，知识、经验是关键基础，数据是依据，工具是运用知识处理数据的手段。这里说的数据包括：运行日志、异常堆栈、GC日志、线程快照、堆转储快照等……应当意识到工具永远都是知识技能的一层包装，没有什么工具是“秘密武器”。

Java提供了很多工具给开发者来监控和处理运行中的问题。包括命令行工具以及可视化工具

####命令行工具

比如jps, jstat, jinfo等。举例如下：

```
jstat -gcutil xxx #xxx是jps查出的LVMID，查看gc相关数据
jstat -gccause xxx#查看gc的原因
jinfo  -flag XXX xxx#XXX是参数名，xxx是VMID，查看虚拟机的参数值
```

####可视化工具

* JConsole：比较老得分析软件，Java自带。Windows下搜jconsole.exe，Mac下启动命令为jconsole
* [Eclipse Memory Analyzer Tool](http://www.eclipse.org/mat/)：用于分析dump下的堆数据
* [VisualVM](http://visualvm.java.net/):推荐，很全能的分析工具

###JVM参数

这里零散的罗列了一些我用到的简单的JVM配置参数：

内存大小控制：

* -Xmx20M: 堆的最大值 
* -Xms10M: 堆的初始分配内存
* -Xmn: 新生代堆的分配内存
* -Xss128k: 线程的栈空间大小
* -XX:PermSize=10M | 方法区初始大小
* -XX:MaxPermSize=10M |方法区最大值

编译相关：

* -Xint: 关闭JIT，完全使用解释执行，实践中没什么作用，解释执行很慢。
* -client: 启动C1编译器
* -server: 启动C2编译器
* -XX:+TieredCompilation: 启动分层编译器

其他：

* -XX:+DisableExplicitGC: 屏蔽System.gc()调用
* -PrintGCDetails: 让jvm在每次发生gc的时候打印日志，利于分析gc的原因和状况
* -XX:+HeapDumpOnOutOfMemoryError: 内存溢出时dump下heap，可以通过Eclipse Memory Analyzer Tool打开查看。
* -XX:HeapDumpPath=/: dump下的heap文件快照的路径。Eclipse中默认放到项目的根目录中
* -XVerify:none: 禁止字节码验证


##调优Eclipse启动的实践

###实践环境
* CPU： 2.8 GHz Intel Core i7
* 内存： 8 GB 1333 MHz DDR3
* 操作系统： OS X 10.9.1(64bits)
* Eclipse：Version: Kepler Service Release 1， Build id: 20130919-0819
* Java：java version "1.7.0_45"

###调优实践

调优Eclipse启动实际上就是调优Eclipse在JVM中的加载和程序启动阶段的运行。由于默认的Ecpise启动配置无法适应所有不同的硬件、软件环境，做针对性的调优是必要的。

Eclipse的启动配置文件是eclipse.ini，对JVM的参数调优直接在该文件中修改。OS X下，其文件路径为 $ECLIPSE/Eclipse.app/Contents/MacOS/eclipse.ini（*注意不是Eclipse文件包根目录下得eclipse.ini*）。

####测Eclipse启动时间

要优化Eclipse的启动时间，先要能确定Eclipse的启动时间。这里推荐网友实现的一个Eclipse插件：[计算启动时间的Eclipse插件](http://empirel.iteye.com/blog/1404226)。下载后放到Eclipse的插件包中，启动Eclipse即可看到弹窗显示的启动时间。为了得到一个尽可能公平的测试结果，需要在测试过程中关闭其他程序，避免CPU负载带来的误差，并多次测试取平均值。

####调优策略

使用VisualVM查看程序的运行状况来定位瓶颈，尝试调优解决。下图是VisualVM的示例图，右边图示展示了GC的状态以及编译时间、类加载时间和垃圾回收时间等指标。

![img](http://biaobiaoqi.u.qiniudn.com/visualvmscreen.png?imageView/2/w/800/h/800)

也可以通过命令行工具查看GC的状态，比如：`jstat -gc XXX #其中XXX是jps查出的进程的LVMID`.


我的实践总结如下：

* 类加载时间过长：禁止加载类时的字节码验证。我们认为Eclipse的字节码是可靠的。`-XVerify:none`
* 编译时间：`-client`缩短了编译时间，但长期运行的性能可能受影响，`-server`编译时间长，而编译优化做得更多，后期使用汇报大，`-XX:+TieredCompilation`分层编译则集合了前两者的优势。没有特殊需求，可选用这一编译选项。
* Minor GC次数太多：新生代空间太小，加大新生代的内存大小。`-Xmn800m`，同时，增大回收堆的总大小上限（`-Xmx1024m`）。
* Full GC次数太多：为了避免回收堆由小到大的动态增长增加时间开销，可将其初始大小跟最大上限设定为同一值`-Xms1024m`，并增加老年代的大小(`-XX:PermSize=256m`，`-XX:MaxPermSize=256m`)。
* 代码中的GC调用：Eclipse代码中有System.GC()的调用可能促使JVM执行垃圾回收，可以通过`-XX:+DisableExplicitGC`来防止。
* 垃圾收集器的选择：垃圾收集器有很多，比如Serial、ParNew、Parallel Scavenge、CMS、G1等。推荐使用老生代CMS新生代ParNew的组合来应对Eclipse用户交互频繁的情况(`-XX:+UseParNewGC`、`-XX:+UserConcMarkSweepGC`)。同时提升CMS的垃圾回收的触发条件：`-XX:CMSInitiatingOccupancyFraction=85`，进一步降低Full GC的出现。



####最终eclipse.ini
```
-startup
../../../plugins/org.eclipse.equinox.launcher_1.3.0.v20130327-1440.jar
--launcher.library
../../../plugins/org.eclipse.equinox.launcher.cocoa.macosx.x86_64_1.1.200.v20130807-1835
-product
org.eclipse.epp.package.standard.product
--launcher.defaultAction
openFile
-showsplash
org.eclipse.platform
--launcher.XXMaxPermSize
256m
--launcher.defaultAction
openFile
--launcher.appendVmargs
-vmargs
-Dosgi.requiredJavaVersion=1.6
-XstartOnFirstThread
-Dorg.eclipse.swt.internal.carbon.smallFonts
-Xms1024m
-Xmx1024m
-Xmn800m
-Xdock:icon=../Resources/Eclipse.icns
-XstartOnFirstThread
-Dorg.eclipse.swt.internal.carbon.smallFonts
-XX:+TieredCompilation
-XX:PermSize=256m
-XX:MaxPermSize=256m
-XX:+DisableExplicitGC
-XVerify:none
-XX:+UseParNewGC
-XX:+UserConcMarkSweepGC
-XX:CMSInitiatingOccupancyFraction=85
```


##其他参考

* [《JVM的GC简介和实例》](http://www.searchtb.com/2013/07/jvm-gc-introduction-examples.html) — 搜索技术博客－淘宝.昆仑

