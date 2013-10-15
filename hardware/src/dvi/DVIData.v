//==============================================================================
//	File:		$URL: svn+ssh://repositorypub@repository.eecs.berkeley.edu/public/Projects/GateLib/trunk/Firmware/Video/Hardware/Firmware/DVI/DVIData.v $
//	Version:	$Revision: 26975 $
//	Author:		Ilia lebedev (ilial@berkeley.edu)
//				Greg Gibeling (http://www.gdgib.com)
//				Kyle Wecker (wecker@berkeley.edu)
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

//------------------------------------------------------------------------------
//	Module:		DVIData
//	Desc:		This module implements an interface to the Chrontel 7301C 
//				DVI controller. I2C initialazation is handled separately.
//	Parameters:	Width:			Resolution-Dependent, see table for detail.
//				FrontH:			Resolution-Dependent, see table for detail.
//				PulseH:			Resolution-Dependent, see table for detail.
//				BackH:			Resolution-Dependent, see table for detail.
//				Height:			Resolution-Dependent, see table for detail.
//				FrontV:			Resolution-Dependent, see table for detail.
//				PulseV:			Resolution-Dependent, see table for detail.
//				BackV:			Resolution-Dependent, see table for detail.
//				ColorFormat:	Integer [0-4]. IDF setting for the CH7301C. See
//								table for detail
//				
//				A few configurations are tabulated below.
//				Resolution				Width	FrontH	PulseH	BackH	Height	FrontV	PulseV	BackV	ClockFreq
//				VGA 640x480,60Hz:		800		16		96		48		525		10		2		33		25175000
//				VESA 800x600,72Hz:		1040	56		120		64		666		37		6		23		50000000
//				VESA 1024x768,70Hz:		1328	24		136		144		806		3		6		29		75000000
//				VESA 1280x1024,60Hz:	1688	48		112		248		1066	1		3		38		108000000
//				VESA 1920x1200,60Hz:	2592	128		208		336		1242	1		3		38		193160000
//				
//				ColorFormat values are detailed below:
//				0,1	-	24-bit RGB triplet.
//				2 -		16-bit RGB (R5-G6-B5) triplet.
//				3 -		15-bit RGB (R5-G5-B5) triplet.
//				4 -		24-bit YCrCb triplet
//				
//				NOTE: Some Chrontel 7301C  features, such as deskewing of the
//				data signals, are not (yet) implemented.
//				TODO: Parameterize color space.
//				Source: http://www.tinyvga.com/vga-timing (timings for
//				various resolutions. More available).
//
//	Inputs:		Reset:			System Reset. Re-Initializes the DVI chip
//				Clock:			Pixel clock. The frequency of this clock
//								partially determines the display resolution.
//				Video:			Current pixel color in 24-bit RGB (R8G8B8)
//								format. Blanking is hidden at the level of
//								this interface.
//	CH7301C Physical Interface:	The following signals interface directly
//								with the CH7301C: DVI_D, DVI_DE, DVI_H, DVI_V,
//								DVI_RESET_B, DVI_XCLK_N, DVI_XCLK_P
//	Author:		Ilia Lebedev
//				<a href="http://www.gdgib.com/">Greg Gibeling</a>
//				Kyle Wecker
//	Version:	$Revision: 26975 $
//------------------------------------------------------------------------------
module	DVIData(
			//------------------------------------------------------------------
			//	System I/O
			//------------------------------------------------------------------
			Clock,
			Reset,
			//------------------------------------------------------------------
			
			//------------------------------------------------------------------
			//	Chrontel 7301C Interface
			//------------------------------------------------------------------
			DVI_D,
			DVI_DE,
			DVI_H,
			DVI_V,
			DVI_RESET_B,
			DVI_XCLK_N,
			DVI_XCLK_P,
			//------------------------------------------------------------------
			
			//------------------------------------------------------------------
			//	Pixel Source
			//------------------------------------------------------------------
			Video,
			VideoReady,
			VideoValid
			//------------------------------------------------------------------
		);
	//--------------------------------------------------------------------------
	//	Parameters
	//--------------------------------------------------------------------------
	parameter				Width =					1328,
							FrontH =				24,
							PulseH =				136,
							BackH =					144,
							Height =				806,
							FrontV =				3,
							PulseV =				6,
							BackV =					29;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	System I/O
	//--------------------------------------------------------------------------	
	input					Clock, Reset;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Chrontel 7301C Interface
	//--------------------------------------------------------------------------
	output	[11:0]			DVI_D;
	output					DVI_DE, DVI_H, DVI_V, DVI_RESET_B;
	output					DVI_XCLK_N, DVI_XCLK_P;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Pixel Source
	//--------------------------------------------------------------------------
	input	[23:0]			Video;
	output					VideoReady;
	input					VideoValid; // First valid pixel triggers internal counter
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Wire & Regs
	//--------------------------------------------------------------------------
	wire	[7:0]			Red, Green, Blue;
	wire					PixelHSync, PixelVSync, PixelActive;
	wire					PixelIncrement;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Assigns
	//--------------------------------------------------------------------------
	assign	VideoReady =						PixelActive;
	
	assign	{Red, Green, Blue} =				Video;
	assign	DVI_RESET_B =						~Reset;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Error Checking
	//--------------------------------------------------------------------------
	`ifdef MODELSIM
		always @ (posedge Clock) begin
			if (~Reset & VideoReady & ~VideoValid) $display("ERROR[%m @ %t]: DVI detected invalid data, but cannot stall output stream to external hardware!", $time);
		end
	`endif
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	First Valid Pixel Register
	//--------------------------------------------------------------------------
	Register		#(			.Width(			1))
					FVPReg(		.Clock(			Clock),
								.Reset(			Reset),
								.Set(			VideoValid),
								.Enable(		1'b0),
								.In(			1'bx),
								.Out(			PixelIncrement));
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	CH7301C Physical Interface
	//--------------------------------------------------------------------------
	SDR2DDR			#(			.DDRWidth(		2))
					ClockBuf(	.Clock(			Clock),
								.Reset(			1'b0),
								.Set(			1'b0),
								.In(			{1'b0, 1'b1, 1'b1, 1'b0}),		// Posedge: {1'b1, 1'b0}, Negedge: {1'b0, 1'b1} 
								.Out(			{DVI_XCLK_P, DVI_XCLK_N}));
	
	IORegister		#(			.Width(			3))
					SyncBuf(	.Clock(			Clock),
								.Reset(			1'b0),
								.Set(			1'b0),
								.Enable(		1'b1),
								.In(			{PixelHSync, PixelVSync, PixelActive}),
								.Out(			{DVI_H, DVI_V, DVI_DE}));
	
	SDR2DDR			#(			.DDRWidth(		12),
								.Interleave(	0))
					VideoBuf(	.Clock(			Clock),
								.Reset(			~PixelActive),
								.Set(			1'b0),
								.In(			{{Green[3:0], Blue[7:0]}, {Red[7:0], Green[7:4]}}),	// Posedge: {Red[7:0], Green[7:4]}), Negedge: {Green[3:0], Blue[7:0]})
								.Out(			DVI_D));
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Sync Timing Logic
	//--------------------------------------------------------------------------
	PixelCounter	#(			.Width(			Width),		// total line width
								.Height(		Height),	// total frame height
								.FrontH(		FrontH),
								.PulseH(		PulseH),
								.BackH(			BackH),
								.FrontV(		FrontV),
								.PulseV(		PulseV),
								.BackV(			BackV))							
					PixCnt(		.Clock(			Clock),
								.Reset(			Reset),
								.PixelX(		/* Unconnected */),
								.PixelY(		/* Unconnected */),
								.PixelActive(	PixelActive),
								.PixelHSync(	PixelHSync),
								.PixelVSync(	PixelVSync),
								.PixelIncrement(VideoValid | PixelIncrement));
	//--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
