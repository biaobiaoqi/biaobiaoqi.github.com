---
layout: post
title: "定制Octopress"
date: 2013-07-10 01:53
comments: true
categories: [tech]
tags: [octopress, web, ui]
description: "按照个人的习惯定制Octopress博客，有如下内容：增加微博墙，增加第三方评论，让博客支持在新窗口打开链接，404Error界面，在侧边栏增加标签云，在顶栏增加标签云页面tab，博客末尾增加原文链接、版权信息，给中英文之间增加空格"

---

在github pages上搭建好octopress博客之后，博客的基本功能就能使用了。如果想自己定制也是没问题的，octopress有较详尽的官方文档，原则上有问题求助官方即可：[octopress-help](http://octopress.org/help/)。官方没有包纳的也可以去询问[stackoverflow](http://stackoverflow.com/questions/tagged/octopress)。 当然，中文的看起来总会省事儿点。我做了如下一些总结;)

不会ruby的童鞋特别注意：配置_config.yml的过程中特别注意，配置项『:』后要留空格，否则会报错。


##1.装饰边栏

以增加豆瓣展示框为例。参加正反反长大哥的博客[How to Embed Douban-Show in Your Octopress Site](http://icodeit.org/2012/10/how-to-embed-douban-show-in-your-octopress-site/)


##2.增加评论和分享功能

虽然octopress内置的disqus评论系统很不错，但在国内的使用并不普及。相比之下，友言、多说等第三方评论则更接地气，可以利用到微博、人人等SNS账号。

###2.1友言

本博客采用了友言。首先注册[友言](http://www.uyan.cc/)的账号，如果不注册，虽然也能实现评论功能，但没有后台管理整个站点的评论会十分纠结。注册完成之后，选择获取代码，将这串代码贴入相应的位置，即可实现第三方评论。

在路径`$OCTOPRESS/source/_includes/post/`上创建文件`youyanandjiathis.html`，功能代码放入其中。

###2.2加网
分享方面，本博客使用了[加网](http://www.jiathis.com/getcode/icon)。注册后，在更多高级自定义功能中，可能自定义不同的分享按钮，生成代码后，也将生成的代码贴入`$OCTOPRESS/source/_includes/post/youyanandjiathis.html`中。

现在，youyanandjiathis.html的样子如下(需要注意，自己使用时，uid显然是不一样的啦)

``` html

<!-- JiaThis Button BEGIN -->
<div class="jiathis_style_32x32">
	<a class="jiathis_button_qzone"></a>
	<a class="jiathis_button_tsina"></a>
	<a class="jiathis_button_tqq"></a>
	<a class="jiathis_button_weixin"></a>
	<a class="jiathis_button_renren"></a>
	<a href="http://www.jiathis.com/share?uid=1814751" class="jiathis jiathis_txt jtico jtico_jiathis" target="_blank"></a>
	<a class="jiathis_counter_style"></a>
</div>
<script type="text/javascript">
var jiathis_config = {data_track_clickback:'true'};
</script>
<script type="text/javascript" src="http://v3.jiathis.com/code/jia.js?uid=xxxxxx" charset="utf-8"></script>
<!-- JiaThis Button END -->

<!-- UY BEGIN -->
<div id="uyan_frame"></div>
<script type="text/javascript" src="http://v2.uyan.cc/code/uyan.js?uid=xxxxxxxx"></script>
<!-- UY END -->

```

###2.3将功能增加到博客中

功能代码已经都在youyanandjiathis.html中了，接下来是让blog使用到这些功能代码。

首先在_config.yml中增加开关：
``` ruby
#comment and share                                                                                    
comment_and_share: true
```

然后在`$OCTOPRESS/source/_includes/post/sharing.html`中的，根据开关`comment_and_share` 引入对应的功能代码`post/youyanandjiathis.html`，类比于默认实现中的`<facebook_like>`部分。代码如下（使用时，先去掉反斜杠）：


``` html    

  \{\% if site.comment_and_share \%\}
      \{\% include post/]youyanandjiathis.html \%\}
  \{\% endif \%\}

```


###2.4友言验证
另外，需要在友言的后台处理评论，甚至做一些定制化处理，需要通过友言的验证。详情在友言的管理员后台可见。



##3.定制域名

如果你拥有自己的域名，可以CNAME到github pages上。以我的配置为例（我的域名为`biaobiaoqi.me`）。

1.在octopress的source目录下创建CNAME文件，并输入新域名：biaobiaoqi.com

2.在域名管理中，创建或修改A记录，指向207.97.227.245这个地址。

3.创建CNAME记录，www.biaobiaoqi.com -> biaobiaoqi.github.com

这一过程可能需要好几天才能生效，请耐心等待:)


##4.让博客中连接在新窗口打开

由于markdown不支持这一语法，如果要自己用html标签实现，又有些违背了markdown以内容为重的立意。

参考博文[《在Octopress中为markdown的超链接加上target="_blank"》](http://www.blogjava.net/lishunli/archive/2013/01/20/394478.html)，可以通过将如下代码添加到 {OCTOPRESS_HOME}/source/_includes/custom/head.html文件末尾来实现：

``` javascript
<script type="text/javascript">

function addBlankTargetForLinks () {

  $('a[href^="http"]').each(function(){

      $(this).attr('target', '_blank');

  });

}

$(document).bind('DOMNodeInserted', function(event) {

  addBlankTargetForLinks();

});

</script>

```

##5.列表的排版

默认情况，所有文字的排头会对齐，但如果有列表项的情况下也如此，列表头就会冲出文章的主体区块了。

在octopress/sass/custom/_layout.scss文件中找到#$indented-lists: true行，去掉#注释即可。

``` 
$indented-lists: true

```

<!--more-->

##6.404ERROR页面


在ocotopress/source目录下，增加404.markdown，并做出自定义的呃编辑。本博客使用了腾讯公益404，推荐大家使用，为社会贡献一分正能量。[公益404](http://www.qq.com/404/)

``` 
---

layout: page

title: "404 Error"

date: 2013-4-21 02:35

comments: false

sharing: false

footer: false

---

<script type="text/javascript" src="http://www.qq.com/404/search_children.js" charset="utf-8"></script>

```


##7.在侧边栏增加标签云(tag cloud)

octopress默认只有分类，没有标签。这对于博文的组织和管理很不友好。有人开源出了自己定制的tag生成和tag cloud展现的代码，可以引入到自己的博客中来。

详细操作参见博文：[《为octopress添加tag Cloud》](http://codemacro.com/2012/07/18/add-tag-to-octopress/)。不过博文中没有讲解标签云的UI配置参数的使用，为了让UI适应页面，请参考原作者的官方说明:[octopress-tag-cloud](https://github.com/robbyedwards/octopress-tag-cloud)。我所实践出的较合理的参数值如下
``` ruby
#注意，下面一行的escape反斜杠在正常使用时需要去掉
\{\% tag_cloud font-size: 70-180%, limit: 15, order: rand, style: para  { &nbsp }\%\}
```

如果想将文章分类（category）也放在侧边栏，可以参考这篇博文：[《Octopress - Category List Plug-in》](http://paz.am/blog/blog/2012/06/25/octopress-category-list-plugin/)


##8.在顶栏增加标签云页面tab

1.生成新网页
``` ruby
rake new_page["tag-cloud"] #在octopress/source/中将生成tag-cloud/文件夹
```

2.在顶栏增加新页面

修改`source/_includes/custom/navigation.html`

```
<ul class="main-navigation">
  <li><a href="{{ root_url }}/">首页</a></li>
  <li><a href="{{ root_url }}/blog/categories/tech/">技术</a></li>
  <li><a href="{{ root_url }}/blog/categories/life/">生活</a></li>
  <li><a href="{{ root_url }}/blog/categories/book/">读书</a></li>
  <li><a href="{{ root_url }}/tag-cloud/">标签云</a></li>
  <li><a href="{{ root_url }}/about">关于</a></li>
</ul>
```
在需要的位置增加`<li><a href="{{ root_url }}/tag-cloud/">标签云</a></li>`。如此一来，可以在网页顶栏看到『标签云』一栏了。不过此时，点击进入，页面为空。

3.修改标签云页面内容。

修改`octopress/source/tag-cloud/index.markdown`，增加标签云执行脚本。

```

---
layout: page
title: "标签云"
date: 2013-07-10 02:53
comments: true
sharing: true
footer: true
---

#注意，代码中的escape反斜杠在正常使用时需要去掉
#另外，这几个语句不能使用换行。在我的测试环境下，使用换行后，最终的页面上对换行进行了错误的解码，给增加了一个<code>标签，造成了错误的显示。

<ul class="tag-cloud">\{\% tag_cloud font-size: 90-210%, limit: 1000, style: para \%\}</ul>
```

##9.博客末尾增加原文链接、版权等

最近发现有其他小网站未经授权直接copy我的博客内容，在违章的末尾加上版权、原文链接变得很有必要了。

详情参见博客[《为octopress每篇文章添加一个文章信息》](http://codemacro.com/2012/07/26/post-footer-plugin-for-octopress/)。

值得注意的是，插件代码中如下几行需要去掉缩进和换行符。原因跟第8节所讲一样，换行符引起了错误的解码，造成了错误的显示。

``` ruby
post.content + %Q[<p class='post-footer'>
            #{pre or "original link:"}
            <a href='#{post.full_url}'>#{post.full_url}</a><br/>
            &nbsp;written by <a href='#{url}'>#{author}</a>
            &nbsp;posted at <a href='#{url}'>#{url}</a>
            </p>]
```
最后，kevin没有提及的是，为了做好美化，还需要增加一段针这块区域的css：

编辑`sass/custom/_style.scss`，在末尾增加如下内容： 

``` css
.post-footer{margin-top:10px;padding:5px;background:none repeat scroll 0pt 0pt #eee;font-size:90%;color:gray}
```
这样，原文链接和版权信息就能很好的和正文内容分离开了。


##10.给中英文之间加空格

参见博文[《给中英文间加个空格》](http://xoyo.name/2012/04/auto-spacing-for-octopress/)。

特别注意ruby文件的编码：复制博文中的代码时，需要去掉前几行的描述性注释，让`#encoding:UTF-8`语句暴露在.rb文件的第一句。否则，`rake generate`时，会报错无法识别`\p{Han}`。


##Tips

既然是个博客站点，就算是web产品啦，可以考虑下SEO。推荐博文[《Octopress中的SEO》](http://codemacro.com/2012/09/06/octopress-seo/)