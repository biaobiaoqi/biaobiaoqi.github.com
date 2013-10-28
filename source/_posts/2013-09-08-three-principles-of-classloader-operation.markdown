---
layout: post
title: "类加载器操作三原则[译]"
date: 2013-09-08 00:42
comments: true
categories: [tech]
tags: [Java, JVM, 字节码]
description: "Java classloader three principles. Java类加载器加载三原则：委托原则；可见性原则；独特性原则"

---

（出自一本J2EE的教材中关于类加载器的介绍，原文已不知所踪。）

类加载的bug，一旦在编程中遇到很难调试。好消息是，理解类加载的过程中，我们只需要牢记住三条基本原则。如果你能清晰的理解这三条基本原则，所有问题都迎刃而解。下面，我们开始介绍。


##委托原则(Delegation Principle)

> 如果一个类还没有被加载，类加载器会委托它的父亲加载器去加载它。

这种委托会一直延续，直到到达委托层次的最顶层，由原始的类加载器加载完成该类。下图展示了这种情况。

![](https://dl.dropboxusercontent.com/u/64021093/Java%20Classloader/classloader1.gif)

Systm-ClassPath classloader加载了MyApp.MyApp，而这个类创造了一个java.util.Vector。假设现在java.util.Vector还没又被加载。因为System-Classpath classloader加载了MyApp类，它首先请求它的父亲extension classloader来加载这个类（java.util.Vector）。而extension classloader又请求Bootstrap classloader尝试加载。因为java.util.Vector是J2SE类，bootstrap classloader成功加载了它。

<!--more-->
考虑一个当略微不同的情况，如下图。

![](https://dl.dropboxusercontent.com/u/64021093/Java%20Classloader/classloader2.gif)

在这种情况中，MyApp创造了一个新的用户自定义类的实例，MyClass。假设MyClass还没有被加载。像以往一样，当System-Classpath classloader接收到这个加载请求，它委托了它的父亲。最终这个委托传递到了Bootstrap classloader。但是在java 核心API里，找不到这个类。所以它的孩子加载器Extensions classloader尝试加载它。同样的，Extensions classloader也没有找到它。最终，委托请求回到了System-Classpath classloader这里。它找到了这个类并加载成功。


##可见性原则（Visibility principle）

> 被父亲类加载器加载的类对于孩子加载器是可见的，但关系相反相反则不可见。

这说明，一个类只能看见它自己的加载器或者这个加载器的父类加载器加载的类，反过来是不可以的。比如，被ClassX的父亲加载器加载的类是不能看见ClassX的。为了更清楚的理解，让我们来看一个例子，如下图。

![](https://dl.dropboxusercontent.com/u/64021093/Java%20Classloader/classloader3.gif)

图中展示了四个类加载器。类加载器A是最顶层的加载器，B是它的孩子。类加载器X和Y是B的孩子。他们各自都加载了与自己同名的类。类加载器A能看见A类，类加载器B能看见A，B类。类似的，X能看见A，B，X，Y能看见A，B，Y。但兄弟、Y之间的类是不可见的。

##独特性原则（Uniqueness Principle）

> 当一个类加载器加载一个类时，它的孩子加载器绝不会重新加载这个类。

这是因为委托原则中，一个加载器总是会委托自己的父亲加载器加载类。当层次中的父亲加载器无法加载类的时候，孩子类加载器就会（或者尝试去）加载这个类。这样，类加载的独特性就得到了保障。当父亲和孩子加载器加载了同一个类，一个有趣的情况就出现了。你可能会想这怎么可能出现？这不是违反了独特性原则？

我们用可见性原则中的示例图来解释这个问题。我们假设没有任何类被加载到这些类加载器的层次结构中。假设X类被类加载器X加载，它强制性的用类加载器X加载B类。这可以通过像Class.Name()这样的API来实现，代码如下：

```java
 public class X {

   public X() {
      ClassLoader cl = this.getClass().getClassLoader();
      Class B = Class.forName(“B”, true, cl);
   }
}

```

在X的构造函数中，B被显示的使用类加载器X加载。如果另一个被类加载器B加载的类需要访问B类，则无法实现，因为委托原则只能向父亲方向查询。如果类加载器B也加载了B类，当比较两个B类的实例时，如果一个实例来自于类加载器X，一个来自于类加载器B，则会抛出ClassCastException异常。

##总结

这三个原则 是解决程序中遇到的类加载问题的关键所在。在实际的编程中，并不需要显示的调用到类加载器，它主要出现在一些框架的代码中。但对于每一个开发者、架构师而言，都必须理解类加载的层次结构，这样才能写出优雅的代码。


###PS

注意，虽然java的加载实现中，对于bootstrap classloader 、extensions classloader 和 system classloader来说，他们的关系是parent-first，也就是像原则一中所说的那样，需要向上委托，但用户自定义的classloader完全可以跳出这个圈子，自己实现parent-lastclassloader。比如Websphere中就有相关配置。

更具体的类加载器编程实例，请见另外一篇博文：[《Java类加载器编程实践》](http://biaobiaoqi.me/blog/2013/09/08/java-class-loader-in-practice/)
