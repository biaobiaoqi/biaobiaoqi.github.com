---
layout: post
title: "在Eclipse里查看Java字节码"
date: 2013-10-25 04:06
comments: true
categories: [tech]
tags: [Java, 字节码, JVM,技术]
description: "Java字节码查看，Eclipse插件，bytecode outline，ASM框架"

---

要理解Java字节码，比较推荐的方法是自己尝试编写源码对照字节码学习。其中阅读Java字节码的工具必不可少。虽然`javap`可以以可读的形式展示出.class文件中字节码，但每次改动源码都需调用命令行并不方便。这里介绍一个可以辅助阅读Java字节码的Eclipse插件：[bytecode outline](http://andrei.gmxhome.de/bytecode/)。


bytecode outline插件用可读的方式展现了Eclipse的Java编辑器或类文件的字节码内容。它使用了[ASM框 架](http://asm.ow2.org/)的部分组建来实现对字节码的展示（ASM框架在另外一篇操纵Java字节码的博文中有提到过：[《AOP实践：java.lang.instrument的使用》](http://biaobiaoqi.github.io/blog/2013/09/08/custom-premain-method/)，是一个轻量级的Java字节码的操纵框架。）。

<!--more-->


##插件安装

直接使用Update manager安装插件，非常简单：

`Help -> Install new Software... -> Work with:`

输入url：http://andrei.gmxhome.de/eclipse/

然后在弹框中选择合适的版本即可。

##使用

在Eclipse中添加相应的查看窗口：

`Window -> Show View -> Other -> Java -> Bytecode`

选中某Java源文件，效果如图：

![img](http://biaobiaoqi.u.qiniudn.com/javabytecode1.png)


同时，还可以使用同样的方法，添加Bytecode Reference窗口，用于查询各个Java字节码的文档，示例如下：

![img](http://biaobiaoqi.u.qiniudn.com/javabytecode2.png)
