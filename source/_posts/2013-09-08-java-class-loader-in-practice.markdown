---
layout: post
title: "Java类加载器编程实践"
date: 2013-09-08 00:33
comments: true
categories: [tech]
tags: [java, jvm, bytecode]
description: "Java类加载器，自定义类加载器。ASM，操纵Java字节码， 面向切面编程，AOP"

---

文本通过实现自定义类加载器，实践Java类加载的流程。

阅读此文前，需要了解Java类加载的基本原理，参见如下两篇博文：

* [《Java类加载器浅析》](http://biaobiaoqi.me/blog/2013/09/07/java-classloader/)
* [《Java类加载器三原则》](http://biaobiaoqi.me/blog/2013/09/08/three-principles-of-classloader-operation/)


以上博文中所提及的Java类加载机制，都是Java1.2及以后的版本，而在最早的Java1.1中类加载器是没有父子关系的模式的。这里将分别对Java1.1和Java1.2及以后的类加载版本进行展示。

##Java1.1中的实现

###原理介绍

Java1.1的类加载机制相对单一，用户自定义加载器的重写比较复杂。

主要需要重写加载器中的Class loadClass(String name)方法。

Class loadClass(String name)或loadClass(String name , boolean resolve)方法是加载的核心。它根据类的全名（比如String类的全名是java.lang.String）获得对应类的二进制数据，然后通过Class defineClass(byte[] b) 将二进制数据加载到JVM的方法区，并返回对应类的Class实例，然后根据可选的参数resolve决定是否需要现在解析这个类。最后将这个Class实例作为loadClass方法的返回值。

如果无法加载和defineClass，即无法通过本加载器直接加载类的情况，则使用Class findSystemClass(String name) 将类加载任务委派给系统类加载器查找。如果能找到则加载，否则抛出ClassNotFoundException异常。

###编程实例

以下用实例来展示这一过程：

<!--more-->

类CompilingClassLoader是一个自定义加载器，它能直接读取Java源文件实现类加载。CLL类的main方法为程序入口，通过ComplilingClassLoader加载一个Foo类，使用反射机制调用Foo类的main方法。


CompilingClassLoader.java
 
```java

import java.io.*;  
  
/* 
 
A CompilingClassLoader compiles your Java source on-the-fly.  It 
checks for nonexistent .class files, or .class files that are older 
than their corresponding source code. 
 
*/  
  
public class CompilingClassLoader extends ClassLoader  
{  
  // Given a filename, read the entirety of that file from disk  
  // and return it as a byte array.  
  private byte[] getBytes( String filename ) throws IOException {  
    // Find out the length of the file  
    File file = new File( filename );  
    long len = file.length();  
  
    // Create an array that's just the right size for the file's  
    // contents  
    byte raw[] = new byte[(int)len];  
  
    // Open the file  
    FileInputStream fin = new FileInputStream( file );  
  
    // Read all of it into the array; if we don't get all,  
    // then it's an error.  
    int r = fin.read( raw );  
    if (r != len)  
      throw new IOException( "Can't read all, "+r+" != "+len );  
  
    // Don't forget to close the file!  
    fin.close();  
  
    // And finally return the file contents as an array  
    return raw;  
  }  
  
  // Spawn a process to compile the java source code file  
  // specified in the 'javaFile' parameter.  Return a true if  
  // the compilation worked, false otherwise.  
  private boolean compile( String javaFile ) throws IOException {  
    // Let the user know what's going on  
    System.out.println( "CCL: Compiling "+javaFile+"..." );  
  
    // Start up the compiler  
    Process p = Runtime.getRuntime().exec( "javac "+javaFile );  
  
    // Wait for it to finish running  
    try {  
      p.waitFor();  
    } catch( InterruptedException ie ) { System.out.println( ie ); }  
  
    // Check the return code, in case of a compilation error  
    int ret = p.exitValue();  
  
    // Tell whether the compilation worked  
    return ret==0;  
  }  
  
  // The heart of the ClassLoader -- automatically compile  
  // source as necessary when looking for class files  
  public Class loadClass( String name, boolean resolve )  
      throws ClassNotFoundException {  
  
    // Our goal is to get a Class object  
    Class clas = null;  
  
    // First, see if we've already dealt with this one  
    clas = findLoadedClass( name );  
  
    //System.out.println( "findLoadedClass: "+clas );  
  
    // Create a pathname from the class name  
    // E.g. java.lang.Object => java/lang/Object  
    String fileStub = name.replace( '.', '/' );  
  
    // Build objects pointing to the source code (.java) and object  
    // code (.class)  
    String javaFilename = fileStub+".java";  
    String classFilename = fileStub+".class";  
  
    File javaFile = new File( javaFilename );  
    File classFile = new File( classFilename );  
  
    //System.out.println( "j "+javaFile.lastModified()+" c "+  
    //  classFile.lastModified() );  
  
    // First, see if we want to try compiling.  We do if (a) there  
    // is source code, and either (b0) there is no object code,  
    // or (b1) there is object code, but it's older than the source  
    if (javaFile.exists() &&  
         (!classFile.exists() ||  
          javaFile.lastModified() > classFile.lastModified())) {  
  
      try {  
        // Try to compile it.  If this doesn't work, then  
        // we must declare failure.  (It's not good enough to use  
        // and already-existing, but out-of-date, classfile)  
        if (!compile( javaFilename ) || !classFile.exists()) {  
          throw new ClassNotFoundException( "Compile failed: "+javaFilename );  
        }  
      } catch( IOException ie ) {  
  
        // Another place where we might come to if we fail  
        // to compile  
        throw new ClassNotFoundException( ie.toString() );  
      }  
    }  
  
    // Let's try to load up the raw bytes, assuming they were  
    // properly compiled, or didn't need to be compiled  
    try {  
  
      // read the bytes  
      byte raw[] = getBytes( classFilename );  
  
      // try to turn them into a class  
      clas = defineClass( name, raw, 0, raw.length );  
    } catch( IOException ie ) {  
      // This is not a failure!  If we reach here, it might  
      // mean that we are dealing with a class in a library,  
      // such as java.lang.Object  
    }  
  
    //System.out.println( "defineClass: "+clas );  
  
    // Maybe the class is in a library -- try loading  
    // the normal way  
    if (clas==null) {  
      clas = findSystemClass( name );  
    }  
  
    //System.out.println( "findSystemClass: "+clas );  
  
    // Resolve the class, if any, but only if the "resolve"  
    // flag is set to true  
    if (resolve && clas != null)  
      resolveClass( clas );  
  
    // If we still don't have a class, it's an error  
    if (clas == null)  
      throw new ClassNotFoundException( name );  
  
    // Otherwise, return the class  
    return clas;  
  }  
}
```


CCLRun.java

```java  
/* 
 
CCLRun executes a Java program by loading it through a 
CompilingClassLoader. 
 
*/  
  
public class CCLRun  
{  
  static public void main( String args[] ) throws Exception {  
  
    // The first argument is the Java program (class) the user  
    // wants to run  
    String progClass = args[0];  
  
    // And the arguments to that program are just  
    // arguments 1..n, so separate those out into  
    // their own array  
    String progArgs[] = new String[args.length-1];  
    System.arraycopy( args, 1, progArgs, 0, progArgs.length );  
  
    // Create a CompilingClassLoader  
    CompilingClassLoader ccl = new CompilingClassLoader();  
  
    // Load the main class through our CCL  
    Class clas = ccl.loadClass( progClass );  
  
    // Use reflection to call its main() method, and to  
    // pass the arguments in.  
  
    // Get a class representing the type of the main method's argument  
    Class mainArgType[] = { (new String[0]).getClass() };  
  
    // Find the standard main method in the class  
    Method main = clas.getMethod( "main", mainArgType );  
  
    // Create a list containing the arguments -- in this case,  
    // an array of strings  
    Object argsArray[] = { progArgs };  
  
    // Call the method  
    main.invoke( null, argsArray );  
  }  
}

```

Foo.java
```java
public class Foo  
{  
  static public void main( String args[] ) throws Exception {  
    System.out.println( "foo! "+args[0]+" "+args[1] );  
  }  
}  
```

执行CLL类，命令行传入Foo的类名。执行结果如下：
```
CCL: Compiling Foo.java...  
foo! arg1 arg2  
```

具体参见资料：[IBM DeveloperWorks ： Understanding the Java ClassLoader](http://www.ibm.com/developerworks/java/tutorials/j-classloader/index.html)， 这是一篇2001年的文章，是早年Java1.1的实现方式。如今的Java已经变得更加人性化，多功能化，鲁棒性也更强了。


##Java1.2以后的实现

###原理介绍

Java1.2以后，类加载器实现了parent-child模型，能更好的控制安全性方面的问题。


由于loadClass()方法中包含了parent-child的责任链模式逻辑，自定义类加载的自定义部分用策略模式从loadClass()方法中剥离到了findClass()中。对应的有一个findLoadedClass()，这个方法用来实现查找当前加载器是否有加载该某类。

loadClass()：加载一个类时，先调findLoadedClass()，如果没有找到，则调用父亲加载器的加载方法。如果父亲找到了该类，就返回Class实例，没有找到，则父亲加载器会抛出一个异常，捕捉到这个异常后，儿子加载器会自己调用findClass()尝试实现对类的加载。如果依然没有成功加载，则再向外抛出一个异常。通过向父亲加载器迭代实现了parent-first的委托关系。

类加载的流程如图：这里显示了一个类未能成功加载所要经历的流程。（来自[stackoverflow:how-is-the-control-flow-to-findclass-of](http://stackoverflow.com/questions/3544614/how-is-the-control-flow-to-findclass-of)）

```
      A.loadClass()  
           |  
       (not-found?) (by findLoadedClass)  
           |  
      B.loadClass()  
           |  
       (not found?) (by findLoadedClass)  
           |  
systemclassloader.loadClass  (Bs parent, also can be   
           |                  called classpath classloader)  
           |  
       (not found?) (by findLoadedClass)  
           |  
bootstrap classloader.loadClass (the bootstrap classloader,   
           |                   (this has no parent)  
           |  
       (not found?)  
           |  
systemclassloader.findClass  (on system classloader,   
           |                   will try to "find" class in "classpath")  
           |  
       (not found?) ClassNotFoundException  
           |  
       B.findClass  
           |  
       (not found?) ClassNotFoundException  
           |  
       A.findClass  
           |  
        (not found?)  
           |  
   ClassNotFoundException  
```


注意，对于扩展类加载器，通过getParent()方法返回的父亲加载器是null，因为引导类加载器是本地实现的，并非Java实现。那么如何从扩展类加载器向上回溯呢？答案如下：

```java
try {  
    if (parent != null) {  
       c = parent.loadClass(name, false);  
    } else {  
       c = findBootstrapClassOrNull(name);  
    }  
} catch (ClassNotFoundException e) {  
   // ClassNotFoundException thrown if class not found  
     // from the non-null parent class loader  
} 
``` 
这是类加载器的源代码，对于父加载器为null的情况，会直接调用findBootstrapClassOrNull()方法尝试用引导类加载器加载。通过源代码，能够很好的理解这里的parent-child模型了。

另注意，对于基于parent-child模型的类加载器实现，都需要定义一个以parent类加载器作为参数的构造函数，以指定父加载器。如果直接调用没有参数的构造函数，则默认制定的是systemclassloader作为parent。

###编程实例

下面的例子是我用来实现动态分析Java类关系的加载器代码。

具体逻辑是：调用ASM开源库的API，在加载器加载类时，修改类文件中的字节码，插入相应的字节码语句，让对象在创建或执行相应指令时，在log文件中记录自己的行为。

在编码的过程中，我遇到的一个错误：将需要使用自定义加载器加载的类文件直接放在了eclipse工程中的bin目录下。而这个目录是可以通过系统类加载器找到路径并加载的。根据parent-first的实现，这些类直接被系统类加载器加载了，也就绕过了自定义加载器的处理机制。修改过路径以后没有出现相应问题了。

ASMClassLoader.java
```java
package biaobiaoqi.classLoader;  
import java.io.*;  
  
import org.objectweb.asm.ClassReader;  
import org.objectweb.asm.ClassWriter;  
  
import biaobiaoqi.asm.*;  
  
  
public class ASMClassLoader extends ClassLoader  
{  
    String basePath ;  
      
    /**reference to System Classloader as the parent class loader 
     * @param path <br> the path of .class files will be loaded 
     */  
    public ASMClassLoader(String path){  
        basePath = path ;  
    }  
   
    /** 
     * reference to parent as it's parent classloader 
     * @param path 
     * @param parent 
     */  
    public ASMClassLoader(String path , ClassLoader parent){  
        super(parent);  
        basePath = path ;  
    }  
  
    @Override  
    public Class findClass(String name) throws ClassNotFoundException{  
        System.out.println("findClass");  
        byte[] raw;  
        try {  
            raw = getBytesFromBasePath( name );  
        } catch (IOException e) {  
            e.printStackTrace();  
            throw new ClassNotFoundException();  
        }  
      
        byte[] transformed = instrumentBtyeCode(raw);  
        /* 
        try{ 
            FileOutputStream file = new FileOutputStream( "/home/biaobiaoqi/" +name.replace( '.', '/' )+".class"); 
            file.write( transformed); 
            file.close(); 
        } 
        catch (IOException e) { 
            e.printStackTrace(); 
        } 
        */  
        if (transformed == null){  
            throw new ClassNotFoundException();  
        }  
        
          
        return defineClass(name, transformed, 0, transformed.length );  
    }  
    
    private byte[] getBytesFromBasePath( String className ) throws IOException ,ClassNotFoundException{  
        String fileStub = className.replace( '.', '/' );  
        String classFileName = basePath +fileStub+".class";  
        File file = new File( classFileName );  
          
        long len = file.length();  
        byte raw[] = new byte[(int)len];  
        FileInputStream fin = new FileInputStream( file );  
          
        int r = fin.read( raw );  
        if (r != len)  
            throw new IOException( "Can't read all, "+r+" != "+len );  
          
        fin.close();  
        return raw;  
    }  
      
    private byte[] instrumentBtyeCode(byte[] raw){  
        ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_FRAMES);  
        ASMClassAdapter mca = new ASMClassAdapter(cw);   
        ClassReader cr = new ClassReader(raw);  
        cr.accept(mca, 0);  
        return cw.toByteArray();  
    }     
      
    @Override  
    public Class loadClass( String name, boolean resolve )  
        throws ClassNotFoundException {  
        System.out.println("loadClass_resolve");  
          return super.loadClass(name ,resolve);  
    }  
      
      
    @Override  
    public Class loadClass( String name )  
        throws ClassNotFoundException {  
        System.out.println("loadClass");  
          return super.loadClass(name );  
    }  
      
}
```
