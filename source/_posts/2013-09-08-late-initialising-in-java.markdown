---
layout: post
title: "Java类加载的延迟初始化"
date: 2013-09-08 02:00
comments: true
categories: [tech]
tags: [java, jvm, bytecode]
description: "Java类的动态加载机制规定，在类被主动使用(active use)之前，必须已经完成类的初始化。既然有主动调用，那么就有被动调用了。这两者有哪些区别呢？"

---

[《Java类的装载、链接和初始化》](http://biaobiaoqi.me/blog/2013/09/08/java-class-loading-linking-and-initialising/)中提到，链接的最后一步是解析，即对符号引用的解析。但这不是必须的，可以等到相应的符号引用第一次使用时再解析。

而类的初始化是在链接之后的（注意了，根据不同JVM有不同的实现方式，在类初始化的时候，可能已经完成了所有的符号引用的解析，也可能没有），本文所写的就是类的初始化的时机问题。


Java类的动态加载机制规定，在类被主动使用(active use)之前，必须已经完成类的初始化。既然有主动调用，那么就有被动调用了。这两者有哪些区别呢？

下面列出所有主动使用的情况，用以区分两者：

* 1.创造该类的一个新的实例
* 2.调用这个类中的静态方法
* 3.获取类或者接口中的非常量的静态变量
* 4.利用反射调用方法
* 5.初始化该类的某子类
* 6.被制定为JVM开始运行时必须初始化的类

注意，3中为何是“非常量的静态变量”。如果是常量，即声明为final的话，并不会出现对类的构造，虽然调用时有类名出现，但实际调用会直接使用常量，绕过了类的限制（详情见相关常量池和运行时常量池的知识）。

只有当一个非常量的静态变量被显示的在类或接口中声明时，它的调用才属于主动调用。对于父类中某非常量静态变量的调用属于被动使用(positive use)。

<!--more-->
如下代码
```java
public class Parent {  
     static int i = 10 ;  
  
     static{  
            System.out.println("Parent initiate");  
     }  
       
     public static void func(){  
        System.out.println("func");  
     }  
}  

public class Son extends Parent{  
    static{  
        System.out.println("Son initiate");  
    }  
      
}  

public class Test {  
    static{  
        System.out.println("Test initiate");  
    }  
      
    public static void main(String[] args){  
        System.out.println(Son.i);  
        Son.func();  
    }  
      
}  
```

运行的结果是：
```
Test initiate  
Parent initiate  
10  
func  
```

虽然有出现Son，但Son.i访问的是父类的非常量静态变量。于是没有对Son类进行初始化，而只是初始化了明确的声明静态变量的Parent类。

由此可见，一般的，我们在某个类中定义了其他类的成员变量引用，只要该变量没有new 出一个新的对象，则JVM也不会初始化这个类，类此时只是被加载了而已，而没有链接和初始化。
