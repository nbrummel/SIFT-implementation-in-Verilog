//==============================================================================
//	File:		$URL: svn+ssh://repositorypub@repository.eecs.berkeley.edu/public/Projects/GateLib/trunk/Firmware/Video/Hardware/Firmware/DVI/DVIInitial.v $
//	Version:	$Revision: 26904 $
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
//	Module:		DVIInitial
//	Desc:		This module implements an interface to the Chrontel 7301C 
//				DVI controller. This module exposes a standard Video R/V
//				interface.
//	Parameters:	ClockFreq:		Pixel Clock clock frequency. Used to correctly
//								produce the I2C clock. Resolution-Dependent, see
//								table for detail.
//				I2CRate:		Desired I2C line rate. Used to correctly produce
//								the I2C clock.
//				Width:			Resolution-Dependent, see table for detail.
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
//				The user is responsible for the generation of a pixel clock
//				(Clock) of appropriate frequency. Most monitors allow some
//				leeway in the pixel clock frequency.
//
//	Inputs:		Reset:			System Reset. Re-Initializes the DVI chip
//				Clock:			Pixel clock. The frequency of this clock
//								partially determines the display resolution.
//				Video:			Current pixel color in 24-bit RGB (R8G8B8)
//								format. Blanking is hidden at the level of
//								this interface.
//	CH7301C Physical Interface:	The following signals interface directly
//								with the CH7301C: DVI_D, DVI_DE, DVI_H, DVI_V,
//								DVI_RESET_B, DVI_XCLK_N, DVI_XCLK_P,
//								I2C_SCL_DVI, I2C_SDA_DVI
//	Author:		Ilia Lebedev
//				<a href="http://www.gdgib.com/">Greg Gibeling</a>
//				Kyle Wecker
//	Version:	$Revision: 26904 $
//------------------------------------------------------------------------------
module	DVIInitial(//------------------------------------------------------------------
			//	System I/O
			//------------------------------------------------------------------
			Clock,
			Reset,
			I2C_SCL_DVI,
			I2C_SDA_DVI,
			//------------------------------------------------------------------
			
			//------------------------------------------------------------------
			//	Completed Initialization
			//------------------------------------------------------------------
			InitDone
			//------------------------------------------------------------------
		
		);
	//--------------------------------------------------------------------------
	//	Parameters
	//--------------------------------------------------------------------------
	parameter				ClockFreq =				100000000,
							I2CRate =				100000,
							I2CAddress =			7'h76;
	
	localparam				I2CInitVals =			(ClockFreq < 65000000) ?
														{8'hC0, 8'h09, 8'h08, 8'h16, 8'h60} :
														{8'hC0, 8'h09, 8'h06, 8'h26, 8'hA0} ;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Constants
	//--------------------------------------------------------------------------
	`include "I2CDRAMMaster.constants"
	`include "I2CMaster.constants"
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	System I/O
	//--------------------------------------------------------------------------	
	input					Clock, Reset;
	inout					I2C_SCL_DVI, I2C_SDA_DVI;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Completed Initialization
	//--------------------------------------------------------------------------	
	output					InitDone;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Wire & Regs
	//--------------------------------------------------------------------------
	wire	[7:0]			I2CCommand;
	wire					I2CCommandReady, I2CCommandValid, I2CCommandDone;
	wire	[7:0]			I2CData;
	wire					I2CDataReady, I2CDataValid, I2CDataDone;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Assigns
	//--------------------------------------------------------------------------
	assign	InitDone =		I2CCommandReady & I2CCommandDone & I2CDataDone;
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Initialization Logic
	//--------------------------------------------------------------------------
	/*FIFOInitial		#(			.Width(			1),
								.Depth(			19),
								.Value(			19'b0001000100010001000))
					I2CCmdInit(	.Clock(			Clock),
								.Reset(			Reset),
								.Done(			I2CCommandDone),
								.OutData(		I2CCommand),
								.OutValid(		I2CCommandValid),
								.OutReady(		I2CCommandReady));
	
	FIFOInitial		#(			.Width(			8),
								.Depth(			15),
								.Value(			{{{I2CAddress,1'b0},8'h49, 8'hC0},
												{{I2CAddress,1'b0}, 8'h21, 8'h09},
												{{I2CAddress,1'b0}, 8'h33, 8'h06},	// TODO: Handle the under 65MHz case! (8'h08, 8'h16, 8'h60 for the last three registers)
												{{I2CAddress,1'b0}, 8'h34, 8'h26},
												{{I2CAddress,1'b0}, 8'h36, 8'hA0}}))
					I2CDatInit(	.Clock(			Clock),
								.Reset(			Reset),
								.Done(			I2CDataDone),
								.OutData(		I2CData),
								.OutValid(		I2CDataValid),
								.OutReady(		I2CDataReady));
	
	I2CMaster		#(			.ClockFreq(		ClockFreq),
								.I2CRate(		I2CRate))
					I2CMaster(	.Clock(			Clock),
								.Reset(			Reset),
								.SDA(			I2C_SDA_DVI),
								.SCL(			I2C_SCL_DVI),
								.Command(		I2CCommand ? I2CMCMD_Restart : I2CMCMD_Write),
								.CommandReady(	I2CCommandReady),
								.CommandValid(	I2CCommandValid),
								.DataIn(		I2CData),
								.DataInReady(	I2CDataReady),
								.DataInValid(	I2CDataValid),
								.DataOut(		),
								.DataOutAck(	1'b1),
								.DataOutReady(	1'b1),
								.DataOutValid(	),
								.Ack(			),
								.AckReady(		1'b1),
								.AckValid(		));*/
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	I2C Master
	//--------------------------------------------------------------------------
	
	
	FIFOInitial		#(			.Width(			8),
								.Depth(			5),
								.Value(			{8'h49, 8'h21, 8'h33, 8'h34, 8'h36} ))
					I2CCmdInit(	.Clock(			Clock),
								.Reset(			Reset),
								.Done(			I2CCommandDone),
								.OutData(		I2CCommand),
								.OutValid(		I2CCommandValid),
								.OutReady(		I2CCommandReady));
	
	FIFOInitial		#(			.Width(			8),
								.Depth(			5),
								.Value(			I2CInitVals))
					I2CDatInit(	.Clock(			Clock),
								.Reset(			Reset),
								.Done(			I2CDataDone),
								.OutData(		I2CData),
								.OutValid(		I2CDataValid),
								.OutReady(		I2CDataReady));
	
	I2CDRAMMaster	#(			.ClockFreq(		ClockFreq),
								.I2CRate(		I2CRate),
								.WAWidth(		8),
								.SingleSlave(	1),
								.SlaveAddress(	I2CAddress))
				I2CControl(		.Clock(			Clock),
								.Reset(			Reset),
								.SDA(			I2C_SDA_DVI),
								.SCL(			I2C_SCL_DVI),
								.CommandAddress(I2CCommand),
								.Command(		I2CDCMD_Write),
								.CommandValid(	I2CCommandValid),
								.CommandReady(	I2CCommandReady),
								.DataIn(		I2CData),
								.DataInValid(	I2CDataValid),
								.DataInReady(	I2CDataReady),
								.DataOut(		),
								.DataOutValid(	),
								.DataOutReady(	1'b1));
	//--------------------------------------------------------------------------


	
	
endmodule
//------------------------------------------------------------------------------
