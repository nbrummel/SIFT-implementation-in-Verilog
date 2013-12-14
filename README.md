
<h1>
<b>Project Report</b>
==============
</h1>

<h2>abstract</h2>
<p>
This paper discusses our process for adding a hardware acceleration module to the Scale Invariant Feature Transform (SIFT) algorithm. When running an algorithm often about 90 percent of program runtime energy is consumed by 10 percent of the code. These parts of the code are frequently data processing intensive, and by adding custom hardware to speed up these sections, the overall algorithm speeds up drastically. 
</p><p>	
The SIFT algorithm is a computer vision algorithm used to detect and describe local features in images. We described several hardware modules using Verilog to aid in expediting the process of this algorithm. The first major module discussed in this paper is the SRAM Arbiter, which efficiently services two write ports and two read ports that are trying to connect to an external SRAM module. The second major module discussed is the Difference of Gaussians calculation module, which takes in a byte stream of pixel data, down samples it to a more manageable size (due to on-board FPGA memory constraints), runs a Difference of Gaussians calculation, and up samples it to the original size again.
</p><a href=https://drive.google.com/file/d/0Bz6DRVnxP1BUUmF6TXc5TXp1azg/edit?usp=sharing> The REPORT </a>


Logins
===

Nathan Brummel, cs150-ba

Tyler McAtee, cs150-ar

Checkpoint Progress
===
<h3>
Checkpoint 1:
</h3>
<a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/project/checkpoint1.pdf> Checkpoint 1 PDF</a>
PatternGenerator.v and PatternGeneratorTest.v up to date and working
All tests for PatternGenerator in sim folder working

<h3>
Checkpoint 2:
</h3>
<a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/project/checkpoint2.pdf> Checkpoint 2 PDF pdf</a>
Finished and working. 

<h3>
Checkpoint 3:
</h3>
<a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/project/checkpoint3.pdf> Checkpoint 3 PDF pdf</a>
Finished the block diagrams.
Working.
<p align="center"><img title="Final Project" src="https://raw.github.com/EECS150/fa13_team06/master/Proposal/PiIthGW.png?token=5061271__eyJzY29wZSI6IlJhd0Jsb2I6RUVDUzE1MC9mYTEzX3RlYW0wNi9tYXN0ZXIvUHJvcG9zYWwvUGlJdGhHVy5wbmciLCJleHBpcmVzIjoxMzg1MDAyODU4fQ%3D%3D--3de2c89a4f562c9efbbbc10e14edf808a4cef721"/></p>
<h3>
Checkpoint 4:
</h3>
<a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/project/checkpoint4-1.pdf> Checkpoint 4 PDF pdf</a>
Working. DOG and Gaussian filters working.  Can switch between all views.  Can easily be implimented to work with entire octive and SIFT algorithm. 

Rules
===
Please keep commits to a minimum and ONLY commit working compilable code. 
Please write detailed and useful commit messages that explain everything that is included in the new working update.
