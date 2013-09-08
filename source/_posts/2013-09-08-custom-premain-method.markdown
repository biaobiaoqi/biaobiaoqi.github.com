---
layout: post
title: "custom premain method"
date: 2013-09-08 13:01
comments: true
categories: [tech]
tags: [java, aop, asm]
description: ""

---

背景

想调用ASM API （用于字节码处理的开源API）对字节码进行处理，目标是实现对java程序运行时各种对象的动态跟踪，并进一步分析各个对象之间的关系（研究前提是目前的UML锁阐释的whole-part relation 是比较混乱的）。由于ASM相关内容又可以延伸很远，在此文中略过。

在完成了能对字节码进行处理的ASM调用以后，需要考虑如何将这些功能与正常的java程序整合到一起。

首先，我考虑到了自定义ClassLoader的方法（具体内容见另一篇博客《ClassLoader编程实践》），即在程序的main入口处，首先加载自定义的classloader，然后通过reflect技术使用这个classloader加载并调用测试程序（就是被跟踪的程序，姑且称之为测试程序）的入口类。

这个方法一个很大的限制：每次都必须先找到测试程序的入口类，而对于有的封装成jar的程序集合，这一点相对比较难控制。

于是，有了这里介绍的方法：通过 java.lang.instrument 实现的java agent对象操作字节码，也就试所谓的AOP（面向方面编程）
中文介绍参加IBM developworks上的文档：《Java SE 6 新特性: Instrumentation 新功能》。内有详细解释。其中提到的BCEL即Byte Code Engineering Library，是apache的开源项目，挺复杂，而ASM库有相对详尽的说明文档。这也是我选择了ASM实现的原因。
博主的程序里，其实很多上文提到的java6新特性都没有使用到：虚拟机启动后的动态instrument ，本地方法的instrument 都没有使用到。这里仅就源代码中的程序简单介绍instrument的基本功能和用法。
程序中，除了ASMAgent 以外的所有类都是调用ASM API 实现对 测试程序中 各个对象的construct 、 方法调用 ， field赋值等操作行为的记录（其中对Collection子类的处理着实费了一番心血= =，字节码操作很细节，容易出错。以后再写ASM方面的博文叙述）。
在此，我们将ASM API调用部分抽象成一个整体的接口好了，就是如下几句代码（在ASMAgent.java中）：
[java] view plaincopy
ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_FRAMES);  
ASMClassAdapter mca = new ASMClassAdapter(cw);   
ClassReader cr = new ClassReader(classfileBuffer);  
cr.accept(mca, 0);  
retVal = cw.toByteArray();  
其中classfileBuffer是类文件加载时的原始的字节码，retVal则是经过处理后的字节码。

============================正文分割===========================
原理
JVMTI（Java Virtual Machine Tool Interface）是一套本地编程接口集合，它提供了一套”代理”程序机制，可以支持第三方工具程序以代理的方式连接和访问 JVM，并利用 JVMTI 提供的丰富的编程接口，完成很多跟 JVM 相关的功能。关于 JVMTI 的详细信息，请参考 Java SE 6 文档（请参见 参考资源）当中的介绍。
java.lang.instrument 包的实现，也就是基于这种机制的：在 Instrumentation 的实现当中，存在一个 JVMTI 的代理程序，通过调用 JVMTI 当中 Java 类相关的函数来完成 Java 类的动态操作。
Instrumentation 的最大作用，就是类定义动态改变和操作。在 Java SE 5 及其后续版本当中，开发者可以在一个普通 Java 程序（带有 main 函数的 Java 类）运行时，通过 – javaagent参数指定一个特定的 jar 文件（包含 Instrumentation 代理）来启动 Instrumentation 的代理程序。
步骤
1.编写java代理类。
这个类中，premain方法是关键，对比于一般的入口main一样，这里的premain是在main之前执行的。它会告诉JVM如何处理加载上来的java字节码。如下例：
[java] view plaincopy
public static void premain(String agentArgs, Instrumentation inst) {  
                    Trace.BeginTrace(); // it's important for trace files  
            inst.addTransformer(new ASMAgent());  
        }  
值得注意的是，addTransformer实现了对字节码处理的方法的回调。
[java] view plaincopy
inst.addTransformer(new ASMAgent());  
类ASMAgent包含着实现对java字节码处理的方法：transform()。它来自于ClassFileTransformer接口。为了方便，博主这里将对ClassFileTransformer接口的实现跟ASMAgent类放在了一起。
[java] view plaincopy
public byte[] transform(ClassLoader loader, String className,Class<?> classBeingRedefined,   
                                        ProtectionDomain protectionDomain,byte[] classfileBuffer)  
            throws IllegalClassFormatException {  
            byte[] retVal = null;  
      
            if(isInstrumentable(className)){  
                  
                    ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_FRAMES);  
                ASMClassAdapter mca = new ASMClassAdapter(cw);   
                ClassReader cr = new ClassReader(classfileBuffer);  
                cr.accept(mca, 0);  
                retVal = cw.toByteArray();  
            }else{  
                    retVal = classfileBuffer ;  
                }  
  
            return retVal;  
    }  

2.打包代理类。
只有合理打包并在manifest文件中记录下相应的键值对之后，才能正常执行premain的内容。
manifest文件中需要添加的键值对是：
[plain] view plaincopy
Premain-Class : biaobiaoqi.asm.ASMAgent  
jar打包和manifest的修改方法见另一篇博文《JAR文件操作基础（Using JAR Files: The Basics）》
另外，如果对字节码的处理有应用到了其他的类，需要在manifest中增加路径。键值对为：
[plain] view plaincopy
Class-Path: asm-3.0.jar  

3.执行
执行测试程序时，添加“-javaagent:代理类的jar[=传入premain的参数]”选项。
比如，对于博主的程序，就是
java -javaagent:ASMInstrument.jar   -jar XXXX.jar  xxxx
其中ASMInstrument.jar 是第二步中打包的程序，  XXX.jar是需要测试的程序， xxx是XXX.jar 执行时可能的命令行参数。
如果只是执行某.class文件中的类，我们假设是在当前目录下的一个XXXX类，则是：
java -javaagent:ASMInstrument.jar   -cp ./  XXXX xxx
其中xxx是可能的命令行参数。

源码下载
编码期间遇到很多问题，比如在instrument方法中的classlodaer的一些判定操作。希望跟大家多交流～求勿喷。