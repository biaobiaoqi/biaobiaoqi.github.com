---
layout: post
title: "Java构造方法中的执行顺序"
date: 2013-09-08 12:58
comments: true
categories: [tech]
tags: [Java, JVM, 字节码, 技术]
description: "Java对象初始化的执行顺序。类初始化，静态方法"

---
这道题来自[stackoverflow](http://stackoverflow.com/questions/8185780/strange-behavior-using-braces-in-java/8186881#8186881)。

##问题描述：

有如下代码，求其输出内容。

```java
public class Test  
{  
    public int a = 10;  
    Test(){System.out.println("1");}  
  
    {System.out.println("2");}  
  
    static{System.out.println("3");}  
  
    public static void main(String args[])  
    {  
        new Test();  
    }  
}
```
##分析

作为静态区段的语句，容易知道，3是会最先出现的。容易弄错的一点是1和2的出现顺序。

我们可以参考字节码来分析。在eclipse中使用ASM bytecode 插件，得到相应的字节码：

```java
// class version 50.0 (50)  
// access flags 0x21  
public class Test {  
  // compiled from: Test.java  
  static <clinit>() : void  
    GETSTATIC System.out : PrintStream  
    LDC "3"  
    INVOKEVIRTUAL PrintStream.println(String) : void  
    RETURN  
  
  <init>() : void  
    ALOAD 0: this  
    INVOKESPECIAL Object.<init>() : void  
    ALOAD 0: this  
    BIPUSH 10  
    PUTFIELD Test.a : int  
    GETSTATIC System.out : PrintStream  
    LDC "2"  
    INVOKEVIRTUAL PrintStream.println(String) : void  
    GETSTATIC System.out : PrintStream  
    LDC "1"  
    INVOKEVIRTUAL PrintStream.println(String) : void  
    RETURN  
  
  
  public static main(String[]) : void  
    NEW Test  
    INVOKESPECIAL Test.<init>() : void  
    RETURN  
}
```

正如我们所想，3是被放在类构造方法中，这是类的初始化函数，固然在类的初始化时出现。
<!--more-->
而在构造方法中先出现2，之后才是1。问题的核心集中到对象构造方法的指令顺序问题。实际上，在对象构造方法中，会先执行一些隐性的指令，比如父类的构造方法、{}区段的内容等，然后再执行显性的构造方法中的指令：

1. Java编译时，对象构造方法里先嵌入隐式的指令，完毕之后，再执行Java源代码中显示的代码。
2. 那些隐式的指令，包括父类的构造方法、变量的初始化、{}区段里的内容，并严格按照这个顺序嵌入到对象的构造方法中。
3. {}区段里的内容和变量的初始化语句的执行顺序，依据源代码中本身的顺序执行。

相关文章参见：[《Java类、实例的初始化顺序》](http://biaobiaoqi.github.io/blog/2013/09/22/java-initialization/)
