# Implementation-of-Linked-List-Recursion-Sorting-CPU-Disk-Consumption

# Abstract
This task aims on the design and execution of toy “memory database” using linked list data structures to efficiently manage student records stored in CSV file. This memory database is developed using any of the two different programming languages from Julia, Python, Java, GO, and C/C++. Basically, this memory database must showcase the three core recursive operations: fetch all the records from student-data.csv file and load into a linked list in-memory; ensure that memory database should adapt changes after the addition or removal of record; export all the in-memory records to a new CSV file; applied bubble and insertion sorting algorithm to the in-memory data; and exported back the sorted data to a CSV files through recursive functions. The work also analyzes the CPU and disk usage for both sorting algorithms on Ubuntu, highlighting the performance differences. This technique illustrates the importance of singly and doubly linked list data structures, indicates node traversal, memory allocation, sorting methods, and system resource profiling. It also provides hands-on exposure with recursion and dynamic data management in a Linux-based environment.

# Introduction
Efficient data management is a big challenge for data engineers and software developers. The goal of this task is to store & manipulate the data efficiently stored in a memory database specially when the data is subjected to frequent changes. Memory database is not a disk-based database like Oracle SQL or MySQL, it’s basically da program that stores data in RAM using linked list along with recursive functions to load the data & export to a CSV file.
Linked list solves this problem due to its logical properties and provides dynamic solution of handling the data by enabling memory allocation. In addition to this, linked list provides consistent insertion as well as deletion of elements without shifting large blocks of elements.
Using bubble sort and insertion sort algorithm, the implementation to sort the data based on any chosen column, handling both numeric and string types. The sorted data is exported using a recursive CSV export function. This study also measures system performance (CPU and disk usage) to compare the computational performance of the two sorting methods.
This project was executed in Python programming by applying doubly linked list approach and Julia programming by applying singly linked list approach within an Ubuntu 25.04 installed on Oracle VirtualBox.

# Requirements
Host Machine: Windows 11
Virtualization Tool: Oracle VirtualBox 7.1.12 (Click here to download)
Guest OS: Ubuntu 25.04 (Click here to download)
IDE: Visual Studio Code
Preferred Programming Language: Python, Julia
Python Libraries: csv, os, time, subprocess, psutil
Julia Libraries: CSV, DataFrames, Dates, Statistics
Dataset: student-data.csv

# Linked List
Linked list is a linear data structure that stores data in dynamic/non-continuous form, allows efficient insertion and deletion operations. Inside linked list, each node stores the data and memory address of the next node.
Basically, there are three types of linked list:

1.	Singly Linked List

A singly linked list consists of the nodes, pointer (data, next) where each node represents the data field and points to the memory address of next node. In addition to this, head stores the memory address of the first node whereas the next of the last node is null.

Head = Memory address of 1st node,
Next = Memory address of next node (Pointer),
Null = Represents the next of last node,
Data = Element stored in current node

2.	Doubly Linked List

A doubly linked list consists of the nodes, pointers (previous, data, next) where each node represents the data field and points to the memory address of next as well as previous node. In addition to this, head stores the memory address of the first node, next of the last node is null and previous of the first node is null. A doubly linked list is a more complex data structure than a singly linked list, but it offers several advantages. The main advantage of a doubly linked list is that it allows for efficient traversal of the list in both directions.

Head = Memory address of 1st node,
Next = Memory address of next node (Pointer),
Prev = Memory address of previous node (Pointer),
Null = Represents the previous of 1st node and next of last node,
Data = Element stored in current node

3.	Circular Linked List

A circular linked list is a data structure where a last node points to the address of first node or head, forms a closed loop. It is best suitable for tasks like scheduling and managing playlists. There are two types of circular linked list:

  a. Circular Singly Linked List

A circular singly linked list consists of the nodes, pointer (data, next) where each node represents the data field and points to the memory address of next node. In addition to this, head stores the memory address of the first node whereas the next of the last node stores the memory address of the first node, forms a circle.

Head = Memory address of 1st node,
Next = Memory address of next node (Pointer),
Data = Element stored in current node

  b. Circular Doubly Linked List

A circular doubly linked list consists of the nodes, pointers (previous, data, next) where each node represents the data field and points to the memory address of next node. In addition to this, head stores the memory address of the first node, next of the last node stores the memory address of the first node, and previous of the first node stores the memory address of the last node, forms a circle.

Head = Memory address of 1st node,
Next = Memory address of next node (Pointer),
Prev = Memory address of previous node (Pointer),
Data = Element stored in current node

# Recursion
A technique with the help of which function calls itself either directly or indirectly is called recursion and its relevant function is called recursion function. A recursion algorithm continues to call itself until all the sub-problems gets resolved to provide the combined solution.

Process to Execute Recursion Approach
1.	Define a base class to stop the condition defined in recursive function in order to prevent from infinitely calling itself.
2.	Break a problem into the smaller versions and then define those sub-problems into the recursive functions to solve each.
3.	Merge the solutions of smaller problems to achieve solution for an original problem.

# Bubble Sort
Bubble sort is a comparison-based sorting algorithm where two adjacent elements are compared and swapped if they are not in sequence in order to arrange all the elements in ascending or descending order as per the requirement.

Complexity:
•	Best Case – O(n) -> When an array is already sorted.
•	Average Case – O(n²) -> In case of lots of comparison and swaps.
•	Worst Case – O(n²) -> When an array is in reverse order.
•	Space Complexity – O(1) -> No extra memory required.

Algorithm:
Step 1 – Check if the first element of input is greater than the second element.
Step 2 – If greater, swap the elements and move the pointer forward.
Step 3 – Repeat step 2 until the last element.
Step 4 – Check of all the elements are sorted. If not, repeat the same process (step 1 to step 3) from the last element to first and output is the sorted array.

# Insertion Sort
Insertion sort is a simplest method of sorting elements in ascending or descending order where a sub-array is managed step by step by taking one item at a time and placing it in its correct.

Complexity:
•	Best Case – O(n) -> When an array is already sorted.
•	Average Case – O(n²) -> In case of lots of swaps.
•	Worst Case – O(n²) -> When an array is in reverse order.
•	Space Complexity – O(1) -> No extra memory required.

Algorithm:
Step 1 – If the first element is already sorted, return 1 and move to next element.
Step 2 – Compare with all the elements of sub-array.
Step 3 – Shift all the elements in the sorted sub-array that is greater than the value to be sorted.
Step 4 – Insert the value and repeat the steps until array is sorted.

# CPU/Disk Utilization
CPU usages is basically the percentage of the processing power allocated to a task where as disk utilization illustrates the percentage of the hard drive or SSD is occupied by that task to perform read or write operations.

In windows, Task Manager is the best feature to monitor the real time memory, CPU and disk utilization. Moreover, this monitoring can also help in evaluating the system performance. In organizations, several teams are built to monitor these utilization parameters just to make sure that application will work smoothly.

There are several Linux commands that are executed in terminal to calculate CPU/DISK Utilization:

•	top: system performance, including CPU and memory utilization.
•	mpstat: CPU usage statistics.
•	iostat: monitor systems input output device statistics including disk performance.
•	df: display information about disk space usage.

# Discussion
An implementation of a toy “memory database” is bounded around three core principles: loading, adapting, and exporting. Each recursive function collectively corresponds to these core principles in order to meet the requirements.

1. Load Data Recursively
2. Adapting to Updates
3. Exporting Data
4. Sorting Algorithm
5. Performance Profiling and Outcome Comparison

# Conclusion
This task has successfully implemented the development of a toy “memory database” using singly linked list in Julia and doubly linked list in Python programming language. The model efficiently loads the data from student-data.csv file, adapts to the insert/update/delete operations, export the updated dataset to a resultant CSV file by preferring recursive functions, demonstrates the execution of bubble sort and insertion sort on memory database, CPU as well as disk performance to monitor the sorting efficiency and export the sorted dataset to a CSV file recursively.

This task highlights the practical benefit of managing dynamic data, the use of recursion in traversal and manipulation by linked list implementation in Julia and Python programming language (extended to more complex database systems), sorting data in memory database and monitoring of system health (elaborates the CPU/DISK I/O utilization).
