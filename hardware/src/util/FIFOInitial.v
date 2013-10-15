//==============================================================================
//	File:		$URL: svn+ssh://repositorypub@repository.eecs.berkeley.edu/public/Projects/GateLib/trunk/Gateware/FIFOs/Hardware/Library/FIFOInitial.v $
//	Version:	$Revision: 27065 $
//	Author:		Greg Gibeling (http://www.gdgib.com)
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
`define MACROSAFE // required to get this to compile...
`include "Const.v"
//==============================================================================

//------------------------------------------------------------------------------
//	Module:		FIFOInitial
//	Desc:		Many pieces of hardware require complex, but fixed,
//				initialization sequences and this module exists to fill that
//				need.  On both configuration and reset this module will present
//				at it's FIFO output a stream of values determined by the
//				instantiation parameters.  This output stream will be generated
//				exactly once per reset.
//				
//	Params:		Width:	The width of the data output.
//				Depth:	The number of words in the output sequence.
//				Value:	A concatenation of the words in the output sequence.
//						The most significant word will appear first.
//	Author:		<a href="http://www.gdgib.com/">Greg Gibeling</a>
//	Version:	$Revision: 27065 $
//------------------------------------------------------------------------------
module	FIFOInitial(
			//------------------------------------------------------------------
			//	System I/O
			//------------------------------------------------------------------
			Clock,
			Reset,
			//------------------------------------------------------------------
			
			//------------------------------------------------------------------
			//	Output Interface
			//------------------------------------------------------------------
			Done,
			OutData,
			OutValid,
			OutReady
			//------------------------------------------------------------------
		);
	//--------------------------------------------------------------------------
	//	Parameters
	//--------------------------------------------------------------------------
	parameter		Width =					8,
							Depth =					2,
							Value =					{Width*Depth{1'b0}};
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Constants
	//--------------------------------------------------------------------------
	localparam				ShiftBased =			1;	// Other styles do not work in most synthesis tools yet
	localparam  			A0Width =				`log2(Depth),
							      A1Width =				`log2(Depth+1);
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	System I/O
	//--------------------------------------------------------------------------
	input					Clock, Reset;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Output Interface
	//--------------------------------------------------------------------------
	output					Done;
	output	[Width-1:0]		OutData;
	output					OutValid;
	input					OutReady;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Multiple Implementations
	//--------------------------------------------------------------------------
	generate if (Depth < 2) begin:SIMPLE
		//----------------------------------------------------------------------
		//	Assigns
		//----------------------------------------------------------------------
		assign	OutData =							Value;
		assign	OutValid =							~Done;
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		//	State Register
		//----------------------------------------------------------------------
		Register #( .Width     ( 1     ),
								.Initial   ( 1'b0) )
					SprReg( .Clock (    Clock ),
								 .Reset(			Reset),
								 .Set(				OutValid & OutReady),
								 .Enable(			1'b0),
								 .In(				  1'bx),
								 .Out(				Done));
		//----------------------------------------------------------------------
	end else if (ShiftBased) begin:SHIFT
		//----------------------------------------------------------------------
		//	Wires
		//----------------------------------------------------------------------
		wire				InternalValid, LastValid, SuppressValid;
		wire				Skip;
		wire				OutTransfer;
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		//	Assigns
		//----------------------------------------------------------------------
		assign	Done =								~(InternalValid | SuppressValid);
		assign	OutValid =							InternalValid & ~SuppressValid;
		assign	OutTransfer =						OutReady & OutValid;
		assign	Skip =								Reset ? ~InternalValid : SuppressValid;
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		//	State Register
		//----------------------------------------------------------------------
		Register	#(			.Width(				1),
								.Initial(			1'b0))
					SprReg(		.Clock(				Clock),
								.Reset(				~Reset & ~InternalValid),
								.Set(				Reset & InternalValid & LastValid),
								.Enable(			1'b0),
								.In(				1'bx),
								.Out(				SuppressValid));
		Register	#(			.Width(				1),
								.Initial(			1'b0))
					LstValReg(	.Clock(				Clock),
								.Reset(				1'b0),
								.Set(				1'b0),
								.Enable(			1'b1),
								.In(				InternalValid),
								.Out(				LastValid));
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		//	Core Shift Registers
		//----------------------------------------------------------------------
		ShiftRegister #(		.PWidth(			Width*Depth),
								.SWidth(			Width),
								.Reverse(			0),
								.Initial(			Value),
								.AsyncReset(		0),
								.ResetValue(		{Width*Depth{1'bx}}))
					DataShft(	.Clock(				Clock),
								.Reset(				1'b0),
								.Load(				1'b0),
								.Enable(			(Skip & InternalValid) | OutTransfer),
								.PIn(				{Width*Depth{1'bx}}),
								.SIn(				OutData),
								.POut(				/* Unconnected */),
								.SOut(				OutData));
								
		ShiftRegister #(		.PWidth(			Depth+1),
								.SWidth(			1),
								.Reverse(			0),
								.Initial(			{{Depth{1'b1}}, 1'b0}),
								.AsyncReset(		0),
								.ResetValue(		{Depth{1'bx}}))
					VldShft(	.Clock(				Clock),
								.Reset(				1'b0),
								.Load(				1'b0),
								.Enable(			Skip | OutTransfer),
								.PIn(				{Depth+1{1'bx}}),
								.SIn(				InternalValid),
								.POut(				/* Unconnected */),
								.SOut(				InternalValid));
		//----------------------------------------------------------------------
	end else begin:RAM
		//----------------------------------------------------------------------
		//	Wires
		//----------------------------------------------------------------------
		wire	[A1Width-1:0] Address;
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		//	Assigns
		//----------------------------------------------------------------------
		assign	OutValid =							~Done;
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		//	Counter
		//----------------------------------------------------------------------
		Counter		#(.Width(				A1Width),
								.Initial(			{A1Width{1'b0}}))
					Cnt(	.Clock(				Clock),
								.Reset(				Reset),
								.Set(				  1'b0),
								.Load(				1'b0),
								.Enable(			OutReady & OutValid),
								.In(				{A1Width{1'bx}}),
								.Count(				Address));
		CountCompare #(	.Width(		A1Width),
								.Compare(			Depth))
					Cmp(	.Count(				Address),
								.TerminalCount(		Done));
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		//	Memory
		//----------------------------------------------------------------------
		RAM			#(	.DWidth(			 Width),
								.AWidth(			  A0Width),
								.RLatency(			0),
								.WLatency(			1),
								.NPorts(			  1),
								.WriteMask(			1'b0),
								.EnableInitial(	1),
								.Initial(			Value))
					RAM(	.Clock(				Clock),
								.Reset(				1'b0),
								.Enable(			1'b1),
								.Write(				1'b0),
								.Address(			Address[A0Width-1:0]),
								.DIn(				{Width{1'bx}}),
								.DOut(				OutData));
		//----------------------------------------------------------------------
	end endgenerate
	//--------------------------------------------------------------------------
endmodule	
//------------------------------------------------------------------------------
