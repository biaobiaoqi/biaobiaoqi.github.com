---
layout: post
title: "基本排序总结"
date: 2013-04-30 23:58
comments: true
categories: [tech]
tags: [算法, 排序]

---

最近准备面试，正好把刚接触数据结构时学习的排序整理了一下。算法的实现在wiki上都有详细的介绍，这里主要做归纳和总结。

注意对排序算法的稳定性的理解：保证2个相等的数在序列的前后位置顺序和排序后它们两个的前后位置顺序相同。换句话说，相等的数值在排序时不断交换位置是不稳定的。


<!--more-->

##冒泡排序

使用冒泡排序为一列数字进行排序的过程如下图：

![冒泡排序](http://upload.wikimedia.org/wikipedia/commons/3/37/Bubble_sort_animation.gif)

Java实现：

```
    int temp = 0;
    for (int i = a.length - 1; i > 0; --i) {
      for (int j = 0; j < i; ++j) {
        if (a[j + 1] < a[j]) {
          temp = a[j];
          a[j] = a[j + 1];
          a[j + 1] = temp;
        }
      }
    }
```

* 最差时间复杂度：O(n^2)
* 最优时间复杂度：O(n)：在遍历时，如果有设定标记，对于已排序的数组，可以实现O(n)
* 平均时间复杂度：O(n^2)
* 最差空间复杂度：总共O(n)，需要辅助空间O(1)
* 稳定性：稳定


##插入排序

使用插入排序为一列数字进行排序的过程如下图：

![](http://upload.wikimedia.org/wikipedia/commons/2/25/Insertion_sort_animation.gif)


Java实现

```
for(int index=1;index<data.length;index++){  
	Comparable key = data[index];  
	int position = index;  
    //shift larger values to the right  
    while(position>0&&data[position-1].compareTo(key)>0){  
    	data[position] = data[position-1];  
        position--;
   	}  
    data[position]=key;  
}     
```


* 最差时间复杂度：O(n^2)
* 最优时间复杂度：O(n)：顺序的情况。
* 平均时间复杂度：O(n^2)
* 最差空间复杂度：总共O(n) ，需要辅助空间O(1)
* 稳定性：稳定

##选择排序

使用选择排序为一列数字进行排序的过程如下图：

![](http://upload.wikimedia.org/wikipedia/commons/b/b0/Selection_sort_animation.gif)

Java实现

```
for (int index = 0; index < array.length - 1; index++) {
	min = index;
	for (int time = index + 1; time < array.length; time++) {
		if (array[time].compareTo(array[min]) < 0) {
			min = time;
		}
	}
	temp = array[index];
	array[index] = array[min];
	array[min] = temp;
}

```


* 最差时间复杂度：О(n^2)
* 最优时间复杂度：О(n^2):比插入、冒泡都还要弱。
* 平均时间复杂度：О(n^2)
* 最差空间复杂度：总共O(n) ，需要辅助空间O(1)
* 稳定性：不稳定。比如对于数组{3,2,3,1}, 第一次交换发生在[0]和[3]之间，[0]的3被交换到[2]的3之后了。


##快速排序

使用快速排序为一列数字进行排序的过程如下图：（图中取最后一个元素为pivot，代码实现中取第一个元素为pivot）

![](http://upload.wikimedia.org/wikipedia/commons/6/6a/Sorting_quicksort_anim.gif)

Java实现

```
public void sort (int[] input){
      sort (input, 0, input.length-1);
}

private void sort(int[] input, int lowIndex, int highIndex) { 
	if (highIndex<=lowIndex){
    	return;
   	}
 
	int partIndex=partition (input, lowIndex, highIndex);
 
    sort (input, lowIndex, partIndex-1);
    sort (input, partIndex+1, highIndex);
}
 
private int partition(int[] input, int lowIndex, int highIndex) {
	int i=lowIndex;
	int pivotIndex=lowIndex;
    int j=highIndex+1;

    while (true){
    	while (less(input[++i], input[pivotIndex])){
        	if (i==highIndex) break;
        }

        while (less (input[pivotIndex], input[--j])){
        	if (j==lowIndex) break;
        }

        if (i>=j) break;

        exchange(input, i, j);
	}
	
    exchange(input, pivotIndex, j);

    return j;
}

```

* 最差时间复杂度：Theta(n^2)：如果选取pivot不够科学，在有序或者逆序的情况下会产生n^2的时间开销。
* 最优时间复杂度：Theta(n*logn)
* 平均时间复杂度：Theta(n*logn)
* 最差空间复杂度：根据实现的方式不同而不，基本快排中总共O(n) ，需要辅助空间O(1)
* 稳定性：不稳定。比如：{5, 10, 11, 3, 3, 3}，后面相等的3会被交换到10和11的位置，而且两者相对位置会变化。

快速排序的分治(divide and conquer)思想非常经典。算法实现上，对pivot的选取也有不同的策略来做优化。比如可以选取数组的第一个元素、最后一个元素和中间元素中排中间大小的那一个。这里介绍的是快排的基础算法，也叫单基算法，还有[双基、三基快速排序](http://www.importnew.com/8445.html)。java.util.Arrays中对基本类型的排序就使用了双基快排（一般对象类型使用的归并排序）。

虽然快速排序最差时间复杂度有n^2，不过这种情况很少见，像它的名字那样，是内部排序中最快的。

适用场景：topK：寻找最大的K个数

##归并排序

![](http://upload.wikimedia.org/wikipedia/commons/c/c5/Merge_sort_animation2.gif)

Java实现

```
public void sort(Integer[] list) {
	if (list.length == 0) {
		System.out.println("");
	} else {
		Integer[] tmpList = new Integer[list.length];
		mergeSort(list, 0, list.length - 1, tmpList);
	}
}

public void mergeSort(Integer[] list, int leftPos, int rightPos,
		Integer[] tmpList) {
	if (leftPos >= rightPos)
		return;

	int center = (leftPos + rightPos) / 2;
	mergeSort(list, leftPos, center, tmpList);
	mergeSort(list, center + 1, rightPos, tmpList);
	merge(list, leftPos, center, rightPos, tmpList);
}

public void merge(Integer[] list, int leftPos, int leftEnd, int rightEnd,
		Integer[] tmpList) {
	int leftIndex  = leftPos;
	int rightIndex = leftEnd + 1;
	int index = leftIndex;
	
	while (leftIndex <= leftEnd && rightIndex <= rightEnd) {
		if (list[leftIndex] <= list[rightIndex]) {
			tmpList[index++] = list[leftIndex++];
		} else {
			tmpList[index++] = list[rightIndex++];
		}
	}

	while (leftIndex <= leftEnd) {
		tmpList[index++] = list[leftIndex++];
	}
	while (rightIndex <= rightEnd) {
		tmpList[index++] = list[rightIndex++];
	}

	for (int i = leftPos; i <= rightEnd; i ++) {
		list[i] = tmpList[i];
	}

}

```

* 最差时间复杂度：Theta(n*logn)
* 最优时间复杂度：Theta(n)
* 平均时间复杂度：Theta(n*logn)
* 最差空间复杂度：总共O(n)，需要辅助空间O(1)
* 稳定性：稳定

Java的java.util.Arrays中对一般对象的排序使用了改良的归并算法：待排序的数组元素少于`INSERTIONSORT_THRESHOLD`时，执行插入排序。

归并排序比堆稍快，但需要一倍的额外存储空间。经常使用的场景：两个已排序数组合并;单向链表排序。


##堆排序

Java实现

```
public int leftChild(int n) {
	return 2*n + 1;
}	

public void percolateDown(int[] list, int n, int length) {
	int tmp;
	int child;
	
	for (tmp = list[n]; leftChild(n) < length; n = child) {
		child = leftChild(n);
		
		if (child + 1 < length && list[child] < list[child + 1]) {
			child ++;
		}
		
		if (tmp < list[child]) {
			list[n] = list[child];
		}else {
			break;
		}
	}
	
	list[n] = tmp;
}

public void sort(int[] list) {
	for (int i = list.length/2; i >= 0; i --) {
		percolateDown(list, i, list.length);
	}
	
	for (int i = list.length - 1; i > 0; i --) {
		int tmp = list[i];
		list[i] = list[0];
		list[0] = tmp;
		
		percolateDown(list, 0, i);
	}
}

```

* 最差时间复杂度：O(n*logn)
* 最优时间复杂度：O(n*logn)
* 平均时间复杂度：Theta(n*logn) 
* 最差空间复杂度：总共O(n)，需要辅助空间O(1)
* 稳定性：不稳定。从堆顶摘掉放入堆尾，如果有跟它相等的值，一定会改变相对位置。比如{3, 27, 36, 27}，对大堆摘掉第一个27后，原来在后面的27被放到了堆顶。

不需要递归、额外空间，适用于数据量特别大的场景，比如海量数据求topK。除了这里的堆排序外，还需要掌握向堆中插入数据。


##外排序

通常来说，外排序处理的数据不能一次装入内存，只能放在读写较慢的外存储器（通常是硬盘）上。外排序通常采用的是一种“排序-归并”的策略。在排序阶段，先读入能放在内存中的数据量，将其排序输出到一个临时文件，依此进行，将待排序数据组织为多个有序的临时文件。然后在归并阶段将这些临时文件组合为一个大的有序文件，也即排序结果。

常用思路：

1. 使用快速排序、归并排序、堆排序等算法完成少量数据的排序，生成临时数据文件。
2. 使用败者树或最小堆，用归并的思路合并1中生成的临时文件，并输出为最后的排序结果。


##快排为什么那样快

刘未鹏在[《数学之美番外篇：快排为什么那样快》](http://mindhacks.cn/2008/06/13/why-is-quicksort-so-quick/)中从问题域向答案域演进的角度解释了基于比较的排序的时间复杂度极限。

核心思想是：N个数组的排序，有N!种可能结果，我们需要在N!中搜索出唯一正确的结果。基于比较的排序每次能输出的结果只有两种：是或否，一个只有两种输出的问题，最多能将可能性空间切分为两半，要让结果稳定可靠，最好的办法就是平均的切分为1/2和1/2，也就一次比较中a<b的概率和a>b的概率一样，如果能保证一这一点，就能保证最优下界，也就是log2(N!)，这个值近似于NlogN。


* 堆排序比快排慢：堆建立好之后，每次取堆顶，将堆尾的数据放到堆顶向下过滤，实际上，堆顶部的元素几乎肯定较大，而堆尾的数据都比较小，在向下过滤的过程中，浪费了很多次比较，让堆排序的速度变慢了。

* 基数排序比快排快：基数排序不是比较排序，将基数相同的元素放到一个桶里的操作，除了一次与技术本身的比较以外，不同的基数桶自然的形成了排序。这里基数桶用空间换取了时间。




##参考资料

* [冒泡排序wiki](http://zh.wikipedia.org/zh-cn/%E5%86%92%E6%B3%A1%E6%8E%92%E5%BA%8F)
* [插入排序](http://zh.wikipedia.org/wiki/%E6%8F%92%E5%85%A5%E6%8E%92%E5%BA%8F)
* [选择排序](http://zh.wikipedia.org/wiki/%E9%80%89%E6%8B%A9%E6%8E%92%E5%BA%8F)
* [快速排序](http://zh.wikipedia.org/wiki/%E5%BF%AB%E9%80%9F%E6%8E%92%E5%BA%8F)
* [本周算法：快速排序—三路快排 vs 双基准](http://www.importnew.com/8445.html)
* [堆排序](http://zh.wikipedia.org/wiki/%E5%A0%86%E6%8E%92%E5%BA%8F)
* [希尔排序](http://zh.wikipedia.org/wiki/%E5%B8%8C%E5%B0%94%E6%8E%92%E5%BA%8F)
* [基数排序](http://zh.wikipedia.org/zh-cn/%E5%9F%BA%E6%95%B0%E6%8E%92%E5%BA%8F)
* [外部排序](http://zh.wikipedia.org/wiki/%E5%A4%96%E6%8E%92%E5%BA%8F)
* [归并排序](http://zh.wikipedia.org/wiki/%E5%BD%92%E5%B9%B6%E6%8E%92%E5%BA%8F)
* [leetcode总结无止境系列之排序](http://cuijing.org/study/summary-of-sort-in-leetcode.html)
* [数学之美番外篇：快排为什么那样快](http://mindhacks.cn/2008/06/13/why-is-quicksort-so-quick/)


