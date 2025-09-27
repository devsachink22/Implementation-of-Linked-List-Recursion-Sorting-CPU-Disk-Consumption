# Implementation-of-Linked-List-Recursion-Sorting-CPU-Disk-Consumption

Abstract: This task aims on the design and execution of toy “memory database” using linked list data structures to efficiently manage student records stored in CSV file. This memory database is developed using any of the two different programming languages from Julia, Python, Java, GO, and C/C++. Basically, this memory database must showcase the three core recursive operations: fetch all the records from student-data.csv file and load into a linked list in-memory; ensure that memory database should adapt changes after the addition or removal of record; export all the in-memory records to a new CSV file; applied bubble and insertion sorting algorithm to the in-memory data; and exported back the sorted data to a CSV files through recursive functions. The work also analyzes the CPU and disk usage for both sorting algorithms on Ubuntu, highlighting the performance differences. This technique illustrates the importance of singly and doubly linked list data structures, indicates node traversal, memory allocation, sorting methods, and system resource profiling. It also provides hands-on exposure with recursion and dynamic data management in a Linux-based environment.

Introduction: Efficient data management is a big challenge for data engineers and software developers. The goal of this task is to store & manipulate the data efficiently stored in a memory database specially when the data is subjected to frequent changes. Memory database is not a disk-based database like Oracle SQL or MySQL, it’s basically da program that stores data in RAM using linked list along with recursive functions to load the data & export to a CSV file.
Linked list solves this problem due to its logical properties and provides dynamic solution of handling the data by enabling memory allocation. In addition to this, linked list provides consistent insertion as well as deletion of elements without shifting large blocks of elements.
Using bubble sort and insertion sort algorithm, the implementation to sort the data based on any chosen column, handling both numeric and string types. The sorted data is exported using a recursive CSV export function. This study also measures system performance (CPU and disk usage) to compare the computational performance of the two sorting methods.
This project was executed in Python programming by applying doubly linked list approach and Julia programming by applying singly linked list approach within an Ubuntu 25.04 installed on Oracle VirtualBox.

Requirements:
Host Machine: Windows 11
Virtualization Tool: Oracle VirtualBox 7.1.12 (Click here to download)
Guest OS: Ubuntu 25.04 (Click here to download)
IDE: Visual Studio Code
Preferred Programming Language: Python, Julia
Python Libraries: csv, os, time, subprocess, psutil
Julia Libraries: CSV, DataFrames, Dates, Statistics
Dataset: student-data.csv

