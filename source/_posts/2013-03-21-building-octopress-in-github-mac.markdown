---
layout: post
title: "在github上搭建octopress博客 mac"
date: 2013-03-21 23:43
comments: true
categories: [git, tech, octopress] 
---
{% img http://pikipity.github.com/images/post/octopress.jpg %}

最早的时候，是看见了[唐巧大哥的博客](http://blog.devtang.com/blog/2012/02/10/setup-blog-based-on-github/)，UI上已是觉得耳目一新。后来读到过[阮一峰的博文](http://www.ruanyifeng.com/blog/2012/08/blogging_with_jekyll.html)，当知道这是搭建在Github这个程序员的facebook上时，更是心头一震，什么时候自己也搭这么个博客呢。直接用github托管代码，完全不用自己租服务器，实在方便。自己之前也有在csdn上维护了一个博客，虽然那已经是一年前的事情了。
<!--more-->深刻的记得，当时想将自己的weibo账户贴到博客页面上，却发现它不支持一般用户潜入javascript代码:(。这更让我对octopress的感情与日俱增。

今天终于动手啦。自己从网上搜到了很多中文的博客描述如何安装配置octopress，有些博客讲得算是清晰，但终归每台电脑有不同的环境，每个人的叙述也或多或少的主观。最要命的是，我发现好几篇博文所讲述的命令都不太一样，走了不少弯路之后，倒腾了一下午，最终还是官网救了我。这也让我进一步认识到，信息的流通中的失真在所难免，最好的方法还是直接探寻最权威的内容。

如果对octopress不太了解，不用急着动手，首先看看几个概念。（当然，lz现在也并非精通这几点，初来乍到的，先做出来再说，以后不断学习...）

>*    Ruby：octopress框架的实现语言。rvm（ruby version manager）是用于管理ruby版本的，rake是ruby中类似于make工具。
>*    静态站点生成工具：简单地说，不用数据库，直接生成网页文件。Jekyll就是这样的工具，而octopress是构建于它的上层的框架。
>*    Git：我主观的认为完虐svn的分布式版本控制工具。git官网貌似被gfw墙了=.=
>*    [Github](https://github.com/)：程序员的Facebook,为程序员托管了很多代码的站点。
>*    [Github pages](https://help.github.com/categories/20/articles):github推出的，给与程序员自由创造静态网页的功能。支持Jekyll，因此也支持octopress。
>*    [homebrew](http://mxcl.github.com/homebrew/ )：mac os下的软件包管理工具，类似于linux下的dpkg。它使用ruby脚本，mac os下自带了ruby。
>*    [octopress](http://octopress.org/) 其官网的help中有搭建octopress的足够的权威指导

 
窃以为，最好的学习方式还是从最源头的资料入手。这里仅针对我的配置过程做简单描述，经验浅薄，有差错的地方还请指教:)

#1. 配环境

###1.0 homebrew
万事开头难，第一步还是配环境。为了软件包安装的方便，可以先安装好homebrew.

```
$ ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
```
	
其使用方法，参见[官网](http://mxcl.github.com/homebrew/)。

###1.1 ruby
mac os x 10.8.1 的系统自带了Ruby，但是版本是1.8.3，而octopress官网所支持的最新版是1.9.3（2013.3），兼容起见，先对版本进行升级。	

```
$ rvm install 1.9.3 && rvm use 1.9.3 
$ rvm ruby gems latest
```


lz在升级过程中遇到了奇怪的错误，于是又参考[另一篇博文](http://wj1s.iteye.com/blog/1118672)，重新安装了rvm，再升级ruby到1.9.3版本。

 
###1.2 git 
使用homebrew安装git。

```
$ brew install git
```

#2. 搭建octopress
环境配置完成后，就可以开始参照[官网](http://octopress.org/help/)的指导搭建octopress，并在github建代码仓库，同步管理啦。

#3. 配置
具体配置同见[官网](http://octopress.org/help/)。

经过试错，发现_config.yml的配置中，配置项和值之间必须有空格。否则会报错。

另附个性化配置方案：（其实这些内容都能在官网文档中找到）

###3.1 [装饰边栏（加weibo、豆瓣信息)](http://icodeit.org/2012/10/how-to-embed-douban-show-in-your-octopress-site/)

###3.2 增加weibo评论：  [友言版](http://blog.devtang.com/blog/2012/02/10/setup-blog-based-on-github/)     [多说版](http://yangdd.github.com/blog/2012/08/23/comment/)

###3.3 CNAME
如果你有自己的域名，可以CNAME到github pages上。以我的配置为例。

1.在工作目录的source目录下创建CNAME文件，并输入新域名：biaobiaoqi.com

2.在域名管理中，创建或修改A记录，指向204.232.175.78这个地址。

3.创建CNAME记录，www.biaobiaoqi.com -> biaobiaoqi.github.com

网上很多CNAME的操作指南，对于A记录的IP都写着~~207.97.227.245~~，或者其他的IP。实际上，这是github pages更换了地址所致。再一次证明**官方文档才是最可靠的！**

#4. 发博文和在线部署
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

其中推荐到的[mou](http://mouapp.com/)，是一个mac下的markdown编辑器。试用后发现有些格式兼容问题，但似乎mac下也只有他这个可视化工具了=。=

另附[markdown语法](http://wowubuntu.com/markdown/index.html)



