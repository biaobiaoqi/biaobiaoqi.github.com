---
layout: post
title: "记排查octopress生成时的编码错误"
date: 2014-03-06 21:48
comments: true
categories: [tech]
tags: [octopress, 编码, ruby, debug]
description: "octopress出现Sorry, I can not find /，debug发现是混入了错误的编码字符 U+200E"

---

前些日子经若亮童鞋提醒，我在[其他推荐](http://biaobiaoqi.me/resources/)的页面中增加了对Dropbox和Linode等工具的推荐，一来分享这些好用的产品，二来期望刚接触这些工具的好心的朋友可以不吝啬时间用我的推荐码注册，让我获得一些分享的回报。

改过页面内容后，照常的使用`rake preview`命令生成预览页面，打开浏览器，得到的却是一行孤零零的

> Sorry, I can not find /

`rake generate`后的结果更悲惨：

<!--more-->

```  
biaobiaoqi.github.com git:(source) ✗ rake generate
## Generating Site with Jekyll
unchanged sass/screen.scss
Configuration from /Users/shenyapeng/Development/biaobiaoqi.github.com/_config.yml
Building site: source -> public
/Users/shenyapeng/Development/biaobiaoqi.github.com/plugins/raw.rb:11:in `gsub': invalid byte sequence in UTF-8 (ArgumentError)
     from /Users/shenyapeng/Development/biaobiaoqi.github.com/plugins/raw.rb:11:in `unwrap'
     from /Users/shenyapeng/Development/biaobiaoqi.github.com/plugins/octopress_filters.rb:18:in `post_filter'
     from /Users/shenyapeng/Development/biaobiaoqi.github.com/plugins/octopress_filters.rb:33:in `post_render'
     from /Users/shenyapeng/Development/biaobiaoqi.github.com/plugins/post_filters.rb:124:in `block in post_render'
     from /Users/shenyapeng/Development/biaobiaoqi.github.com/plugins/post_filters.rb:123:in `each'
     from /Users/shenyapeng/Development/biaobiaoqi.github.com/plugins/post_filters.rb:123:in `post_render'
     from /Users/shenyapeng/Development/biaobiaoqi.github.com/plugins/post_filters.rb:151:in `transform'
     from /Users/shenyapeng/.rvm/gems/ruby-1.9.3-p545/gems/jekyll-0.12.1/lib/jekyll/convertible.rb:88:in `do_layout'
     from /Users/shenyapeng/Development/biaobiaoqi.github.com/plugins/post_filters.rb:167:in `do_layout'
     from /Users/shenyapeng/.rvm/gems/ruby-1.9.3-p545/gems/jekyll-0.12.1/lib/jekyll/page.rb:100:in `render'
     from /Users/shenyapeng/.rvm/gems/ruby-1.9.3-p545/gems/jekyll-0.12.1/lib/jekyll/site.rb:204:in `block in render'
     from /Users/shenyapeng/.rvm/gems/ruby-1.9.3-p545/gems/jekyll-0.12.1/lib/jekyll/site.rb:203:in `each'
     from /Users/shenyapeng/.rvm/gems/ruby-1.9.3-p545/gems/jekyll-0.12.1/lib/jekyll/site.rb:203:in `render'
     from /Users/shenyapeng/.rvm/gems/ruby-1.9.3-p545/gems/jekyll-0.12.1/lib/jekyll/site.rb:41:in `process'
     from /Users/shenyapeng/.rvm/gems/ruby-1.9.3-p545/gems/jekyll-0.12.1/bin/jekyll:264:in `<top (required)>'
     from /Users/shenyapeng/.rvm/gems/ruby-1.9.3-p545/bin/jekyll:23:in `load'
     from /Users/shenyapeng/.rvm/gems/ruby-1.9.3-p545/bin/jekyll:23:in `<main>'
     from /Users/shenyapeng/.rvm/gems/ruby-1.9.3-p545/bin/ruby_executable_hooks:15:in `eval'
     from /Users/shenyapeng/.rvm/gems/ruby-1.9.3-p545/bin/ruby_executable_hooks:15:in `<main>’
```
似乎是编码的问题：`invalid byte sequence in UTF-8`，但是我只是修改了普普通通的几行文字而已，怎么会有编码问题呢。

恰逢自己刚因为SSD损坏重装了系统，编程环境也是刚刚配好，而且使用rvm安装ruby1.9.3的时候，提示文字中也有一些warning。我开始怀疑是不是ruby1.9.3没编译好的原因。

设立对照实验，我在另外一台Ubuntu机器上clone下一个博客的repo，`rake generate`，结果竟然一切顺利。一切似乎都在说明就是开发环境的问题。

我删除了之前的ruby1.9.3，甚至是rvm，重装后结果依旧。

不能在一棵树上吊死，我不科学的将目标重新定位到markdown页面中的编码错误上（没想到后来事实证明奏效了……）。

在git中新开启测试分支，在上面做回滚，测试修改页面内容前源码能否generate

```
#>git branch checkError
#>git checkout checkError

#>git log #找到修改前的提交码
#>git reset --hard xxx #xxx为相应的提交码

```

然后`rake generate`竟然能成功= =#!，看来真的是修改的页面掺入了错误的编码。

接下来是回到原来的分支上，通过diff命令定位错误代码：

```
#>git checkout source 
#>git branch -d checkError  #删除测试分支

#>git diff  xxx #xxx为相应的提交码

```

比较结果如下图，果然是有一个奇怪的字符。
![img](http://biaobiaoqi.u.qiniudn.com/8BB0BA73-9736-435D-9111-5E3BF8516299.png?imageView/2/w/800/h/800)

查了下，这是[左至右符号](http://zh.wikipedia.org/wiki/%E5%B7%A6%E8%87%B3%E5%8F%B3%E7%AC%A6%E8%99%9F)。莫非是从chrome浏览器复制地址时，不小心复制了它？

进一步尝试发现，这个字符如果不与)相邻，是不会造成编码问题的。与)相邻时，一旦他们被markdown解析后，就出现了这个bug。


有意思的是，另一台Ubuntu服务器上这个有编码隐患的repo时能够正常`rake generate`的。如下图，左边是mac上用vim打开包含隐患字符的文件截图，右边是Ubuntu上的截图。
![img](http://biaobiaoqi.u.qiniudn.com/371c00e86e5de776d262fedbce334f7a.jpeg?imageView/2/w/800/h/800)

谁能告诉我理解这一现象的思路呢 ><...
