<head>
  <h1>
      Project Report
  </h1>
  <h5>
    <i>
      Nathan Brummel (cs150-ba) & Tyler McAtee (cs150-ar)
    </i>
  </h5>
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
    <li>
      Bonato, V.; Marques, E.; Constantinides, G.A.,
      <br>
       "A Parallel Hardware
      Architecture for Scale and Rotation Invariant Feature Detection,"
      <br>
      Circuits and Systems for Video Technology, IEEE Transactions on ,
      vol.18, no.12, pp.1703,1712, Dec. 2008 
      <br> doi: 10.1109/TCSVT.2008.2004936
        <ul>
          <li><a href="http://cas.ee.ic.ac.uk/people/gac1/pubs/VanderleiTCASVT08.pdf">PDF of paper</a> or <a href="http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=4675857">Link to paper on IEEE</a></li>
        </ul></li>
    <li><a href=http://www.verilog.com>Verilog</li>
    <li><a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/resources/#virtex-5-fpga-documentation>Virtex-5 FPGA Documentation</a></li>
    <li><a href=http://www.xilinx.com/tools/cspro.htm>ChipScope</a></li>
    <li><a href=http://www.mentor.com/products/fpga/model>ModelSim</a></li>
    <li><a href=http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&ved=0CDcQFjAB&url=http%3A%2F%2Fwww.xilinx.com%2Ftraining%2Fdownloads%2Fhow-to-use-the-3-axi-configurations.pptx&ei=h72sUpOaAsH6oASFmoKwCw&usg=AFQjCNHITN9sGdcBJN6cxMPk8MK6Y2RVbQ&sig2=nxVBt5tR3KRZARs2ScqFaw&bvm=bv.57967247,d.cGU>Ready/Valid handshake</a></li>
  </ul>
  <h3 id="protocols-standards">Protocols &amp; Standards</h3>
  <ul>
    <li>IEEE Verilog</li>
    <li><a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/resources/ac97_r23.pdf>AC97 Audio</li>
    <li><a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/resources/I2C_BUS_SPECIFICATION_3.pdf>I2C Bus</li>
    <li><a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/resources/MAX3233E-MAX3235E.pdf>RS-232</li>
  </ul>
  <h2>
    Checkpoint Progress
  </h2>
  <h3>
  Checkpoint 1:
  </h3>
  <a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/project/checkpoint1.pdf> Checkpoint 1 PDF</a>
  <br>
  PatternGenerator.v and PatternGeneratorTest.v up to date and working
  <br>
  All tests for PatternGenerator in sim folder working
  <h3>
  Checkpoint 2:
  </h3>
  <a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/project/checkpoint2.pdf> Checkpoint 2 PDF pdf</a>
  <br>
  Finished and working. 
  
  <h3>
  Checkpoint 3:
  </h3>
  <a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/project/checkpoint3.pdf> Checkpoint 3 PDF pdf</a>
  <br>
  Finished the block diagrams.
  <br>
  Working.
  
  <h3>
  Checkpoint 4:
  </h3>
  <a href=http://www-inst.eecs.berkeley.edu/~cs150/fa13/project/checkpoint4-1.pdf> Checkpoint 4 PDF pdf</a>
  <br>
  Working. DOG and Gaussian filters working.  
  Can switch between all views.  
  SIFT algorithm can easily be implimented to work with entire octave. 
  
</body>  
