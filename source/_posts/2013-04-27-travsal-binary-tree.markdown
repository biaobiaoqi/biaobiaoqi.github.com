---
layout: post
title: "二叉树的遍历（递归、非递归）分析"
date: 2013-04-27 21:03
comments: true
description: "二叉树，递归，非递归，中序遍历，前序遍历，后序遍历"
categories: [tech]
tags: [算法, 技术]

---
背景
---

* 2013-10-7 修订部分内容


本文讨论二叉树的常见遍历方式的代码(Java)实现，包括前序(preorder)、中序(inorder)、后序(postorder)、层序(level order)，进一步考虑递归和非递归的实现方式。

递归的实现方法相对简单，但由于递归的执行方式每次都会产生一个新的方法调用栈，如果递归层级较深，会造成较大的内存开销，相比之下，非递归的方式则可以避免这个问题。递归遍历容易实现，非递归则没那么简单，非递归调用本质上是通过维护一个栈，模拟递归调用的方法调用栈的行为。

在此之前，先简单定义节点的数据结构：

二叉树节点最多只有两个儿子，并保存一个节点的值，为了实验的方便，假定它为int。同时，我们直接使用Java的System.out.print方法来输出节点值，以显示遍历结果。

```java
public class Node {
		public int value;
		public Node leftNode;
		public Node rightNode;
		
		public Node(int i) {
			value = i;
		}
	}
```

详细代码参见链接:[BST及其各种便利的详细实现代码](https://github.com/biaobiaoqi/biaobiaoqiCode/blob/master/src/biaobiaoqi/algorithm/basics/tree/BinarySearchTree.java)

<!--more-->

前序遍历
---


####递归实现

递归实现很简单，在每次访问到某个节点时，先输出节点值，然后再依次递归的对左儿子、右儿子调用遍历的方法。代码如下

```java
	public void preOrderTrav(Node n) {
		if (n != null) {
			System.out.print(n.value + " ");
			preOrderTrav(n.leftNode);
			preOrderTrav(n.rightNode);
		}
	}
```

####非递归调实现

#####方法1

```java
	public void preOrderTravNoRecur(Node n) {
		Stack<Node> stack = new Stack<Node>();
		stack.add(root);
		while (!stack.empty()) {
			Node t = stack.pop();
			System.out.print(t.value + " ");
			if (t.rightNode != null)
				stack.add(t.rightNode);
			if (t.leftNode != null)
				stack.add(t.leftNode);
		}
	}
```

* 描述

	维护一个栈，将根节点压入栈中。此后，每次从栈中读出栈顶的节点，作为对节点的访问，然后将该节点的儿子节点按照先右后左的顺序，压入栈中，实现递归模拟。

* 分析

	这个栈的递归策略不具备很好的扩展性，其他的遍历方式无法使用这种策略。实际上，它并不是对程序调用栈的模拟，而是针对先序遍历的特殊实现：先序遍历先对当前节点做出访问后，然后递归的调用对儿子节点的遍历，不需要在对儿子节点遍历结束后再回过头来处理当前节点。于是模拟的递归中也不需要存储之前的调用栈信息，只需要类似的生成一个未来的儿子节点的访问计划即可。

#####方法2

```java
	public void preOrderTravNoRecurII(Node n) {
		System.out.println("No Recursive: ");
		Stack<Node> s = new Stack<Node>();
		while (n != null | !s.empty()){
			while (n!=null ){
				System.out.print(n.value + " ");
				s.add(n);
				n = n.leftNode;
			}
			n = s.pop();
			n = n.rightNode;
		}
		System.out.println();
	}
```
* 描述

	1.维护一个栈s和一个当前节点n。初始时将n赋值为根节点。
	
	2.逐个访问当前节点n的左子链上的节点，并推入栈中，直到没有左儿子。
	
	3.取出栈顶的节点，将n赋值为该节点的右儿子。
	
	4.不断执行2，3，直到栈为空且当前节点也为空。

* 分析

	该方法模拟了递归的前序遍历中程序调用栈的行为过程：在调用栈中，会不断的递归进入左儿子链中，直到没有左儿子，再进入对右儿子的处理中。与递归方法的调用栈的不同之处在于，内层while循环将递归方法中针对左儿子链上所有节点的递归过程集中到了一起。

中序遍历
---
####递归实现

```java
	public void inorderTrav(Node n) {
		if (n != null) {
			inorderTrav(n.leftNode);
			System.out.print(n.value + " ");
			inorderTrav(n.rightNode);
		}
	}
```

####非递归实现

```java
	public void inorderTravNoRecu(Node n) {
		System.out.println("No Recursive: ");
		Stack<Node> s = new Stack<Node>();
		while (n != null | !s.empty()){
			while (n!=null ){
				s.add(n);
				n = n.leftNode;
			}
			n = s.pop();
			System.out.print(n.value + " ");
			n = n.rightNode;
		}
	}
```

* 描述

	1.维护一个栈s和一个当前节点n。初始时将n赋值为根节点。
	
	2.将当前节点n的左子链上的节点逐个推入栈中，直到没有左儿子。
	
	3.取出栈顶的节点，访问该节点，将n赋值为该节点的右儿子。
	
	4.不断执行2，3，直到栈为空且当前节点也为空。

* 分析
	
	跟前序遍历的非递归实现方法二很类似。唯一的不同是访问当前节点的时机：前序遍历在入栈前访问，而中序遍历在出栈后访问。


后序遍历
---
####递归实现

```java
public void postOrderTrav(Node n) {
		if (n != null) {
			inorderTrav(n.leftNode);
			inorderTrav(n.rightNode);
			System.out.print(n.value + " ");
		}
	}
```

####非递归实现


```java
public void postOrderTravNoRecu(Node n) {		
		Stack<Node> stack = new Stack<Node>();
		int[] flag = new int[max];
		
		while (n != null) {
			stack.push(n);
			flag[stack.size()] = 0;
			n = n.leftNode;
		}
		
		while (!stack.empty()) {
			n = stack.peek();
			if (n.rightNode != null && flag[stack.size()] == 0) {
				n = n.rightNode;
				flag[stack.size()] = 1;
				while (n != null) {
					stack.push(n);
					flag[stack.size()] = 0;
					n = n.leftNode;
				}
				n = stack.peek();
			}
			n = stack.pop();
			System.out.print(n.value + " ");
		}
		
	}
```

* 描述

	1.维护一个栈stack、当前节点n和一个标记数组flag。将根节点的左儿子链上的所有节点压入stack中，并将标记数组对因为值置为0.
	
	2.将当前节点赋值为栈顶的节点。如果节点有右儿子，且没有被处理过（通过标记数组判定），则将右子树的根节点及其左儿子全部压入栈中。
	
	3.将当前节点付志伟栈顶的节点，访问它，并将该节点从栈中pop出。
	
	4.循环2，3两步，直到栈为空。

* 分析

	在非递归方法中用栈模拟程序调用栈，碰到的最大的问题就是模拟递归方法所处的状态。编码维护的栈能记录节点，但无法记录在如何处理该节点。这里使用了一个`flag`数组来记录节点的右子树是否被访问过，对每个节点进行访问的时候，都保证已经处理完了左右子树（通过先压入左边儿子链为主线，处理栈中的每个节点时，再压入右边儿子来实现）。


层序遍历
---

####无法使用递归方法

层序遍历不同于其他的遍历，无法使用递归实现。

* 反证法证明

	如果能实现对A节点的层序递归，在对A节点处理的过程中，应该递归的对两个儿子B和C分别调用了层序遍历。在这种情况下，我们无法让B和C的同一个层级的儿子在集中的时间中被遍历到，换言之，B的第一层儿子在对B的调用中被遍历，而C的第一层儿子，则在对C的调用中遍历，这是分离开的。不成立，得证。

####非递归方法

```java
	public void levelOrderTrav(Node n) {
		System.out.print("Level OrderTrav: ");
		
		Queue<Node> q = new LinkedList<Node>();
		q.add(n);
		while (q.size() != 0) {
			n = q.poll();
			System.out.print(" " + n.value);
			if (n.leftNode != null) 
				q.add(n.leftNode);
			if (n.rightNode != null)
				q.add(n.rightNode);

		}
	}
```

* 分析

	用一个队列实现层序遍历，拓扑排序中也有用到这种方式。

总结
---

非递归实现的代码相对来说没有递归实现的直观。其核心都是维护了一个栈来保存状态，避免了产生过多方法调用栈浪费内存空间。
