---
layout: post
title: "出栈序列的可能性判定（PAT1051）"
date: 2013-07-16 01:32
comments: true
categories: [tech]
tags: [algorithm, think, methodology, pat]
description: "1051. Pop Sequence (25)，不同于常规解法，本文使用更高效的解法完成对pop数组的检验。"

---

问题说明
---

[PAT1051](http://pat.zju.edu.cn/contests/pat-a-practise/1051)：给定stack的容量，给定数据的入栈顺序：从1开始的正整数序列，在允许随机的出栈操作的情况下，要求判断某出栈序列是否可能。

比如，告知stack容量为5，入栈序列的最大值为7。有两个序列需要判断合理性：

* `1 2 3 4 5 6 7`： 这个序列是可能的，只需每次入栈时都做出栈操作。
* `3 2 1 7 5 6 4`： 这个序列是不可能的，其中前半部分`3 2 1`是合法的，先将`1 2 3`顺序入栈，然后三次执行出栈操作。而之后的`7 5 6`则是不可能的。

要完成判定过程，常规思路是直接使用的stack数据结构模拟出栈序列做操作，然后判定是否会触犯条件。但考虑到PAT1051中时间限制只有10ms，虽然常规方法是线性的，似乎也无法保障（事实证明是错误的，用常规方法也能在PAT上AC），我想到从序列本身的特性入手，找规律，于是有了一种效率更高的判定逻辑。

常规思路
---
直接使用出栈序列指导stack模拟操作。判定条件有两条：

* 1.栈中数据量不超过栈的容量。
* 2.出栈只能从栈顶取，不应该出现从固定的堆栈中取出其他数据的情况。

算法描述如下：

用游标记录当前已知压栈的最大数据cur。如果新的读入数据tmp（即出栈序列中的某数据）大于cur，则将cur到tmp之间的数据顺序压入栈中，更新cur并执行检查1；如果新的读入数据tmp小于cur，则一定是直接出栈获得的，执行检查2。

如果能顺利完成就是合理的，如果操作过程违背了一些规则，则判定为不合理。C++实现代码如下：

``` cpp

#include<stdio.h>
#include<stack>
using namespace::std;
int m, n, k, tmp, cur;
bool flag;
stack<int> s;
int main()
{
    scanf("%d %d %d", &m, &n, &k);
    while(k --) {
        flag = true;
        cur = 1;
        s.push(1);
        for (int i = 0; i != n; ++ i) {
            scanf("%d", &tmp);
            if (tmp > cur) {
                for (int j = cur + 1; j <= tmp; ++ j)
                    s.push(j);
                if (s.size() > m) flag = false;
                cur = tmp;
            }else {
                if (s.top() != tmp)
                    flag = false;
            }
            s.pop();
        }

        if (flag) printf("YES\n");
        else printf("NO\n");
    }
}

```

更高效的判定逻辑
---
实际上，在PAT1051的环境下，由于入栈序列数据由小到大排列非常特殊，要通过出栈序列判定可能性是存在简便思路的。

对比分析题中Sample给出的序列，结合上面提到的两条冲突条件入手分析：

* 1.栈中数据量不超过栈的容量：

	只有在入栈时，才会需要考虑栈中数据是否超量。出栈序列中的每个数，都以为着在出栈操作之前，它刚入栈，那么当它入栈的时候能否判定是否超过栈容量呢？可以的，（当前的出栈数值 - 已经执行过的出栈操作数量）就是当前栈中元素的数量。
	
<!--more-->

* 2.出栈只能从栈顶取，不应该出现从固定的堆栈中取出其他数据的情况。
	
	根据观察分析发现，当某数据m出栈之后，比m小的数据如果在m之后出栈的，它们所组成的序列本身需要保持从大到小的顺序排列。距离如`3 2 1 7 5 6 4`这个序列，在`7`之后有`5 6 4`这个子序列，它们都大于`7`，但却没有保持一个递减的顺序，不合法。
	
C++实现代码如下：

``` cpp
#include<stdio.h>
int m, n, k;
int max, min, tmp;
bool flag;
int main()
{
    scanf("%d %d %d", &m, &n, &k);
    while(k --) {
        flag = true;
        max = 0;
        min = 1001;
        
        for (int i = 0; i != n; ++ i) {
            scanf("%d", &tmp);
            if (tmp > max) {
                if (tmp - i > m) flag = false;
                else max = min= tmp;
            } else {
                if ( tmp > min) flag = false;
                else min = tmp;
            }
        }
        
        if (flag) printf("YES\n");
        else printf("NO\n");
    }
}
```
总结
---
在我的理解之中，经典的算法、数据结构是在面对编程问题的解决过程中所抽象出的通用模型。而生活是多变的，并不像考试卷一样简单的套用数学题所能解决，很多情况下，编程问题也是如此。那么除了这些经典的方法外，认真分析条件，并进行针对性的优化甚至重新设计就非常重要了。这里仅仅是一个小实践。
