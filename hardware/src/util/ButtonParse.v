//==============================================================================
//	File:		$URL: svn+ssh://repositorypub@repository.eecs.berkeley.edu/public/Projects/GateLib/branches/dev/Core/GateCore/Hardware/Library/ButtonParse.v $
//	Version:	$Revision: 17478 $
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
//	Module:		ButtonParse
//	Desc:		This is a highly parameterized module which can be used to clean
//				up groups of related buttons used for human input.
//
//				This module essentially connects an edge detector after a
//				debouncer, one per-bit in the input bus.  However, by using a
//				"Half" bus from the debouncers this module can be used to
//				decode presses from combinations of buttons as long as the
//				original buttons and the derived "buttons" are all fed in as
//				separate input bits.  Thus the input might be something like
//				{Button[0] & Button[1], Button[1], Button[0]} in order to cause
//				different outputs when one, the other or both buttons are
//				pressed.
//
//				The output from this module is one-hot when the obvious parameter
//				is 1.
//
//	Params:		Width:		This sets the bitwidth of the input and output
//							busses.  Note that the signals are assumed to be
//							related as described above.
//				EdgeWidth:	The total number of bits the edge detectors should
//							look at to determine if an edge exists.
//				WdgeUpWidth:The number of edge bits which must be high to signal
//							an edge.  Obviously must be less than EdgeWidth.
//				BebWidth:	This is the width of the counter core of the
//							debouncer, which will require 2^width cycles for the
//							output to change, assuming no bounces on the input.
//				DebSimWidth:This is the value used instead of DebWidth for
//							simulation.
//				EdgeType:	number	type
//							0	posedge
//							1	negedge
//							2	both
//							3	neither
//				Related:	Binary flag specifying if the input signals are
//							related buttons (when 1) or if they should be
//							treated completely separately (when 0).
//				EnableEdge:	Forcibly enable the edge detectors at all times.
//							The debouncers will still use the Enable input.
//				Continuous:	
//				OutWidth:	The width of the output pulses to generate
//				AsyncReset: Make the reset input an asynchronous one
//	Author:		<a href="http://gdgib.gotdns.com/~gdgib/">Greg Gibeling</a>
//	Version:	$Revision: 17478 $
//------------------------------------------------------------------------------
module ButtonParse(Clock, Reset, Enable, In, Out);
	//--------------------------------------------------------------------------
	//	Parameters
	//--------------------------------------------------------------------------
	parameter				Width =					1,
							EdgeWidth =				3,
							EdgeUpWidth =			2,
							DebWidth =				16,
							DebSimWidth =			4,
							EdgeType =				0,
							Related =				1,
							EnableEdge =			0,
							Continuous =			0,
							EdgeOutWidth =			1,
							AsyncReset =			0;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	I/O
	//--------------------------------------------------------------------------
	input					Clock, Reset, Enable;
	input	[Width-1:0]		In;
	output	[Width-1:0]		Out;
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Wires
	//--------------------------------------------------------------------------
	wire	[Width-1:0]		Debounced;	// The debounced versions of the inputs
	wire	[Width-1:0]		Edges;		// The edge detected versions of the inputs
	wire	[Width-1:0]		Half;		// Used to ensure the output is one-hot, even at human perception times...
	
	genvar					i;
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Generated Instantiations
	//		Actually instantiate a debouncer and edge
	//		detector for each bit.  Notice the "Half" signal
	//		and how the constants will be optimized.
	//--------------------------------------------------------------------------
	generate for (i = 0; i < Width; i = i + 1) begin:BP
			Debouncer #(		.Width(				DebWidth),
								.SimWidth(			DebSimWidth),
								.Continuous(		Continuous),
								.AsyncReset(		AsyncReset))
					D(			.Clock(				Clock),
								.Reset(				Reset),
								.Enable(			Enable),
								.In(				In[i] & (Related ? ~|(Half & ~(1 << i)) : 1'b1)), // The complex masking removes the potential loop between half and the input
								.Out(				Debounced[i]),
								.Half(				Half[i]));
			if (EdgeType != 3) begin:ED
				EdgeDetect #(	.Width(				EdgeWidth),
								.UpWidth(			EdgeUpWidth),
								.Type(				EdgeType),
								.AsyncReset(		AsyncReset))
						ED(		.Clock(				Clock),
								.Reset(				Reset),
								.Enable(			EnableEdge ? 1'b1 : Enable),
								.In(				Debounced[i]),
								.Out(				Edges[i]));
			end else begin:NOED
				assign	Edges[i] =					Debounced[i];
			end
			if (EdgeOutWidth > 1) begin:PE
				PulseExpander #(.Width(				EdgeOutWidth),
								.AsyncReset(		AsyncReset))
						PE(		.Clock(				Clock),
								.Reset(				Reset),
								.In(				Edges[i]),
								.Out(				Out[i]));
			end else begin:NOPE
				assign Out[i] =						Edges[i];
			end
		end
	endgenerate
	//--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------