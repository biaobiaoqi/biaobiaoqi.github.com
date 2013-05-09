---
layout: post
title: "二叉树的遍历（递归、非递归）分析"
date: 2013-04-27 21:03
comments: true
description: "本文讨论二叉树的常见遍历方式的代码实现（这里贴出的是Java），包括前序(preorder)、中序(inorder)、后序(postorder)、层序(level order)，进一步，考虑递归和非递归的实现方式。递归方法的实现相对简单，但递归的执行方式由于每次都会产生一个新的方法调用栈，如果递归层级较深，会消耗较大的内存，转化为非递归则没那么简单了，往往需要实现一个栈来保存状态信息。"
categories: [tech, algorithm]
---
背景
---

二叉树是一种很基本的数据结构。很多地方能看到它的身影，比如大名鼎鼎的霍夫曼编码（好了，别问我再比如了，见识浅薄，真不知道更多了。。。）它的结构很简洁、巧妙。

本文讨论二叉树的常见遍历方式的代码实现（这里贴出的是Java），包括前序(preorder)、中序(inorder)、后序(postorder)、层序(level order)，进一步，考虑递归和非递归的实现方式。递归方法的实现相对简单，但递归的执行方式由于每次都会产生一个新的方法调用栈，如果递归层级较深，会消耗较大的内存，转化为非递归则没那么简单了，往往需要实现一个栈来保存状态信息。
<!--more-->
在此之前，先简单定义节点的数据结构：

二叉树节点最多只有两个儿子，并保存一个节点的值，为了实验的方便，假定它为int。同时，我们直接使用Java的System.out.print方法来输出节点值，以显示遍历结果。

```
public class Node {
		public int value;
		public Node leftNode;
		public Node rightNode;
		
		public Node(int i) {
			value = i;
		}
	}
```
详细代码参见链接:[BST及其各种便利的详细实现代码](https://github.com/biaobiaoqi/biaobiaoqiCode/blob/master/src/biaobiaoqi/algorithm/tree/BinarySearchTree.java)

前序遍历
---


* 递归实现：递归实现很简单，在每次访问到某个节点时，先输出节点值，然后再依次递归的对左儿子、右儿子调用遍历的方法。代码如下

```
	public void preOrderTrav(Node n) {
		if (n != null) {
			System.out.print(n.value + " ");
			preOrderTrav(n.leftNode);
			preOrderTrav(n.rightNode);
		}
	}
```

* 非递归调实现：

1.第一种实现方式相对容易理解：

初始：维护一个栈，将根节点压入栈中。

循环：每次从栈顶读出一个节点信息，直接将节点值**输出**，同时将儿子节点按从左到右的顺序推到栈顶。

分析：跟递归调用的整体思路一样，不同的是，递归调用时是利用运行时系统所维护的程序调用栈来维护顺序，而这个非递归方法是用过自己维护的栈来保存信息。如此节省了调用栈的空间。

```
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

2.第二种实现方式更普遍（中序遍历的非递归使用了同样的思路）：

初始：维护一个栈S和一个节点变量N。节点变量赋值为根节点。

循环：将节点变量N的左儿子循环的**输出**，并推入栈S中，直到没有左儿子；推出栈S的顶节点，节点变量N赋值为栈S顶节点的右节点。

分析：不同于递归调用的思路。栈S用于实现对某节点的左边支递归值的存储，以便回溯；节点变量N则用于遍历某节点的右边枝（这些节点是从栈S顶读出的节点，依次做处理），由于右边枝是最后才会被访问到的，故在处理右边枝的时候，不需要存储右边枝的信息，依次处理即可。

```
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

###中序遍历
* 递归实现

```
	public void inorderTrav(Node n) {
		if (n != null) {
			inorderTrav(n.leftNode);
			System.out.print(n.value + " ");
			inorderTrav(n.rightNode);
		}
	}
```

* 非递归实现

初始：维护一个栈S和一个节点变量N。节点变量赋值为根节点。

循环：将节点变量N的左儿子循环的**输出**，并推入栈S中，直到没有左儿子；节点变量N赋值为栈S顶节点的右节点。

分析：跟前序遍历的非递归实现方法二很类似。唯一的不同是输出的时机不同：前序遍历在入栈时输出，而中序遍历在出栈时输出。可以跟深刻的理解到，栈在这里是为了回溯而存在的。

```
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

###后序遍历
* 递归实现

```
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

* 非递归实现

初始：1.维护一个栈S、一个节点变量N和一个标记数组。节点变量赋值为根节点，栈暂时存储便利到的节点，标记数组用于标记栈中的节点是否已经访问过右边节点。2.将根节点的所有左儿子压入栈中。

循环：依次处理栈中节点。如果节点有右儿子，且没有被处理过（通过标记数组判定），则将右子树的根节点及其左儿子全部压入栈中；如果已经处理过或者没有右儿子，则输出并出栈。

分析：与前序和中序的一个大的不同在于需要用标记数组标记节点的右子树是否已经访问过。对每个节点进行处理的时候，都保证已经处理完了左右子树（通过先压入左边儿子为主线，处理栈中的每个节点时，再压入右边儿子来实现）。

```
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
			while(n.rightNode != null && flag[stack.size()] == 0) {
				n = n.rightNode;
				flag[stack.size()] = 1;
				while (n != null) {
					stack.push(n);
					flag[stack.size()] = 0;
					n = n.leftNode;
				}
				n = stack.peek();//TODO be careful about this
			}
			n = stack.pop();
			System.out.print(n.value + " ");
		}
		
	}
```


###层序遍历

* 无法使用递归方法

层序遍历不同于其他的遍历。可以通过反证法证明：

如果能实现对A节点的层序递归，在对A节点处理的过程中，应该递归的对两个儿子B和C分别调用了层序遍历。在这种情况下，我们无法让B和C的同一个层级的儿子在集中的时间中被遍历到，换言之，B的第一层儿子在对B的调用中被遍历，而C的第一层儿子，则在对C的调用中遍历，这是分离开的。不成立，得证。

* 非递归方法：

分析：此方法类似于前序遍历的非递归方法的第一种。用一个栈维护信息。

```
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


总结
---
非递归实现的代码相对来说没有递归实现的直观。其核心都是维护了一个栈来保存状态，避免了产生过多方法调用栈浪费内存空间。

本文中针对二叉树的几种遍历方式，描述了递归和非递归的解决方案。普遍意义的递归转非递归的方法和思想，将在另外一篇博文中介绍;)。欢迎交流。
