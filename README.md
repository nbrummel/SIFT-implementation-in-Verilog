<head>
  <h1>
    <b>
      Project Report
    </b>
  </h1>
</head>  

<body>
  <h2>
    abstract
  </h2>
  
  <p>
    This paper discusses our process for adding a hardware acceleration module to the Scale Invariant Feature Transform    (SIFT) algorithm. When running an algorithm often about 90 percent of program runtime energy is consumed by 10         percent of the code. These parts of the code are frequently data processing intensive, and by adding custom hardware   to speed up these sections, the overall algorithm speeds up drastically. 
  </p>
  
  <p>	
  The SIFT algorithm is a computer vision algorithm used to detect and describe local features in images. We described several hardware modules using Verilog to aid in expediting the process of this algorithm. The first major module discussed in this paper is the SRAM Arbiter, which efficiently services two write ports and two read ports that aretrying to connect to an external SRAM module. The second major module discussed is the Difference of Gaussians calculation module, which takes in a byte stream of pixel data, down samples it to a more manageable size (due to on-board FPGA memory constraints), runs a Difference of Gaussians calculation, and up samples it to the original size again.
  </p>  
  
  <a href=https://drive.google.com/file/d/0Bz6DRVnxP1BUUmF6TXc5TXp1azg/edit?usp=sharing> 
    The REPORT 
  </a>
  
  <h3>
    Tools Used
  </h3>
  
  <ul>
    <li><a href=http://www.verilog.com>Verilog</li>
    <li><a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/resources/#virtex-5-fpga-documentation>Virtex-5 FPGA Documentation</a></li>
    <li><a href="ChipScope.pdf">ChipScope</a></li>
    <li><a href="ModelSim.pdf">ModelSim</a></li>
    <li><a href="ReadyValidInterface.pdf">Ready/Valid handshake</a></li>
  </ul>
  <h3 id="protocols-standards">Protocols &amp; Standards</h3>
  <ul>
    <li><a href="http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&amp;arnumber=1620780">IEEE Verilog</a></li>
    <li><a href="ac97_r23.pdf">AC97 Audio</a></li>
    <li><a href="I2C_BUS_SPECIFICATION_3.pdf">I2C Bus</a></li>
    <li><a href="MAX3233E-MAX3235E.pdf">RS-232</a></li>
  </ul>
  <h4>
  Logins
  </h4>
  <p>
  Nathan Brummel, cs150-ba
  <br>
  Tyler McAtee, cs150-ar
  </p>
  Checkpoint Progress
  ===
  <h3>
  Checkpoint 1:
  </h3>
  <a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/project/checkpoint1.pdf> Checkpoint 1 PDF</a>
  <p>
  PatternGenerator.v and PatternGeneratorTest.v up to date and working
  <br>
  All tests for PatternGenerator in sim folder working
  </p>
  <h3>
  Checkpoint 2:
  </h3>
  <a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/project/checkpoint2.pdf> Checkpoint 2 PDF pdf</a>
  
  <p>
  Finished and working. 
  </p>
  
  <h3>
  Checkpoint 3:
  </h3>
  <a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/project/checkpoint3.pdf> Checkpoint 3 PDF pdf</a>
  <p>
  Finished the block diagrams.
  Working.
  </p>
  
  <h3>
  Checkpoint 4:
  </h3>
  <a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/project/checkpoint4-1.pdf> Checkpoint 4 PDF pdf</a>
  <p>
  Working. DOG and Gaussian filters working.  
  <br>Can switch between all views.  
  <br>Can easily be implimented to work with entire octive and SIFT algorithm. 
  </p>
  
  Rules
  ===
  <p>
  Please keep commits to a minimum and ONLY commit working compilable code. 
  <br>
  Please write detailed and useful commit messages that explain everything that is included in the new working update.
  </p>
</body>  
