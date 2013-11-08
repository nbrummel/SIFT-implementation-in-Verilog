//==============================================================================
//	File:		$URL: svn+ssh://repositorypub@repository.eecs.berkeley.edu/public/Projects/GateLib/trunk/Firmware/I2C/Hardware/Physical/I2CMaster.v $
//	Version:	$Revision: 27062 $
//	Author:		Greg Gibeling (http://www.gdgib.com/)
//				Ilia Lebedev
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
`ifndef MACROSAFE
  `define MACROSAFE 
`endif // required to get this to compile...
`include "Const.v"
//==============================================================================

//------------------------------------------------------------------------------
//	Module:		I2CMaster
//	Desc:		This module implements the functionality of an I2C bus master at
//				a low level.  As an I/O firmware module it cannot entirely
//				respect the FIFO interface specification, see the individual
//				control signals for more information.
//	Params:		ClockFreq:	The frequency of the system clock
//				I2CRate:	Data rate to be used on the I2C
//							bus (100k default, 400k fast)
//	Author:		<a href="http://www.gdgib.com/">Greg Gibeling</a>
//				Ilia Lebedev
//	Version:	$Revision: 27062 $
//------------------------------------------------------------------------------
module	I2CMaster(
			//------------------------------------------------------------------
			//	System Inputs
			//------------------------------------------------------------------
			Clock,
			Reset,
			//------------------------------------------------------------------
			
			//------------------------------------------------------------------
			//	I2C Interface
			//------------------------------------------------------------------
			SDA,
			SCL,
			//------------------------------------------------------------------
			
			//------------------------------------------------------------------
			//	FPGA-Side Interface
			//------------------------------------------------------------------
			Command,
			CommandValid,
			CommandReady,	// Pulsed, not class1
			
			DataIn,
			DataInValid,
			DataInReady,	// Pulsed, not class1
			
			DataOut,
			DataOutAck,
			DataOutValid,	// Pulsed, not class1
			DataOutReady,	// Used to control transfer of DataOutAck only
			
			Ack,
			AckValid,		// Pulsed, not class1
			AckReady		// Ignored
			//------------------------------------------------------------------
		);
	//--------------------------------------------------------------------------
	//	Parameters
	//--------------------------------------------------------------------------
	parameter				ClockFreq =				100000000,
							I2CRate =				400000;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Constants
	//--------------------------------------------------------------------------
	`ifdef MACROSAFE
		localparam			CycleMax =				`divceil(ClockFreq, I2CRate * 4),
							CycleWidth =			`log2(CycleMax);
	`endif
	`include "I2CMaster.constants"
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	System Inputs
	//--------------------------------------------------------------------------
	input					Clock, Reset;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	I2C Interface
	//--------------------------------------------------------------------------
	inout					SDA 					/* synthesis xc_pullup = 1 */;
	inout					SCL 					/* synthesis xc_pullup = 1 */;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	FPGA-Side Interface
	//--------------------------------------------------------------------------
	input	[I2CMCMD_CWidth-1:0] Command;
	input					CommandValid;
	output reg				CommandReady;
	
	input	[7:0]			DataIn;
	input					DataInValid;
	output reg				DataInReady;
	
	output	[7:0]			DataOut;
	input					DataOutAck;
	output reg				DataOutValid;
	input					DataOutReady;
	
	output reg				Ack;
	output reg				AckValid;
	input					AckReady;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	State Encoding
	//--------------------------------------------------------------------------
	localparam				STATE_NOP =				3'd0, 
							STATE_Start =			3'd1,
							STATE_Write =			3'd2,
							STATE_CheckAck =		3'd3,
							STATE_Read =			3'd4,
							STATE_SendAck =			3'd5,
							STATE_Stop =			3'd6,
							STATE_Restart =			3'd7,
							STATE_X =				3'bxxx;
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Wires and Regs
	//--------------------------------------------------------------------------
	wire	[2:0]			SCLLast;
	
	wire					SData, SDataEnable;
	
	wire					LongOp, StartStopOp, DisableSCLOp, LoadOp, DoneOp, NextOp;
	wire					SDAOutShift, SDAStartStopShift, SDAInShift, SDAShift, BitCount, BitReset;
	
	wire					CycleCountReset, CycleCountEnable, CycleCountEnd;
	wire	[CycleWidth-1:0] CycleCount;
	wire	[1:0]			Phase;
	wire	[2:0]			Bit;
	
	reg		[2:0]			CurrentState, NextState, LastState;
	
	reg		[7:0]			SDataSequence;
	reg						SDataEnableNext;
	
	wire					SendAck;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Debug Printouts
	//--------------------------------------------------------------------------
	/*always @ (posedge Clock) begin
		if (CommandValid & CommandReady) $display("DEBUG[%m @ %t]: Command: 0x%X", $time, Command);
		if (DataInValid & DataInReady) $display("DEBUG[%m @ %t]: DataIn: 0x%X", $time, DataIn);
		if (DataOutValid & DataOutReady) $display("DEBUG[%m @ %t]: DataOut: 0x%X", $time, DataOut);
		if (AckValid & AckReady) $display("DEBUG[%m @ %t]: Ack: 0x%X", $time, Ack);
	end*/
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Assigns and Decodes
	//--------------------------------------------------------------------------
	assign	SCL =									(Phase[1] | DisableSCLOp) ? 1'bz : 1'b0;
	assign	SDA =									SDataEnable ? SData : 1'bz;
	
	assign	LongOp =								(CurrentState == STATE_Read) | (CurrentState == STATE_Write);
	assign	StartStopOp =							(LastState == STATE_Start) | (LastState == STATE_Stop) | (LastState == STATE_Restart);
	assign	DisableSCLOp =							(CurrentState == STATE_NOP) | (CurrentState == STATE_Start);
	assign	LoadOp =								&Bit & (Phase == 2'b00) & CycleCountEnd;
	assign	DoneOp =								&Bit & SCLLast[0] & ~SCLLast[1];
	assign	NextOp =								((CurrentState == STATE_NOP) & ~StartStopOp) | (&Bit & SCLLast[1] & ~SCLLast[2]);
	
	assign	SDAOutShift =							(Phase == 2'b00) & CycleCountEnd;
	assign	SDAStartStopShift =						StartStopOp & (&Bit) & (Phase == 2'b10) & CycleCountEnd;
	assign	SDAInShift =							(Phase[1] & ~SCLLast[0]);
	assign	SDAShift =								SDataEnable ? (SDAOutShift | SDAStartStopShift) : SDAInShift;
	assign	BitCount =								(SDataEnable ? SDAOutShift : SDAInShift) | LoadOp;
	assign	BitReset =								(LoadOp & (CurrentState == STATE_Read)) | (BitCount & ~LongOp);
	
	assign	CycleCountReset =						~Phase[1] & SCLLast & Phase[1];
	assign	CycleCountEnable =						1'b1;
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Pullups
	//--------------------------------------------------------------------------
	// synthesis translate_off
		pullup		pscl(							SCL);
		pullup		psda(							SDA);
	// synthesis translate_on
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Last Value/Delay Registers
	//--------------------------------------------------------------------------
	ShiftRegister	#(			.PWidth(			3),
								.SWidth(			1))
					SCLShft(	.PIn(				3'b111),
								.SIn(				Phase[1]),
								.POut(				SCLLast),
								.SOut(				/* Unconnected */),
								.Load(				Reset),
								.Enable(			1'b1),
								.Clock(				Clock),
								.Reset(				1'b0));

	Register		#(			.Width(				1))
					SDEReg(		.Clock(				Clock),
								.Reset(				Reset),
								.Set(				1'b0),
								.Enable(			LoadOp),
								.In(				SDataEnableNext),
								.Out(				SDataEnable));
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Send Ack Register
	//--------------------------------------------------------------------------
	Register		#(			.Width(				1))
					SAReg(		.Clock(				Clock),
								.Reset(				Reset | (DoneOp & (CurrentState == STATE_SendAck))),
								.Set(				1'b0),
								.Enable(			DataOutValid & DataOutReady),
								.In(				DataOutAck),
								.Out(				SendAck));
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Serial Data Shift Register
	//--------------------------------------------------------------------------
	ShiftRegister	#(			.PWidth(			8),
								.SWidth(			1))
					SDAShft(	.PIn(				SDataSequence),
								.SIn(				SDA),
								.POut(				DataOut),
								.SOut(				SData),
								.Load(				LoadOp),
								.Enable(			SDAShift),
								.Clock(				Clock),
								.Reset(				Reset));
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Cycle Counter
	//--------------------------------------------------------------------------
	Counter			#(			.Width(				CycleWidth))
					CycCnt(		.Clock(				Clock),
								.Reset(				Reset | CycleCountReset | (CycleCountEnable & CycleCountEnd)),
								.Set(				1'b0),
								.Load(				1'b0),
								.Enable(			CycleCountEnable),
								.In(				{CycleWidth{1'bx}}),
								.Count(				CycleCount));
	CountCompare	#(			.Width(				CycleWidth),
								.Compare(			CycleMax-1))
					CycCmp(		.Count(				CycleCount),
								.TerminalCount(		CycleCountEnd));
	Counter			#(			.Width(				2))
					PhaseCnt(	.Clock(				Clock),
								.Reset(				(Reset | CycleCountReset)),
								.Set(				1'b0),
								.Load(				1'b0),
								.Enable(			CycleCountEnable & CycleCountEnd),
								.In(				2'bxx),
								.Count(				Phase));
	
	Counter			#(			.Width(				3))
					BitCnt(		.Clock(				Clock),
								.Reset(				1'b0),
								.Set(				(Reset | BitReset)),
								.Load(				1'b0),
								.Enable(			BitCount),
								.In(				3'bxxx),
								.Count(				Bit));
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Current State Register
	//--------------------------------------------------------------------------
	always @ (posedge Clock) begin
		if (Reset) begin
			CurrentState <=							STATE_NOP;
			LastState <=							STATE_NOP;
		end else if (NextOp) begin
			CurrentState <=							NextState;
			LastState <=							CurrentState;
		end
	end
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Next State Logic
	//--------------------------------------------------------------------------
	always @ ( * ) begin
		NextState =									CurrentState;
		SDataSequence =								{8{1'bx}};
		SDataEnableNext =							1'b0;
		CommandReady =								1'b0;
		DataInReady =								1'b0;
		DataOutValid =								1'b0;
		Ack =										1'bx;
		AckValid =									1'b0;

		case (CurrentState)
			STATE_NOP: begin
				if (CommandValid) begin
					case (Command)
						I2CMCMD_Write: NextState =	DataInValid ? STATE_Start : STATE_NOP;
						I2CMCMD_Read: NextState =	STATE_Start;
						I2CMCMD_Restart: NextState = STATE_Start;
						default: begin
							NextState =				STATE_NOP;
							CommandReady =			1'b1;
						end
					endcase
				end
			end
			STATE_Start: begin
				SDataSequence =						{2'b00, {6{1'bx}}};
				SDataEnableNext =					1'b1;
				if (CommandValid) begin
					case (Command)
						I2CMCMD_Write: NextState =	STATE_Write;
						I2CMCMD_Read: NextState =	STATE_Read;
						default: begin
							NextState =				STATE_Stop;
							CommandReady =			DoneOp;
						end
					endcase
				end else begin
					NextState =						STATE_Stop;
					CommandReady =					1'b0;
				end
			end
			STATE_Write: begin
				SDataSequence =						DataIn;
				SDataEnableNext =					1'b1;
				NextState =							STATE_CheckAck;
			end
			STATE_CheckAck: begin
				CommandReady =						DoneOp;
				DataInReady =						DoneOp;
				Ack =								~DataOut[0];
				AckValid =							DoneOp;
				
				if (CommandValid) begin
					case (Command)
						I2CMCMD_Write: NextState =	DataInValid ? STATE_Write : STATE_Stop;
						I2CMCMD_Read: NextState =	STATE_Read;
						I2CMCMD_Restart: NextState = STATE_Restart;
						default: NextState =		STATE_Stop;
					endcase
				end else NextState =				STATE_Stop;
			end
			STATE_Read: begin
				NextState =							STATE_SendAck;
				DataOutValid =						DoneOp;
			end
			STATE_SendAck: begin
				SDataSequence =						{~SendAck, {7{1'bx}}};
				SDataEnableNext =					1'b1;
				CommandReady =						DoneOp;
				
				if (CommandValid) begin
					case (Command)
						I2CMCMD_Write: NextState =	DataInValid ? STATE_Write : STATE_Stop;
						I2CMCMD_Read: NextState =	STATE_Read;
						I2CMCMD_Restart: NextState = STATE_Restart;
						default: NextState =		STATE_Stop;
					endcase
				end else NextState =				STATE_Stop;
			end
			STATE_Stop: begin
				SDataSequence =						{2'b01, {6{1'bx}}};
				SDataEnableNext =					1'b1;
				NextState =							STATE_NOP;
			end
			STATE_Restart: begin
				SDataSequence =						{2'b10, {6{1'bx}}};
				SDataEnableNext =					1'b1;

				CommandReady =						DoneOp;
				if (CommandValid) begin
					case (Command)
						I2CMCMD_Read: NextState =	STATE_Read;
						I2CMCMD_Write: NextState =	DataInValid ? STATE_Write : STATE_Stop;
						I2CMCMD_Restart: NextState = STATE_Restart;
						default: NextState =		STATE_Stop;
					endcase
				end else NextState =				STATE_Stop;
			end
			default: begin
				NextState =							STATE_X;
				SDataSequence =						{8{1'bx}};
				SDataEnableNext =					1'bx;
				CommandReady =						1'bx;
				DataInReady =						1'bx;
				DataOutValid =						1'bx;
				Ack =								1'bx;
				AckValid =							1'bx;
			end
		endcase
	end
	//--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
