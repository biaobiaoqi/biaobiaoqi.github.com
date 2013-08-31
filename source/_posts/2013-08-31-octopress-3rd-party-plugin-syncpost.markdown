---
layout: post
title: "octopress第三方插件：博文同步工具syncPost"
date: 2013-08-31 19:30
comments: true
categories: [tech]
tags: [octopress, ruby, webservice, metaweblog]
description: "octopress第三方插件，基于metaWeblog的博文同步工具syncPost, 开源托管在github上。正在进一步开发中。"

---

为了增加外链等考虑，独立博客往往有将博文同步到其他博客社区的需求。自己人肉黏贴的方式笨拙、重复，对于程序猿而言，着实不可取。

我在github上找到了[syncPost](https://github.com/huangbowen521/octopress-syncPost)这个针对octopress的第三方工具，能够通过一些论坛提供的[metaWeblog](http://en.wikipedia.org/wiki/MetaWeblog)服务实现octopress最新一篇博文的同步提交。

这大概就是我要找的东西吧。不过，其中有些细节并不是我想要的：

* 1.在本地配置文件存储论坛账户的密码。虽然可以设置为ignore不提交到git代码库中，但这也并不安全。
* 2.只能同步最新的一篇博客，没有整体的博文搬家功能。
* 3.先比其他的octopress插件，原来版本的代码结构难于维护，比如有自己单独的配置文件，而不是使用全局的`_config.yml`(在那个版本中大概是为了不把明文密码提交到版本库中)，比如ruby文件单独在一个`_custom`文件夹下等

基于这些点，我fork了作者的代码，定制成了它[现在的样子](https://github.com/biaobiaoqi/octopress-syncPost)。

<!--more-->

##功能

通过rake的方式实现同步功能：

* 1.同步所有octopress的博文到目标博客。 (`rake sync_all_posts`)
* 2.同步最新一篇博文到目标博客。(`rake sync_lates_post`)

##开发

这个octopress插件的结构很简单：

* 安装`nokogiri`和 `metaweblog`两个gem。前者实现对octopress生成的html页面的解析，找到对应的博文。提供了客户端发起MetaWeblog请求的功能。
* 在全局配置文件`_config.yml`中配置了目标博客MetaWeblog的服务地址、用户的账号信息。
* octopress/plugins/sync_*.rb三个文件则是代码实现。其中sync_post.rb中包含了post类，是主要的逻辑代码所在，sync_all_posts.rb和sync_latest_post.rb则是对前者的调用。
* 修改了octopress的Rakefile，通过rake的方式实现功能。

##下一步

希望能进一步完善这个插件，现在考虑到的有：

* 增加同步所有博文功能中，对目标博客中已有博文的查重功能。即对于已经同步过去的博客，不再发送请求，或者实现编辑功能的同步功能。由于站点的MetaWeblog服务大多对请求有时限控制，同步过程中可能出现中断，此时部分博文已经同步过去，而部分没有，这种情况下，暂时没有好的解决方式。
* 测试其他有MetaWeblog服务的博客站点（现在仅测试了cnblog）。
* cnblog的博文显示中，似乎不支持octopress的代码块样式。

欢迎感兴趣的朋友参与到这个repo中来:)

