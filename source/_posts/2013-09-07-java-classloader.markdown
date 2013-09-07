---
layout: post
title: "Java 类加载器"
date: 2013-09-07 23:15
comments: true
categories: [tech]
tags: [java, jvm, bytecode]
description: "Java Class Loader 原理，浅析。 Java类加载器。bootstrap class loader，extension class loader，System Class Loader"

---

##背景知识

Java平台无关的特性是由JVM(Java 虚拟机)支撑的。不同平台有不同的JVM支持。

计算机领域有这么一句话：

> 计算机科学领域的任何问题都可以通过增加一个间接的中间层来解决。

JVM其实也可以看做是运行的Java程序和实际的硬件架构之间的一个新抽象层。

一个Java程序从编写到执行的流程一句话概括如下：首先将Java源代码（\*.java文件）编译成字节码（\*.class文件，字节码之于Java源码，类比于汇编代码之于C源码），然后由JVM运行那些字节码文件。

JVM工作原理如下图

![JVM framework](https://dl.dropboxusercontent.com/u/64021093/Java%20Classloader/JVM%E5%B7%A5%E4%BD%9C%E5%8E%9F%E7%90%86.gif)


Java中所有的类文件都需要由类加载器（Class Loader）装载到JVM中。可以简单的将JVM理解为一个工厂，类文件就是等待加工的原料，加载器则是装载货物的工人。Java类被装载之后，才能进入到JVM的运行时机制中，开始运行。


##类加载器的作用

顾名思义，Java类加载器的作用是向JVM中装载类。

这种动态装载的技术是Java的一种创新，让类能够动态加载到JVM中执行（更详细的介绍参见 [Java programming dynamics, Part 1: Java classes and class loading](http://www.ibm.com/developerworks/java/library/j-dyn0429/)）。 

<!--more-->

而它的意义远非仅仅是加载类这么简单。实际上，类加载器对Java的沙箱模型具有重大意义。他和安全管理模块（负责对类文件中的字节码进行校验，防止恶意代码的攻击）一起保证了JVM运行的安全性。

##类加载机制

大体上，每个Java应用使用了如下几种类型的类加载器:  

* 1.引导类加载器（bootstrap class loader）

	它由C++编写（注意，它非常特殊，并非Java中的ClassLoader类的子类）。当JVM启动时，引导类加载器也随之启动，它负责加载Java 核心类，如JRE的rt.jar、charsets.jar等。从Java1.2开始，它只加载Java核心API部分。

	因为这些类是系统信任的类，所以这里的装载，跳过了很多对字节码的验证过程。
	
* 2.扩展类加载器（extension class loader）
  
   它负责加载/lib/ext中的java扩展类。
   
* 3.系统类加载器（System Class Loader）
  
  这是很重要的一个加载器，加载Java的路径classpath下的类。应用程序的装载默认由它负责。

* 4.自定义类加载器

   由系统类加载器继承得到。它的存在让我们能定制出各种不同功能的加载器，增加了Java的可扩展性。自定义的类加载器如果没有显示的继承关系，则其父类默认为系统类加载器。

一个JVM，只拥有一个引导类加载器，同时可以拥有多个自定义类加载器，方便不同应用环境的用户定制。比如，自定义类加载器能够动态的修改字节码，让它能接收并加载从网上传来的类文件或Jar包，甚至是任何编码方式的压缩包。只要自定义类加载器能够正确识别并调用相应方法来实现类的加载和解析，一切都有可能。

四种加载器不是四个独立的部分，他们之间具有一种特殊的父子关系，每个类加载器都保持着他们的父加载器的应用，共同组成了一条父子关系链，被称作 parent-delegation模式。如下图

![class loader hirerachy](https://dl.dropboxusercontent.com/u/64021093/Java%20Classloader/java%20classloader%20hierachy.gif)

类加载器按照如此树形排列。类加载的查找顺序是：

cache --> parent --> self

子类加载器需要加载某个类时，并不是直接加载，而是首先查看cache（cache可以理解为加载器已经加载过的类的记录）。如果没有，则向父加载器提出请求，查看是否存在于父加载器的cache中。如此往上，直到根部的引导类加载器。如果引导类加载器的cache也没有这个类，则它尝试直接加载这个类，如果无法成功，则请求儿子加载器加载，依次往下。

直接接受程序请求加载某类的加载器被称作初始类加载器（Initiating class loader），而最终加载了该类的加载器则成为定义类加载器（defining class loader）。

类加载器的`getParent()`方法可以获得加载器的父亲。下面的代码用于输出各个层级的类加载器。

```java

public class ClassLoaderTest {    
    public static void main(String[] args) {    
        ClassLoader loader = Thread.currentThread().getContextClassLoader();    
        System.out.println("current loader:"+loader);    
        System.out.println("parent loader:"+loader.getParent());    
        System.out.println("grandparent loader:"+loader.getParent().getParent());    
    }    
}    

```

显示的结果是

```
current loader:sun.misc.Launcher$AppClassLoader@1c78e57
parent loader:sun.misc.Launcher$ExtClassLoader@5224ee
grandparent loader:null

```

grandparent显示的值是null，并不意味着他没有parent，而是因为它是由C++编写的引导类加载器。他并不是ClassLoader类的子类，也就无法使用getParent()方法获得返回了。

如此，parent class loader总是拥有更高的加载优先级，这让想利用自定义加载器伪装加载某些重要类的恶意代码无法得逞。如果好奇，你可以尝试自己写package java.lang里的String类，加载执行试试～
另外，当类A调用另类B时，B会由加载A的class loader加载，从而实现。



##加载类的流程

类的装载大致可以分为三个步骤（如下图）：

* 1.装载(loading)
* 2.链接(linking)
* 3.初始化(initialising)

![class loader process](https://dl.dropboxusercontent.com/u/64021093/Java%20Classloader/ClassLoaderProcess.gif)

跟C++或者C程序有很大的不同，编译过后的类文件中的字节码并没有设计好内存布局，这些需要等到加载之后的链接阶段，才会完成。这也是java可移植性中精彩的一笔！

关于类的加载、链接和初始化，请参见另一篇博文：[《Java类的装载、链接和初始化》](http://biaobiaoqi.me/blog/2013/09/08/java-class-loading-linking-and-initialising/)

关于类加载器的编程实践，请参见另一篇博文：[《Java类加载器编程实践》](http://biaobiaoqi.me/blog/2013/09/08/java-class-loader-in-practice/)
