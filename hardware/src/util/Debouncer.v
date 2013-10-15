//==============================================================================
//	File:		$URL: svn+ssh://repositorypub@repository.eecs.berkeley.edu/public/Projects/GateLib/branches/dev/Core/GateCore/Hardware/Library/Debouncer.v $
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

//==============================================================================
//	Section:	Includes
//==============================================================================
`include "Const.v"
//==============================================================================

//------------------------------------------------------------------------------
//	Module:		Debouncer
//	Desc:		A hysteresis loop based debouncer.  This module will ensure that
//				a noisy signal is at least somewhat clean before passing it back
//				out.  It provides the digital equivalent of inertia...
//
//	Params:		Width:		This is the width of the counter core of the
//							debouncer which will require 2^width cycles for the
//							output to change, assuming no bouncing.
//				SimWidth:	This is the value used instead of Width during
//							simulation.
//				Continuous:	
//				AsyncReset: Make the reset input an asynchronous one
//	Author:		<a href="http://gdgib.gotdns.com/~gdgib/">Greg Gibeling</a>
//	Version:	$Revision: 17689 $
//------------------------------------------------------------------------------
module	Debouncer(Clock, Reset, Enable, In, Out, Half);
	//--------------------------------------------------------------------------
	//	Parameters
	//--------------------------------------------------------------------------
	parameter				Width =					16,
							SimWidth =				4,
							Continuous =			0,
							AsyncReset =			0;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Constants
	//--------------------------------------------------------------------------
	`ifdef SIMULATION
	localparam				XWidth =				SimWidth;
	`else
	localparam				XWidth =				Width;
	`endif
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	I/O
	//--------------------------------------------------------------------------
	input					Clock, Reset, Enable;
	input					In;
	output					Out;
	output					Half;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Wires & Regs
	//--------------------------------------------------------------------------
	reg		[XWidth-1:0]	NextCount;
	wire	[XWidth-1:0]	Count;
	
	reg						NextOut;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Assigns
	//--------------------------------------------------------------------------
	assign	Half =									Count[XWidth-1];
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Limited Up/Down Counter
	//--------------------------------------------------------------------------
	always @ (*) begin
		if (Continuous ? Out : 1'b0) NextCount =	0;
		else if (In & (~&Count)) NextCount =		Count + 1;
		else if (~In & (|Count)) NextCount =		Count - 1;
		else NextCount =							Count;
	end
	
	Register		#(			.Width(				XWidth),
								.AsyncReset(		AsyncReset),
								.Initial(			0))
					CntReg(		.Clock(				Clock),
								.Reset(				Reset),
								.Set(				1'b0),
								.Enable(			Enable),
								.In(				NextCount),
								.Out(				Count));
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Hysteresis/Limit Detector
	//--------------------------------------------------------------------------
	always @ (*) begin
		if (&Count) NextOut =						1;
		else if (~|Count) NextOut =					0;
		else NextOut =								Out;
	end
	
	Register		#(			.Width(				1),
								.AsyncReset(		AsyncReset))
					OutReg(		.Clock(				Clock),
								.Reset(				Reset),
								.Set(				1'b0),
								.Enable(			Enable),
								.In(				NextOut),
								.Out(				Out));
	//--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------