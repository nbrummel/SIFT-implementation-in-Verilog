//==============================================================================
//	File:		$URL: svn+ssh://repositorypub@repository.eecs.berkeley.edu/public/Projects/GateLib/trunk/Platforms/Virtex/Hardware/IO/SDR2DDR.v $
//	Version:	$Revision: 27067 $
//	Author:		Ilia Lebedev
//				Greg Gibeling
//	Copyright:	Copyright 2005-2010 UC Berkeley
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
//	Includes
//==============================================================================
`include "Const.v"
//==============================================================================

//------------------------------------------------------------------------------
//	Module:		SDR2DDR Mux
//	Desc:		...
//	Params:		...
//	Author:		Ilia Lebedev
//				<a href="http://www.gdgib.com/">Greg Gibeling</a>
//	Version:	$Revision: 27067 $
//------------------------------------------------------------------------------
module	SDR2DDR(Clock, Reset, Set, In, Out);
	//--------------------------------------------------------------------------
	//	Per-Instance Constants
	//--------------------------------------------------------------------------
	parameter				DDRWidth =				1,
							Interleave =			1;	// If 1, posedge bits are taken from odd-numbered bits of In. If 0, posedge bits are taken from In[DDRWidth-1:0]
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Constants
	//--------------------------------------------------------------------------
	localparam				SDRWidth =				2*DDRWidth;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	I/O
	//--------------------------------------------------------------------------
	input					Clock, Reset, Set;
	input	[SDRWidth-1:0]	In;
	output	[DDRWidth-1:0]	Out;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Wires
	//--------------------------------------------------------------------------
	genvar					i;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	DDR Mux
	//--------------------------------------------------------------------------
	generate for (i = 0; i < DDRWidth; i = i+1) begin : bit
			// NOTE:	Data is transmitted with a 180-degree phase shift! DDR Data *must* be deskewed before use, or the receiver must listen on negative edges.
			ODDR	#(			.DDR_CLK_EDGE(		"SAME_EDGE"))	// "OPPOSITE_EDGE" or "SAME_EDGE" are the options, but we use "SAME_EDGE"
					ODDR(		.Q(					Out[i]),		// 1-bit DDR output
								.C(					Clock),			// 1-bit clock input
								.CE(				1'b1),			// 1-bit clock enable input
								.D1(				(Interleave ? In[2*i] : In[i])),				// 1-bit data input (1st edge - negative)
								.D2(				(Interleave ? In[(2*i)+1] : In[DDRWidth+i])),	// 1-bit data input (2nd edge - positive)
								.R(					Reset),			// 1-bit reset
								.S(					Set));			// 1-bit set
		end
	endgenerate
	//--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
