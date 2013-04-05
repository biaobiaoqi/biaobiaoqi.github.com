---
layout: post
title: "分治、时间空间的权衡:最大合的连续字串问题 (PAT 1007)"
date: 2013-04-05 20:16
comments: true
categories: [algorithm, tech, pat, think]
---

[PAT1007](http://pat.zju.edu.cn/contests/pat-a-practise/1007)：给定一个整数串，找出连续子串中合最大的子串。

《编程珠玑》中用专门的一章对这个问题进行了讲解。（《编程珠玑（第2版）》P73 第8章 算法设计技术）

第一次在PAT上遇到这个题目时，我的思路如下：

~~最简单的淡然是一个三层循环咯，O(n3)，肯定会超时。节省时间的话，用动态规划吧。但简单的动态规划，显然是会超出内存限制的。有没有更巧妙的子问题划分方法呢？~~先找到子问题：因为要求的串必须连续，分治的时候需要考虑如何延续这个连续性，那么每个子问题中就得考虑找出三个串：1.即左端连续的最大串，2.右端连续的最大串，3.整个串中的最大串.~~由于每个问题都有三个量要维护，难道我得造出三个表来？卡主:(~~

<!--more-->

《编程珠玑》列出了性能上依次递进的四个算法。这里我结合个人理解和感悟做一些阐释。

* 1.粗暴的brute forse。三层循环嵌套，据说当n 为100000的时候，就需要运行15天时间=.=

```
maxsofar = 0
for i = 0 [0, n)
	for j = [i, n)
		sum = 0;
		for k = [i, j]
		 sum += x[k]
		 /*sum is sum of x[i..j]*/
		 maxsofar = max(maxsofar, sum)
```

* 2.针对第一个算法做出了优化。利用零时变量保存状态，避免了过多的重复操作，即所谓的**memoization思想**。时间复杂度下降到O(n*logn)。不过这份代码在PAT的OJ上仍然会超时。

```
maxsofar = 0;
for i = [0, n)
	sum = 0;
	for j = [i, n)
		sum += x[j]
		/* sum is sum of x[i..j]*/
		max sofar = max(maxsofar, sum)
```

相比之下，动态规划的策略也是有memoization的思想在的，不过，在这里用DP将会创建一张很大的表。。。超出内存限定。

* 3.分治算法

	其实之前我自己在思考DP更好的子问题划分时，已经考虑到了这种分治策略。但它的实现，**并非需要DP支持**。
	
	divide：将串平均分为两段，如下代码第6行。分别处理两个子串，并拼接计算。

	conquer： 计算1.自身包含左端的最大子串；2.包含右端的最大子串；（这两个子串用于与其他子串拼接）；3.自身的最大子串。
	
```
float maxsum3(l, u)
	if (l > u) /* zero elements*/
		return 0
	if (l == u) /* one element*/
		return max (0, x[l]);
	m = (1 + u) / 2
	
	/* find max crossing to left */
	lmax = sum = 0
	for (i = m; i >= 1; i--)
		sum += x[i]
	lmax = max(lmax, sum)
	
	/* find max croosing to right */
	rmax = sum = 0;
	for i = (m, u]
		sum += x[i]
	rmax = max(rmax, sum)
	
	return max(lmax+rmax, maxsum3(l, m), maxsum3(m+1, u))	
```

* 4.扫描算法

	类似于**数学归纳法**的思想。从串的最左端开始扫描。对于子串[0, k],其最大子串要么存在于[0, k-1]中而不包含[k]，称其为maxsofar，要么包含[k]，称其maxendingright。
	
	maxsofar和maxendingright是可能重合的。maxendingright的作用在于对[0,k+1]的子串而言，新的元素[k+1]可以与之结合，从而产生可能的新的子串。
	
	如果[k+1]本身就是负数呢？不要紧，将[k+1]加入到maxendingright的过程本身就是试错以产生可能的过程。当maxendingright降到0以下时，放弃掉这一子串就好了，因为无论如何扩张，它都是会拖后退的。别忘了，我们还维护着maxsofar，它记录最大的子串。有点绕，但是可以严格的证明算法的正确性。
	
	伪代码如下：
	
```
maxsofa = 0
maxendingright = 0
for i = [0, n)
	/* invariant: maxendingright and maxsofar are accurate for x[0..i-1]*/
	maxendingright = max(maxendingright + x[i], 0)
	maxsofar = max(maxsofar, maxendingright)
```

根据这个思路，写出[代码](https://github.com/biaobiaoqi/biaobiaoqiCode/blob/master/src/biaobiaoqi/pat/advancedlevel/APAT1007.java)，一遍AC:)
	

总结：
---
* 保存状态，避免重复计算：在算法整体框架没有大的优化的情况下，时间和空间的trade-off或许会有奇效。memoization本身就是一种用空间换时间的思想，而DP中用一种方式实现了这种思想。不过不要被DP算法所禁锢。因为，这个trade-off的实现是很多变的，就像这题的第2种算法。
* 分治：它的重要性不必多说了。同样的，DP中有分治的思想，但分治本身也是非常灵活的。
* 数学归纳证明，对算法的设计和正确性佐证很有帮助。话说它也类似于分治的思想呢。
