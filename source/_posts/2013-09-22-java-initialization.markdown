---
layout: post
title: "Java类、实例的初始化顺序"
date: 2013-09-22 21:53
comments: true
categories: [tech]
tags: [java, jvm]
description: "阿里巴巴2013校招笔试题，java类的加载、对象的初始化过程、顺序。"

---

今晚是阿里巴巴2013校园招聘的杭州站笔试。下午匆忙看了两张历年试卷，去现场打了瓶酱油。

题目总体考察点偏基础，倒数第二题（Java附加题）比较有趣，考察了Java初始化机制的细节，在此摘录出来。


##题目

求如下java代码的输出：

``` java

class T  implements Cloneable{
	public static int k = 0;
	public static T t1 = new T("t1");
	public static T t2 = new T("t2");
	public static int i = print("i");
	public static int n = 99;
	
	public int j = print("j");
	{
		print("构造快");
	}
	
	static {
		print("静态块");
	}
	
	public T(String str) {
		System.out.println((++k) + ":" + str + "    i=" + i + "  n=" + n);
		++n; ++ i;
	}
	
	public static int print(String str){
		System.out.println((++k) +":" + str + "   i=" + i + "   n=" + n);
		++n;
		return ++ i;
	}
	
	public static void main(String[] args){
		T t = new T("init");
	}
}

```

<!--more-->

##分析

代码主要考察的是类、变量初始化的顺序。

一般的，我们很清楚类需要在被实例化之前初始化，而对象的初始化则是运行构造方法中的代码。

本题的代码显然没有这么简单了。本题中涉及到了`static {…}` 和 `{…}`这种形式的代码块，以及在类的静态变量中初始化该类的对象这种交错的逻辑，容易让人焦躁（类似于密集恐惧症吧=(）。实际上，按照[类的装载、链接和初始化逻辑](http://biaobiaoqi.me/blog/2013/09/08/java-class-loading-linking-and-initialising/)，以及[对象初始化的顺序](http://biaobiaoqi.me/blog/2013/09/08/strange-behavior-using-braces-in-java/)来思考，不难得到答案。


###代码组成


* 成员变量
	2~6行的变量是static的，为类T的静态成员变量，需要在类加载的过程中被执行初始化；第8行的`int j`则为实例成员变量，只再类被实例化的过程中初始化。

* 代码段
	9~11行为实例化的代码段，在类被实例化的过程中执行；13~15行为静态的代码段，在类被加载、初始化的过程中执行。

* 方法
	方法`public static int print(String str)` 为静态方法，其实现中牵涉到k,i,n三个静态成员变量，实际上，这个方法是专门用来标记执行顺序的方法；T的构造方法是个实例化方法，在T被实例化时调用。

* main方法
	main方法中实例化了一个T的实例。

###执行顺序分析

在一个对象被使用之前，需要经历的过程有：类的装载 -> 链接（验证 -> 准备 -> 解析） -> 初始化 -> 对象实例化。（详情参见[《Java类的装载、链接和初始化》](http://biaobiaoqi.me/blog/2013/09/08/java-class-loading-linking-and-initialising/)），这里需要注意的点主要有：

* 在类链接之后，类初始化之前，实际上类已经可以被实例化了。
	
	就如此题代码中所述，在众多静态成员变量被初始化完成之前，已经有两个实例的初始化了。实际上，此时对类的实例化，除了无法正常使用类的静态承运变量以外（还没有保证完全被初始化），JVM中已经加载了类的内存结构布局，只是没有执行初始化的过程。比如第3行`public static T t1 = new T("t1");`，在链接过程中，JVM中已经存在了一个t1，它的值为null，还没有执行`new T("t1")`。又比如第5行的`public static int i = print("i");`，在没有执行初始化时，i的值为0，同理n在初始化前值也为0.

* 先执行成员变量自身初始化，后执行`static {…}`、`{…}`代码块中的内容。

	如此策略的意义在于让代码块能处理成员变量相关的逻辑。如果不使用这种策略，而是相反先执行代码块，那么在执行代码块的过程中，成员变量并没有意义，代码块的执行也是多余。

	
* 类实例化的过程中，先执行隐式的构造代码，再执行构造方法中的代码
	这里隐式的构造代码包括了`{}`代码块中的代码，以及实例成员变量声明中的初始化代码，以及父类的对应的代码（还好本题中没有考察到父类这一继承关系，否则更复杂;)）。为何不是先执行显示的构造方法中的代码，再执行隐式的代码呢？这也很容易解释：构造方法中可能就需要使用到实例成员变量，而这时候，我们是期待实例变量能正常使用的。


有了如上的分析，也就能推到出最终的输出结果了。实际上，这几个原则都不需要死记硬背，完全能通过理解整个JVM的执行过程来梳理出思路的。


##答案

```

1:j   i=0   n=0
2:构造快   i=1   n=1
3:t1    i=2  n=2
4:j   i=3   n=3
5:构造快   i=4   n=4
6:t2    i=5  n=5
7:i   i=6   n=6
8:静态块   i=7   n=99
9:j   i=8   n=100
10:构造快   i=9   n=101
11:init    i=10  n=102


```

###参考：

* [《Java构造方法中的执行顺序》](http://biaobiaoqi.me/blog/2013/09/08/strange-behavior-using-braces-in-java/)
* [《Java类的装载、链接和初始化》](http://biaobiaoqi.me/blog/2013/09/08/java-class-loading-linking-and-initialising/)
