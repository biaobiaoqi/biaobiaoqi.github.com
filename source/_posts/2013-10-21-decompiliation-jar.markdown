---
layout: post
title: "反编译Jar包"
date: 2013-10-21 12:16
comments: true
categories: [tech]
tags: [Java, JVM, 逆向工程, 技术]
description: "jadclipse，Jar包反编译"

---


Jar包(Java Archive)是对Java程序的打包，它可能包含源码，也可能没有。

对于有包含源码的Jar包，在Eclipse工程里设定好source code路径后能直接查看到远吗，对于理解代码、调试的帮助很大。而如果Jar包没有打包源码，实际上也可以通过反编译的方法得到源码。道理很简单，Java规范中，生成的.class文件所包含的信息完全能逆向的重构出源码。

当然，一些代码为了防止自身Jar包被人反编译，会做[代码混淆](http://zh.wikipedia.org/wiki/%E4%BB%A3%E7%A0%81%E6%B7%B7%E6%B7%86)掩人耳目。其中最简单的一种方法就是是通过修改类名、变量名、方法名等方法让反编译的源码难于阅读理解。不过这个方法在混淆的时候需要特别注意：不能混淆对外提供接口的类。如果混淆了提供给外部的API接口的名字，整个工程就无法被正常使用了。

本文要举例的是对[阿里云开放云存储Java SDK](http://help.aliyun.com/origin?helpId=664)的反编译。由于SDK需要暴露接口给其他开发人员调用，本身确实没有做混淆（不理解阿里云为何没有将它开源出来），故可以做简单的反编译来查看源码。

<!--more-->

##Jadclipse的安装使用

Jadclipse插件的反编译功能源于Java反编译工具Jad。但用裸的Jad来命令行执行不太友好，于是就有了Jadclipse。


###1.下载Jad反编译工具

下载好Jad工具，解压后放在合适的路径下。
[Jad下载链接](http://varaneckas.com/jad/)


###2.安装插件

按照Eclipse版本下载匹配的Jadclipse插件：[下载链接](http://sourceforge.net/projects/jadclipse/files/?source=navbar)。（这个插件的最近修改是2007年，只要不是使用的老掉牙的Eclipse，都可以下载最新的插件版本jadclipse3.3）。

解压后，将对应版本的.jar包放入Eclipse的插件目录(eclipse/plugins)下。


###3.配置Jadclipse

插件中有两个一定要配置好的选项：

* Jad执行文件的路径
* .class文件打开时的关联工具

以下配置路径的方式可能Windows跟Mac版本的Eclipse各不相同，不过都比较简单，可以自行Google。

####3.1 Jad执行文件路径

在Eclipse中，依次打开 `Preference -> Java -> JadClipse`，修改`Path to decompiler`的值，定位到Jad的执行文件路径。

####3.2 .class关联工具

由于Eclipse默认.class文件打开使用的是Class File Viewer，如果.class没有关联的源文件，则无法查看源代码。需要将`.class without source`类型的文件的关联编辑器首选设置为JadClipse Class File Viewer。

打开方式如下： `Windows—> Perference—>General->Editors->File Associations`

###4.测试

配置好后，可能需要重启Eclipse（或许是插件本身不够Robust，博主在没有重启的情况下尝试打开没有附带源代码的.class文件时失败了，重启后一切ok）。

下载阿里云开放云存储SDK：[下载链接](http://help.aliyun.com/origin?helpId=664)，解压后，将相应的Jar包加入到工程中。

点击其中的某个.class文件，即可显示出它的源代码。文件的头部会有Jad的相关信息：

```java
/*jadclipse*/// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) radix(10) lradix(10) 
// Source File Name:   HmacSHA1Signature.java

…

```


###PS

后来Google相关内容时，找到了JadClipse在Eclipse Market的版本：[请戳](http://marketplace.eclipse.org/content/jadclipse-eclipse-4x)，或许对大家有用=)