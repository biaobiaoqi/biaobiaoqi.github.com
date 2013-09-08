---
layout: post
title: "Java方法调用的虚分派"
date: 2013-06-02 01:51
comments: true
categories: [tech]
tags: [java, jvm, bytecode]

description: "本文通过介绍Java方法调用的虚分派，来加深对Java多态实现的理解。需要预先理解Java字节码和JVM的基本框架。java virtual dispatch, method table. invokevirtual invokespecial invokeinteface invokestatic"

---

本文通过介绍Java方法调用的虚分派，来加深对Java多态实现的理解。需要预先理解Java字节码和JVM的基本框架。

##虚分配（Virtual Dispatch）

首先从字节码中对方法的调用说起。Java的bytecode中方法的调用实现分为四种指令：

* 1.invokevirtual 为最常见的情况，包含virtual dispatch机制； 
* 2.invokespecial是作为对private和构造方法的调用，绕过了virtual dispatch；
* 3.invokeinterface的实现跟invokevirtual类似。
* 4.invokestatic是对静态方法的调用。

其中最复杂的要属 invokevirtual指令，它涉及到了多态的特性，使用virtual dispatch做方法调用。

virtual dispatch机制会首先从 receiver（被调用方法的对象）的类的实现中查找对应的方法，如果没找到，则去父类查找，直到找到函数并实现调用，而不是依赖于引用的类型。

下面是一段有趣的代码。反映了virtual dispatch机制 和 一般的field访问的不同。
```java
public class Greeting {  
    String intro = "Hello";  
    String target(){  
        return "world";  
    }  
}  


public class FrenchGreeting extends Greeting {  
    String intro = "Bonjour";  
    String target(){  
        return "le monde";  
    }  
      
      
    public static void main(String[] args){  
        Greeting english = new Greeting();  
        Greeting french = new FrenchGreeting();  
          
        System.out.println(english.intro + "," + english.target());  
        System.out.println(french.intro + "," + french.target());  
        System.out.println(((FrenchGreeting)french).intro + "," + 		((FrenchGreeting)french).target());  
    }  
}  
```
运行的结果为
```
Hello,world  
Hello,le monde  
Bonjour,le monde  
```

前两行输出中，对于intro这个属性的访问，直接指向了父类中的变量，因为引用类型为父类。

第二行对于target()的方法调用，则是指向了子类中的方法，虽然引用类型也为父类，但这是虚分派的结果，虚分派不管引用类型的，只查被调用对象的类型。

既然虚分派机制是从被调用对象本身的类开始查找，那么对于一个覆盖了父类中某方法的子类的对象，是无法调用父类中那个被覆盖的方法的吗？

在虚分派机制中这确实是不可以的。但却可以通过invokespecial实现。如下代码

```java
public class FrenchGreeting extends Greeting {  
    String intro = "Bonjour";  
    String target(){  
        return "le monde";  
    }  
      
    public String func(){  
        return super.target();  
    }  
      
      
    public static void main(String[] args){  
        Greeting english = new Greeting();  
        FrenchGreeting french = new FrenchGreeting();  
          
        System.out.println(french.func());  
          
    }  
}  
```
<!--more-->
func()就成功的调用了父类的方法target()，虽然target()已经被子类重写了。具体的调用细节，从字节码中可以看到：

```
ALOAD 0: this  
INVOKESPECIAL Greeting.target() : String  
ARETURN  
```
其中使用了invokespecial指令，而不是施行虚分派策略的invokevirtual指令。


##方法表（Method Table）

介绍了虚分派，接下来介绍是它的一种实现方式 -- 方法表。类似于C++的虚函数表vtbl。

在有的JVM实现中，使用了方法表机制实现虚分派，而有时候，为了节省内存可能不采用方法表的实现。

不要被方法表这个名字迷惑，它并不是记录所有方法的表。它是为虚分派服务，不会记录用invokestatic调用的静态方法和用invokespecial调用的构造函数和私有方法。

JVM会在链接类的过程中，给类分配相应的方法表内存空间。每个类对应一个方法表。这些都是存在于method area区中的。这里与C++略有不同，C++中每个对象的第一个指针就是指向了相应的虚函数表。而Java中每个对象索引到对应的类，在对应的类数据中对应一个方法表。（关于链接的更多信息，参见博文[《Java类的装载、链接和初始化》](http://localhost:4000/blog/2013/09/08/java-class-loading-linking-and-initialising/)）

### 一种方法表的实现如下：

父类的方法比子类的方法先得到解析，即父类的方法相比子类的方法位于表的前列。

表中每项对应于一个方法，索引到实际方法的实现代码上。如果子类重写了父类中某个方法的代码，则该方法第一次出现的位置的索引更换到子类的实现代码上，而不会在方法表中出现新的项。

JVM运行时，当代码索引到一个方法时，是根据它在方法表中的偏移量来实现访问的。（第一次执行到调用指令时，会执行解析，将符号索引替换为对应的直接索引）。

由于invokevirtual调用的方法在对应的类的方法表中都有固定的位置，直接索引的值可以用偏移量来表示。（符号索引解析的最终目的是完成直接索引：对象方法和对象变量的调用都是用偏移量来表示直接索引的）

###invokeinterface与invokevirtual的比较

当使用invokeinterface来调用方法时，由于不同的类可以实现同一interface，我们无法确定在某个类中的inteface中的方法处在哪个位置。于是，也就无法解析 CONSTANT_intefaceMethodref-info为直接索引，而必须每次都执行一次在methodtable中的搜索了。
所以，在这种实现中，通过 invokeinterface访问方法比通过invokevirtua﻿﻿l访问明显慢很多。


###参考资料

* [《Inside the Java2 Virtual Machine》](http://book.douban.com/subject/1788390/)
