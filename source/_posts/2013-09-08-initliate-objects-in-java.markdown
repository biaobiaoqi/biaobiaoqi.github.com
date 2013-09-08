---
layout: post
title: "Java类的实例化总结"
date: 2013-09-08 02:03
comments: true
categories: [tech]
tags: [java, jvm, bytecode]
description: "Java类实例化的方法：显性实例化，隐性实例化"

---

java类的实例化(instantiation)具有显性的和隐性的区别。

写Java代码时，我们所使用new的方法实例化最简单直接的显性实例化。而隐性的实例化则出现在java程序的整个生命周期中，包括String、Class，StringBuffer 或者StringBuilder 的实例化等等。


##显性的实例化

###new关键字实例化对象

调用相应的构造函数完成实例化。（类中的非静态成员变量如果有初始化语句，都会被隐式的加入到构造函数中）代码如下：
```java

public class Test  {  
  
    String strA = "xyz";  
    String strB ;  
      
    public Test(String str){  
        strB = str ;  
    }  
    public static void main(String[] args){  
            Test t = new Test("abc");  
    }  
      
}  
```

在eclipse中装了[ASM bytecode](http://asm.ow2.org/)插件后，观察.class文件中的构造函数对应的字节码如下：
<!--more-->
```
INVOKESPECIAL Object.<init>() : void  
   ALOAD 0: this  
   LDC "xyz"  
   PUTFIELD Test.strA : String  
   ALOAD 0: this  
   ALOAD 1: str  
   PUTFIELD Test.strB : String  
   RETURN  
```

关键在于`LDC"xyz"`这条指令，明显可以看出，这是用于strA初始化的字符串。

由此我们可以归纳出，在没有调用本类中其他的构造函数的情况下，每次类的构造函数中都会按如下顺序进行：

* a)隐式（或显性）的调用父类的构造函数
* b)然后执行写在构造函数外的成员变量的初始化赋值
* c)最后再执行构造函数中的命令。

如果是有显性的调用本类其他构造函数（必须是放在构造函数第一步执行），那么对于这个构造函数，处理过程就简单些了：

* a)调用那个构造函数。
* b)执行之后的代码。


###利用java反射机制

反射机制是是java动态性中的关键之一，调用java.lang.reflect.Constructor的newInstance()方法能创建对象。

```java
public class Test  {  
  
    public Test(){  
        System.out.println("Created by invoking newInstance()");  
    }  
      
    public Test(String str){  
        System.out.println(str);  
    }  
      
    public static void main(String[] args)  
                    throws ClassNotFoundException , InstantiationException ,  
                    IllegalAccessException  {  
            Test t1 = new Test("Created with new"); //常规的方法  
            Class myClass = Class.forName("Test");  //获得了对应于Test类的Class对象，如果没有加载，会先加载这个类，再返回。  
            Test t2 = (Test)myClass.newInstance(); //调用newInstance()创建对象。  
    }  
      
}  
```

###其他

其他还有对象的clone()方法，以及串行化后的解串行化过程。

 
##隐性的实例化
隐性的实例化主要有如下几类：

* 1.String和String数组。main(String[] args)中拥有的args参数为String数组类型，这些command line参数将会首先被实例化。
* 2.Class的实例化。由于类的加载过程中，会生成相应类的Class对象，这些也会被隐性的实例化。
* 3.JVM在执行类加载的过程中，对常量池中的CONSTANT_String_info项会实例化出对应的String对象。这里涉及到常量池解析的知识。
* 4.在String的操作中，可能存在隐性的StringBuffer 或者StringBuilder的实例化。
* 5.int和Integer这些类型转化过程中的装箱、拆箱。

比如如下代码：
``` java
public class Test  {  
  
    public static void main(String[] args){  
            String str1 = "abc";  
            String str2 = "def";  
            String str = str1 + str2 ;  
    }  
}  
```

在eclipse中装了ASM bytecode插件后，直接观察.class文件对应的字节码：
```
NEW StringBuilder  
    DUP  
    ALOAD 1: str1  
    INVOKESTATIC String.valueOf(Object) : String  
    INVOKESPECIAL StringBuilder.<init>(String) : void  
    ALOAD 2: str2  
    INVOKEVIRTUAL StringBuilder.append(String) : StringBuilder  
    INVOKEVIRTUAL StringBuilder.toString() : String  
    ASTORE 3  
```

实际上，这里str1 和 str2合并的过程，是使用了StringBuilder来间接完成的，首先以str1的值构造一个StringBuilder，然后调用其中的append()方法，将str2串联上来。

值得注意的是：老版本的java使用StringBuffer完成这一步，但StringBuffer是线程安全的，效率略低，于是在新版本java中出现了非线程安全的StringBuilder，这类似于Hashtable 和 hashset的关系。