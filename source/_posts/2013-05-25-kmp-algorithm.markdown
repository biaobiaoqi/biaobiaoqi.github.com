---
layout: post
title: "KMP算法实现"
date: 2013-05-25 21:22
comments: true
description: "本文描述了单模式的字符串匹配的经典算法KMP算法的实现。首先对字符串匹配算法做简单的介绍，然后是KMP算法的实现描述，最后推荐三道简单的ACM模板题做kmp练手用，也可以加深对kmp细节过程的理解。"
categories: [tech] 
tags: [算法, Java,  技术]

---
本文描述了单模式的字符串匹配的经典算法KMP算法的实现。首先对字符串匹配算法做简单的介绍，然后是KMP算法的实现描述，最后推荐两道简单的ACM模板题做练手用。

字符串匹配算法
---

字符串匹配(String Matchiing)也称字符串搜索(String Searching)是字符串算法中重要的一种，是指从一个大字符串或文本中找到模式串出现的位置。一个基本的字符串匹配算法分类如下：

* 单模式匹配：即每次算法执行只需匹配出一个模式串。
* 有限集合的多模式匹配：即算法需要同时找出多个模式串的匹配结果，而这个模式串集合是有限的。
* 无限集合的多模式匹配：如正则表达式的匹配。

单模式匹配最容易理解，构造也非常简单。一个最朴素的思路就是从文本的第一个字符顺次比较模式串，不匹配则重新从下一个字符开始匹配，直到文本末尾。Java实现代码如下：

``` java

	public static boolean bruteforce(String str1, String str2) {
         for (int i = 0, j = 0; i!= str1.length(); ) {
               if (str1.charAt(i) == str2.charAt(j)) {
                    j ++;
                    i ++;
                    if (j == str2.length()) return true;
               }else {         
                    i = i - j + 1;
                    j = 0;                        
               }
          }
          return false;
     }

```

但是这种算法，有明显的效率黑洞。因为每次匹配失败后，都会回到原来的匹配起点的下一个字符开始匹配，这些步骤很多情况下，并不是必要的。

实际上这些字符很有可能已经被读入了一次。理论上，如果我们能对所有被读入过的字符有足够的了解，那就能判定是否能避免再次读入一遍做匹配运算了。经典的KMP算法正是基于这点思考，对原有的蛮力算法做出了优化。


KMP算法
---

网络上关于KMP算法的描述很多，其中个人觉得阮一峰老师的[《字符串匹配的KMP算法》](http://www.ruanyifeng.com/blog/2013/05/Knuth%E2%80%93Morris%E2%80%93Pratt_algorithm.html)对KMP的描述最为简明和清晰。图例展示的算法流程更容易让人接受和理解。这里仅记录我所认为重点的知识点。

#####算法的思想
相比蛮力算法，KMP算法预先计算出了一个哈希表，用来指导在匹配过程中匹配失败后尝试下次匹配的起始位置，以此避免重复的读入和匹配过程。这个哈希表被叫做“部分匹配值表(**Particial match table**)”，它的设计是算法精妙之处。

#####部分匹配值表
要理解部分匹配值表，就得先了解字符串的前缀(prefix)和后缀(postfix)。

* 前缀:除字符串最后一个字符以外的所有头部串的组合。
* 后缀：除字符串第一个字符以外的所有尾部串的组合。
* 部分匹配值：一个字符串的前缀和后缀中最长共有元素的长度。

举例说明：字符串`ABCAB`

* 前缀：{A， AB， ABC， ABCA}
* 后缀：{BCAB， CAB， AB， B}
* 部分匹配值：2 （AB）

而所谓的部分匹配值表，则为模式串的所有前缀以及其本身的部分匹配值。

举例如下：还是针对字符串`ABCAB`，它的部分匹配值表为：

```
A B C A B
0 0 0 1 2
```

这代表着：字符串`A B C A B` 中，子串`A B C`的部分匹配值为0，而子串`A B C A`的部分匹配值为1，诸如此理。

#####算法实现


``` java

	public static boolean kmp(String str, String dest) {
		int[] next =  generateNext(dest);
		
		//i是str的索引，j是dest的索引。
		for (int i = 0, j = 0; i < str.length(); i++) {
			//匹配发生错误时，在next数组中向前迭代找到匹配的结果。这是整个算法的核心位置！
			while (j > 0 && str.charAt(i) != dest.charAt(j))
				j = next[j - 1];

			//如果相等，dest中的索引往后移动一位
			if (str.charAt(i) == dest.charAt(j))
				j++;
			
			//dest数组所有位置均连续的匹配完成
			if (j == dest.length())
				return true;
		}

		return false;
	}
	
	//生成next数组
	private void generateNext(String str) {
		int[] next = new int[dest.length()];
        next[0] = 0;  //第一个元素的next值为0。
        
        //i索引的是需要计算的next值；j记录了上一个元素的next值。
        for (int i = 1, j = 0; i < str.length(); i ++) {
        	//当i和j指向的字符不匹配时，在next中往前迭代，直到两字符相等或者j为0.
            while(j > 0 && str.charAt(i) != str.charAt(j)) 
                j = next[j - 1];
            
            //如果j和i指向的字符相等，则j增加1.
            if (str.charAt(i) == str.charAt(j))
                j ++;
                
            next[i] = j;
        }
    }

```

理解算法实现时，有几点特别需要注意：

* 在生成部分匹配值数组的generateNext()方法中，第一层循环内，`i`是字符串的索引，而`j`则在每次循环开始时代表了`i`所指定字符之前的子串的部分匹配值。以部分匹配值为下标的字符，其实也就是相同公共的缀串的下一位字符了。
* generateNext()方法的内层while()循环，是为了迭代得到让`i`指定字符匹配到的情况。
* generateNext()方法的while()循环中，需要特别注意是`next[j -1]`，这里表达的是：当j指向的字符匹配失败，则继续找到j前一个字符的部分匹配值。
* kmp()的循环代码和generateNext()部分匹配值表生成的循环代码很类似。两者使用了相同方式，在字符匹配失败后迭代获取新的可匹配情况，且都是利用了next数组。



其他
---

KMP算法虽然能达到O(M+N)的算法复杂度，但在实际使用中，KMP算法的性能并不如[BM](http://www.ruanyifeng.com/blog/2013/05/boyer-moore_string_search_algorithm.html)算法强。


模板题
---

####基础模板题
* [HDOJ的2203题](http://acm.hdu.edu.cn/showproblem.php?pid=2203)是一个能检验算法正确性的模板题。Java实现的答案代码[请戳这里](https://github.com/biaobiaoqi/CPractice/tree/master/HDOJ/HDOJ2203.java)。

* [LeetCode: Implement strStr()](http://oj.leetcode.com/problems/implement-strstr/) 是一道裸字符串匹配题，直接使用KMP。Java实现的代码[请戳这里](https://github.com/biaobiaoqi/biaobiaoqiCode/blob/master/src/biaobiaoqi/algorithm/oj/leetcode/Implement%20strStr())。

####延伸模板题

* [POJ的2406题](http://poj.org/problem?id=2406)，对考察点做了巧妙的变形，对更深入的理解KMP中的部分匹配表（即next数组）很有帮助。Java实现的答案代码[请戳这里](https://github.com/biaobiaoqi/CPractice/tree/master/POJ/POJ2406.java)。

* [HDOJ的1867题](http://acm.hdu.edu.cn/showproblem.php?pid=1867)也属于kmp的变形。要求对kmp利用next数组进行比较的过程有清晰的认识。Java实现的答案代码[请戳这里](https://github.com/biaobiaoqi/CPractice/tree/master/HDOJ/HDOJ1867.java)。



###其他参考资料：

* [wiki:Knuth–Morris–Pratt Algorithm](http://en.wikipedia.org/wiki/Knuth%E2%80%93Morris%E2%80%93Pratt_algorithm)

* [wiki:String Searching Algorithm](http://en.wikipedia.org/wiki/String_searching_algorithm)

* [《KMP算法的实现》](http://www.cppblog.com/converse/archive/2006/07/05/9447.html)

* [《Linux 内核中的 KMP 实现》](http://wangcong.org/blog/archives/2090)

----------
###LOG

* 2014-4-9：对代码增加了更多注释，便于理解。
