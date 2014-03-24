---
layout: post
title: "对Java字符串的探究"
date: 2013-09-08 13:01
comments: true
categories: [tech]
tags: [Java, JVM, 字节码, 技术]
description: "string interning, 常量池 constant pool， 字符串池 string pool"

---


##问题的出发点

在网上看到一道题：

```java
String str = new String("abc");
```

以上代码执行过程中生成了多少个String对象？

答案写的是两个。"abc"本身是一个，而new又生成了一个。


##"abc"是什么

查看这句程序的字节码，如下：
```
NEW String  
    DUP  
    LDC "abc"  
    INVOKESPECIAL String.<init>(String) : void  
    ASTORE 1   
```
指令`ldc indexbyte`的含义：将两字节的值从indexbyte索引的常量池中加载到方法栈上。

指令`LDC "abc"`说明了"abc"并不是直接以对象存在的，而是存在于常量池的索引中。String的构造函数调用命令实际使用的就是String类型作为参数，那么，栈上应该有一个String类型的索引。

由此我们得出，在字节码中，ldc命令在常量池中找到了能索引到“abc”那个String对象的索引值。

##常量池

常量池是类文件（.class）文件中的一部分，记录了许多常量信息，索引的字符串信息。

由于Java是动态加载的，类文件并没有包含程序运行时的内存布局，方法调用等无法直接记录出方法的物理位置，常量池通过索引的方法解决了这个问题。
<!--more-->
常量池中存着许多表，其中Constant_Utf8_info表中，记录着会被初始化为String对象的字符串的字面值（iteral）。
而在String 的java doc中，有对String字面值的说明：

> All string literals in Java programs, such as "abc", are implemented as instances of this class.

在Java编译的过程中，确定下来的String字面值都先被优化记录在常量池中（那些双引号字符串，都是以CONSTANT_utf8_info的形式存储在常量池中的）。也就是说，Java源代码文件中出现的那些诸如"abc"字符串，都已经被提前放在了常量池中。

可以使用如下代码验证这一点：

```java
public class Program  
{  
    public static void main(String[] args)  
    {  
       String str1 = "Hello";    
       String str2 = "Hello";   
       System.out.print(str1 == str2);  
    }  
}  
```

输出结果是true.说明"Hello"作为对象是被程序从同一个内存空间读取出来的。

常量池是编译时产生的，存在于类文件中（\*.class文件）。运行时，JVM中每个对象都拥有自己的运行时常量池（run time constant pool）。


##字符串池


我在JDK 6.0源码的String类中，发现了一个有趣的method：intern() ,我翻译如下：

> 当intern方法被调用，如果池中已经拥有一个与该String的字符串值相等（即equals()调用后为true）的String对象时，那么池中的那个String对象会被返回。否则，池中会增加这个对象，并返回当前这个String对象。

其中有介绍一个字符串池的东西：字符串池（String pool），初始是空的，由类私有的控制。

查看java.lang.String的源代码，发现Intern()方法是一个native方法，即本地实现的方法，而不是Java方法，这让我们不能直观的看到字符串池的实现细节。不过能够理解字符串池其实是类似于线程池的缓冲器，可以起到节约内存的作用。如下代码可以验证

```java
package biaobiaoqi.thinkingInJava;  

public class Test {  
    public static void main(String[] args){  

        String strA1 = "ab";  
        String strA2 = "c";  
        String strB1 = "a";  
        String strB2 = "bc" ;  
        System.out.println((strA1+strA2).intern() == (strB1 + strB2).intern());  
          
    }  
}
```
输出结果为true。


现代的JVM实现里，考虑到垃圾回收（Garbage Collection）的方便，将内存区域[heap](http://en.wikipedia.org/wiki/Java_Virtual_Machine#Heap)划分为三部分： young generation 、 tenured generation（old generation）和 permanent generation(也就是方法区），方法区存储着类、静态变量、常量等信息。字符串池是为了解决字符串重复的问题，存在于方法区中。


回过头来看看文章刚开始的那个问题。

```java
String str = new String("abc");
```
这里确实是有两个String对象生成了。`new String("xxx")` 创建的String 对象会在堆中生成对象。而如果使用`String str = "xxx"`则先查看字符串池 是否已经存在，存在则直接返回该String 对象，否则生成新的String 对象，并将它加入字符串池中。

##intern()的应用

在JDK 源码中查找对String.intern()的调用，发现诸如java.lang.Class中就有方法调用了它：
```
 private Field searchFields(Field[] fields, String name) {
        String internedName = name.intern();
        for (int i = 0; i < fields.length; i++) {
            if (fields[i].getName() == internedName) {
                return getReflectionFactory().copyField(fields[i]);
            }
        }
        return null;
    }
```
这里获得的internedName


##总结

* 编译Java源代码时，源文件中出现的双引号内的字符串都被收纳到常量池中，用CONSTANT_utf8_info项存储着。

* JVM中，相应的类被加载运行后，常量池对应的映射到JVM的运行时常量池中。其中每项CONSTANT_utf8_info（也就试记录那些字符串的）都会在常量引用解析时，自动生成相应的internal String，记录在字符串池中。

* 尽量使用`String str = "abc";`，而不是`String str = new String("abc")；`。用new的方法肯定会开辟新的堆空间，而前者的方法，则会通过string interning优化。

* JDK的实现也一直在优化，

###参考资料

* [Busting java.lang.String.intern() Myths](http://www.codeinstructions.com/2009/01/busting-javalangstringintern-myths.html)
* [What is String literal pool? How to create a String](http://www.xyzws.com/Javafaq/what-is-string-literal-pool/3)
* [What type of memory (Heap or Stack) String constant pool in Java gets stored?](http://stackoverflow.com/questions/4918399/what-type-of-memory-heap-or-stack-string-constant-pool-in-java-gets-stored)
