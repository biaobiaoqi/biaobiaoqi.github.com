---
layout: post
title: "《Hadoop技术内幕》学习笔记——RPC和动态代理"
date: 2013-06-08 00:24
description: "《hadoop技术内幕——深入解析Hadoop Common和HDFS架构设计与实现原理》第4章的1-3节，Hadoop IPC部分的基础知识介绍。"
comments: true
categories: [tech]
tags: [distributed, hadoop, java]

---
本文是《hadoop技术内幕——深入解析Hadoop Common和HDFS架构设计与实现原理》第4章的1-3节的学习笔记。内容为Hadoop IPC部分的基础知识介绍。

知识框架
---

由于Hadoop分布式环境需要一个更高效和正对性优化的IPC机制，传统的诸如RMI的解决方案无法满足这一要求，Hadoop自己实现了一套IPC方法。

第4章第1节讲解了RPC的原理，包括Stub-Skeleton的架构等，进而用`RMI`举例（可以参考的[演示代码]()）。RMI的调用实现主要包括了服务器端的registry和客户端的lookup。虽然Hadoop不是使用RMI做IPC，但了解一下其调用方式对感性的认识到如何进行分布式环境下的远程调用还是有作用的。

接下来的2,3小节，简单的介绍了IPC过程所依赖的技术方法：Java的动态代理方式和NIO的网络传输方式。

第2节讲`动态代理`，这里需要理解面向对象的代理模式和*动态*的原因。代理模式分很多种，这里用到的是简单的对行为的传递。动态代理的动态特性，则是因为框架能提供动态创建某个接口的实现的能力(可以参考的[演示代码]())。

更系统的看动态代理过程，分为两个阶段：

* 1.代理接口的实现：静态方法Proxy.newInstance()生成动态对象。
* 2.调用转发过程：InvocationHandler实现

第3节的`NIO`，跟传统的套接字(Socket)通信过程做了对比。需要了解Socket通信的特点：同步，阻塞，基于字节，理解这种特点带来的服务器端的线程闲置的压力。对应的，NIO则是可异步的，非阻塞的，基于块的。具体的实现上，需要了解缓冲区(Buffer)的原理和使用方式，通道(Channel)和选择器(Selector)配合的使用方式。

我总结了一份slides，如下：(挂在speackerdeck上，如果加载缓慢，请稍候:))

<script async class="speakerdeck-embed" data-id="fbcb8590b1540130690c2e6f0be13e84" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

slides下载地址：[请戳](https://dl.dropboxusercontent.com/u/64021093/slides/%E8%BF%9C%E7%A8%8B%E8%BF%87%E7%A8%8B%E8%B0%83%E7%94%A8%E5%92%8CNIO.pdf)