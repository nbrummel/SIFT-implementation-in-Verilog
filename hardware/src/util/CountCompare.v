//==============================================================================
//	File:		$URL: svn+ssh://repositorypub@repository.eecs.berkeley.edu/public/Projects/GateLib/trunk/Core/GateCore/Hardware/Counting/CountCompare.v $
//	Version:	$Revision: 26904 $
//	Author:		Greg Gibeling (http://www.gdgib.com/)
//	Copyright:	Copyright 2003-2010 UC Berkeley
//==============================================================================

//==============================================================================
//	Section:	License
//==============================================================================
//	Copyright (c) 2005-2010, Regents of the University of California
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification,
//	are permitted provided that the following conditions are met:
//
//		- Redistributions of source code must retain the above copyright notice,
//			this list of conditions and the following disclaimer.
//		- Redistributions in binary form must reproduce the above copyright
//			notice, this list of conditions and the following disclaimer
//			in the documentation and/or other materials provided with the
//			distribution.
//		- Neither the name of the University of California, Berkeley nor the
//			names of its contributors may be used to endorse or promote
//			products derived from this software without specific prior
//			written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//	ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//==============================================================================

//==============================================================================
//	Section:	Includes
//==============================================================================
`ifndef MACROSAFE `define MACROSAFE `endif// required to get this to compile.
`include "Const.v"
//==============================================================================

//------------------------------------------------------------------------------
//	Module:		CountCompare
//	Desc:		An efficient (=) comparison against a monotonic, binary
//				counter.  This module exploits the fact that we needn't actually
//				check EVERY bit to determine equality.  The output may be true
//				or false for inputs larger than the comparison value.  Here's a
//				truth table:
//				
//				Count input		TerminalCount output
//				< Compare		1'b0
//				== Compare		1'b1
//				> Compare		1'b1 or 1'b0 (can be either for different values)
//
//				This module is designed to be used to reset a counter when that
//				counter hits a certain value.  The output of the counter should
//				be fed to the Count input, and the TerminalCount output can then
//				be used to reset the Counter.
//
//				By using this module the space complexity of the comparator is
//				reduced to the number of 1'b1 bits in Compare
//				(N = PopCount(Compare)), and the time complexity is reduced to
//				O(logD(N)), assuming a d-ary AND reduction tree is synthesized.
//				By comparison a magnitude comparator will generally require
//				a carry propagation operation which takes O(Width) time.  
//	Params:		Width:	Sets the bitwidth of the input
//				Compare:The value to compare against
//	Author:		<a href="http://www.gdgib.com/">Greg Gibeling</a>
//	Version:	$Revision: 26904 $
//------------------------------------------------------------------------------
module	CountCompare(Count, TerminalCount);

	//	Parameters
	parameter				Width = 				8,
						  	Compare =			  	8'hFF;

	//	Constants
	`ifdef MACROSAFE
	localparam				CWidth =			`log2(Compare+1),
							 CWidthCheck =			`max(CWidth,1);
	`endif

	//	I/O
	input	[Width-1:0]		Count;
	output					TerminalCount;
	
	//	Multiple Implementations
	generate if (Width > 1) begin:WIDE
		//	Wires and Regs
		wire	[CWidth-1:0]	CompareWire;
	
		//	Assigns
		assign	CompareWire   = Compare;
		assign	TerminalCount = Compare ? &(Count[CWidthCheck-1:0] | ~CompareWire) : 1'b1;
		
	end else begin:NARROW
		//	Assigns
		assign	TerminalCount =						Count >= Compare;
	end endgenerate
	
	
endmodule
//------------------------------------------------------------------------------
