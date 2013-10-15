//==============================================================================
//	File:		$URL: svn+ssh://repositorypub@repository.eecs.berkeley.edu/public/Projects/GateLib/branches/dev/Core/GateCore/Hardware/Library/EdgeDetect.v $
//	Version:	$Revision: 17689 $
//	Author:		Greg Gibeling (http://gdgib.gotdns.com/~gdgib/)
//	Copyright:	Copyright 2003-2008 UC Berkeley
//==============================================================================

//==============================================================================
//	Section:	License
//==============================================================================
//	Copyright (c) 2003-2008, Regents of the University of California
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

//------------------------------------------------------------------------------
//	Module:		EdgeDetect
//	Desc:		A simple parameterized, shift-register based edge detector.
//				Note this module is fully moore-tyle, the output is isolated
//				from the input by a single flip-flop.
//	Params:		Width:		The number of samples of the input signal to examine
//				UpWidth:	The number of consecutive high samples which must
//							appear before the edge is signaled (assuming
//							posedge detection).
//				Type:	number	type
//						0	posedge
//						1	negedge
//						2	both
//	Author:		<a href="http://gdgib.gotdns.com/~gdgib/">Greg Gibeling</a>
//	Version:	$Revision: 17689 $
//------------------------------------------------------------------------------
module EdgeDetect(Clock, Reset, Enable, In, Out);
	//--------------------------------------------------------------------------
	//	Parameters
	//--------------------------------------------------------------------------
	parameter				Width = 				3,
							UpWidth = 				2,
							Type =					0,
							AsyncReset =			0;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	I/O
	//--------------------------------------------------------------------------
	input					Clock, Reset, Enable;
	input					In;
	output reg				Out;
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Wires & Regs
	//--------------------------------------------------------------------------
	wire	[Width-1:0]		Q;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Output Decoder
	//--------------------------------------------------------------------------
	always @ (Q) begin
		case (Type)
			0:	Out =								(~|(Q[Width-1:UpWidth])) & (&(Q[UpWidth-1:0]));
			1:	Out =								(&(Q[Width-1:UpWidth])) & (~|(Q[UpWidth-1:0]));
			2:	Out =								((~|(Q[Width-1:UpWidth])) | (&(Q[Width-1:UpWidth]))) ^ ((~|(Q[UpWidth-1:0])) | (&(Q[UpWidth-1:0])));
			default: Out =							1'bx;
		endcase
	end
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Shift Register
	//--------------------------------------------------------------------------
	Register		#(			.Width(				Width),
								.AsyncReset(		AsyncReset))
					Register(	.Clock(				Clock),
								.Reset(				Reset),
								.Set(				1'b0),
								.Enable(			Enable),
								.In(				{Q[Width-2:0], In}),
								.Out(				Q));
	//--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------