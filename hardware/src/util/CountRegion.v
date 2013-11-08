//==============================================================================
//	File:		$URL: svn+ssh://repositorypub@repository.eecs.berkeley.edu/public/Projects/GateLib/trunk/Core/GateCore/Hardware/Counting/CountRegion.v $
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
`include "Const.v"
//==============================================================================

//------------------------------------------------------------------------------
//	Module:		CountRegion
//	Desc:		Uses a highly efficient counter comparison (CountCompare) and
//				a single big register to determine whether the input counter
//				is within a prespecified region.
//	Params:		Width:	Sets the bitwidth of the input
//				Start:	The starting value at which to turn the output on (inclusive)
//				End:	The ending value at which to turn the output off (inclusive)
//	Author:		<a href="http://www.gdgib.com/">Greg Gibeling</a>
//	Version:	$Revision: 26904 $
//------------------------------------------------------------------------------
module	CountRegion(Clock, Reset, Enable, Count, Max, Output);
	//--------------------------------------------------------------------------
	//	Parameters
	//--------------------------------------------------------------------------
	parameter				Width = 				8,
							Start =					9'h000,
							End =					9'h100,
							UseMagnitude =			Width < 4;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Constants
	//--------------------------------------------------------------------------
	`ifdef MACROSAFE
	localparam				EnablePre =				Start > 0,
							EnableActive =			Start != End,
							EnablePost =			End < `pow2(Width);
	`else
	localparam				EnablePre =				1'b1,
							EnableActive =			1'b1,
							EnablePost =			1'b1;
	`endif
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	I/O
	//--------------------------------------------------------------------------
	input					Clock, Reset;
	
	input					Enable;
	input	[Width-1:0]		Count;
	input					Max;
	output					Output;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Comparison Logic
	//--------------------------------------------------------------------------
	generate if (UseMagnitude) begin:MAG
		assign	Output =							(Count >= Start) && (Count < End);
	end else if (EnableActive & (EnablePre | EnablePost)) begin:FSM
		//----------------------------------------------------------------------
		//	Wires
		//----------------------------------------------------------------------
		wire	[2:0]		CurrentState, NextState, DoneState;
		wire				SetOutput, ResetOutput;
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		//	Assigns
		//----------------------------------------------------------------------
		assign	DoneState =							CurrentState & {Max, ResetOutput, SetOutput};
		
		assign	NextState[0] =						EnablePre & (DoneState[2] | (~EnablePost & DoneState[1]));
		assign	NextState[1] =						DoneState[0] | (~EnablePre & (DoneState[2] | (~EnablePost & DoneState[1])));
		assign	NextState[2] =						EnablePost & DoneState[1];
		assign	Output =							CurrentState[1];
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		//	Start Comparator
		//----------------------------------------------------------------------
		if (EnablePre) begin:STARTCMP
			CountCompare #(		.Width(				Width),
								.Compare(			Start-1))
					StartCmp(	.Count(				Count),
								.TerminalCount(		SetOutput));
		end else begin:STARTFIXED
			assign	SetOutput =						Max;
		end
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		//	End Comparator
		//----------------------------------------------------------------------
		if (EnablePost) begin:ENDCMP
			CountCompare #(		.Width(				Width),
								.Compare(			End-1))
					EndCmp(		.Count(				Count),
								.TerminalCount(		ResetOutput));
		end else begin:ENDFIXED
			assign	ResetOutput =					Max;
		end
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		//	State Register
		//----------------------------------------------------------------------
		Register	#(			.Width(				3),
								.ResetValue(		EnablePre ? 3'b001 : 3'b010))
					State(		.Clock(				Clock),
								.Reset(				Reset),
								.Set(				1'b0),
								.Enable(			Enable & (|DoneState)),
								.In(				NextState),
								.Out(				CurrentState));
		//----------------------------------------------------------------------
	end else if (EnableActive) begin:SIMPLE
		assign Output =								1'b1;
	end else begin:INACTIVE
		assign Output =								1'b0;
	end endgenerate
	//--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
