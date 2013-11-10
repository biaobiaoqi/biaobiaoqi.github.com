---
layout: post
title: "在github上搭建octopress博客 Mac版"
date: 2013-03-21 23:43
comments: true
description: "在github上搭建octopress博客 Mac版"
categories: [tech]
tags: [Git, octopress,技术] 

---

{% img http://pikipity.github.com/images/post/octopress.jpg %}

大概是从[唐巧大哥的博客](http://blog.devtang.com/blog/2012/02/10/setup-blog-based-on-github/)以及[阮一峰的博文](http://www.ruanyifeng.com/blog/2012/08/blogging_with_jekyll.html)了解到了octopress这个静态的博客框架，托在Github上面，不用自己搭服务器，方便易用。自己之前也有在csdn上维护了一个博客，但经过密码泄露事件以及难于自定义配置等问题的考虑，自己在Github上维护一个静态博客是一个更好的选择。

自己搭建博客之初并没有学过Ruby，甚至于对Git的操作指令也不甚熟悉。颇费周章的从网上搜索了很久的教程，但终归每台电脑有不同的初始环境，不能盲目跟从。倒腾了一下午，最终发现还是官网的Guide最有效。这里总结下自己在Mac上的搭建经验。
<!--more-->

如果对octopress、ruby、git不太了解，先不着急动手，以下是一些基本概念：
>*    [Octopress](http://octopress.org/) ：本文所要搭建的博客框架，是一个静态站点生成工具，不需要使用动态的数据库和相关处理。
>*    [Markdown](http://zh.wikipedia.org/wiki/Markdown)：一种轻量级的标记语言，比HTML简单，用于Octopress博客发表时的内容排版。
>*    Git：最早用于管理Linux源码的分布式版本控制工具。
>*    [Github](https://github.com/)：程序员的Facebook,为程序员托管了很多代码的站点。
>*    [Github pages](https://help.github.com/categories/20/articles)：Github推出的，给与程序员自由创造静态网页的功能，支持Jekyll，而Octopress是对Jekyll的封装，于是也被支持。
>*    Ruby：Octopress框架的实现语言（顺道推荐[codecademy](http://www.codecademy.com/tracks/ruby)，可以体验到轻松的交互式的Ruby学习）。Mac OS X下自带了Ruby，不过版本可能与Octopress不匹配，需要使用RVM重新配置。
>*    [RVM](https://rvm.io/)（ruby version manager）：用于管理ruby版本的工具。类似的工具有rbenv，本文使用rvm管理ruby版本。
>*    rake：ruby中类似于make的构建工具，用于从源码生成最终的产品。
>*    [YAML](http://www.ibm.com/developerworks/cn/xml/x-cn-yamlintro/): YAML是一种比 XML更敏捷的半结构化数据格式。Octopress使用yaml做配置文件。
>*    [homebrew](http://mxcl.github.com/homebrew/ )：Mac OS下的软件包管理工具，类似于Linux下的dpkg。

 
 搭建过程如下：

#1. 配环境

###1.0 Homebrew
万事开头难，第一步还是配环境。为了软件包安装的方便，可以先安装好homebrew。

```
$ ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
```
	
其使用方法，参见[官网](http://mxcl.github.com/homebrew/)。

###1.1 Ruby
Mac OS X 10.8.1 的系统自带了Ruby，但是版本是1.8.3，Octopress官网所支持的最新版是1.9.3（2013.3），兼容起见，先对版本进行升级。	

```
$ rvm install 1.9.3 && rvm use 1.9.3 
$ rvm ruby gems latest
```

lz在升级过程中遇到了奇怪的错误，于是又参考[另一篇博文](http://www.iteye.com/blog/1118672)，重新安装了rvm，再升级ruby到1.9.3版本。
 
###1.2 Git 

使用Homebrew安装Git。

```
$ brew install git
```

#2. 搭建octopress

环境配置完成后，就可以开始参照[官网](http://octopress.org/help/)的指导搭建Octopress。这一过程依赖于对Github的账户操作。不再展开。


#3. 发博文和在线部署

同样的，参考[官网](http://octopress.org/help/)即可。
这里大致的列出我所常用到的几条命令：

```

#创建一篇博文
rake new_post["post title"] #octopress将在工作目录的source/_post/目录下生成相应的markdown文件。然后可以使用mou工具去修改编辑内容。

#生成预览
rake preview #可以通过localhost:4000在本机实时观察最新的编辑效果。

#在线发布
rake deploy #完成编辑后，可以将最新的内容部署到github上去。成功后，即可在线访问。

#向github提交源文件更新
git add -A
git commit -m "提交内容"
git push


```

另外，推荐Mac下的Markdown编辑器：[mou](http://mouapp.com/)，另附[markdown语法参考](http://wowubuntu.com/markdown/index.html)。

进一步的octopress博客定制，参见博客[《定制自己的octopress》](/blog/2013/07/10/decorate-octopress/)


**LOG：**

* 2013-11-11 修订