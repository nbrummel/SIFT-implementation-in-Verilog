//==============================================================================
//	File:		$URL: svn+ssh://repositorypub@repository.eecs.berkeley.edu/public/Projects/GateLib/trunk/Firmware/Video/Hardware/Base/PixelCounter.v $
//	Version:	$Revision: 26904 $
//	Author:		Greg Gibeling (http://www.gdgib.com/)
//				Ilia Lebedev
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
`ifndef MACROSAFE
  `define MACROSAFE 
`endif// required to get this to compile...
`include "Const.v"
//==============================================================================

//------------------------------------------------------------------------------
//	Module:		PixelCounter
//	Desc:		...
//	Params:		...
//	Author:		<a href="http://www.gdgib.com/">Greg Gibeling</a>
//	Version:	$Revision: 26904 $
//------------------------------------------------------------------------------
module	PixelCounter(Clock, Reset, PixelX, PixelY, PixelActive, PixelHSync, PixelVSync, PixelIncrement);
	//--------------------------------------------------------------------------
	//	Per-Instance Constants
	//--------------------------------------------------------------------------
	parameter				Width =					640,
							Height =				480,
							FrontH =				0,
							PulseH =				0,
							BackH =					0,
							FrontV =				0,
							PulseV =				0,
							BackV =					0;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Constants
	//--------------------------------------------------------------------------
	`ifdef MACROSAFE
	localparam				ActiveH =				Width - FrontH - PulseH - BackH,
							ActiveV =				Height - FrontV - PulseV - BackV,
							XWidth =				`log2(Width),
							YWidth =				`log2(Height);
	`endif
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	I/O
	//--------------------------------------------------------------------------
	input					Clock, Reset;
	output	[XWidth-1:0]	PixelX;
	output	[YWidth-1:0]	PixelY;
	output					PixelActive, PixelHSync, PixelVSync;
	input					PixelIncrement;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Wires
	//--------------------------------------------------------------------------
	wire					XReset, YReset;
	wire					XMax, YMax;
	wire					XActive, YActive;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Assigns
	//--------------------------------------------------------------------------
	assign	XReset =								(XMax & PixelIncrement);
	assign	YReset =								(YMax & XMax & PixelIncrement);
	assign	PixelActive =							XActive & YActive;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	X Counter
	//--------------------------------------------------------------------------
	Counter			XCnt(		.Clock(				Clock),
								.Reset(				Reset | XReset),
								.Set(				1'b0),
								.Load(				1'b0),
								.Enable(			PixelIncrement),
								.In(				{XWidth{1'bx}}),
								.Count(				PixelX));
	defparam		XCnt.Width = 					XWidth;
	CountCompare	XCmp(		.Count(				PixelX),
								.TerminalCount(		XMax));
	defparam		XCmp.Width = 					XWidth;
	defparam		XCmp.Compare =					Width - 1;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Y Counter
	//--------------------------------------------------------------------------
	Counter			YCnt(		.Clock(				Clock),
								.Reset(				Reset | YReset),
								.Set(				1'b0),
								.Load(				1'b0),
								.Enable(			XMax & PixelIncrement),
								.In(				{YWidth{1'bx}}),
								.Count(				PixelY));
	defparam		YCnt.Width = 					YWidth;
	CountCompare	YCmp(		.Count(				PixelY),
								.TerminalCount(		YMax));
	defparam		YCmp.Width = 					YWidth;
	defparam		YCmp.Compare =					Height - 1;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Region Comparators
	//--------------------------------------------------------------------------
	CountRegion #(
    .Width(XWidth),
    .Start(0),
    .End(ActiveH))
  RgnAX(.Clock(Clock),
    .Reset(Reset),
    .Enable(PixelIncrement),
    .Count(PixelX),
    .Max(XReset),
    .Output(XActive));
	
  CountRegion	#(
    .Width(YWidth),
    .Start(0),
    .End(ActiveV))
  RgnAY(.Clock(Clock),
    .Reset(Reset),
    .Enable(XMax & PixelIncrement),
    .Count(PixelY),
    .Max(YReset),
    .Output(YActive));
	
  CountRegion	#(
    .Width(XWidth),
    .Start(ActiveH+FrontH),
    .End(ActiveH+FrontH+PulseH)) 
  RgnHS(
    .Clock(Clock),
    .Reset(Reset),
    .Enable(PixelIncrement),
    .Count(PixelX),
    .Max(XReset),
    .Output(PixelHSync));
	
  CountRegion	#(
    .Width(YWidth),
    .Start(ActiveV+FrontV),
    .End(ActiveV+FrontV+PulseV))
  RgnVS(
    .Clock(Clock),
    .Reset(Reset),
    .Enable(XMax & PixelIncrement),
    .Count(PixelY),
    .Max(YReset),
    .Output(PixelVSync));
	//--------------------------------------------------------------------------
endmodule	
//------------------------------------------------------------------------------
