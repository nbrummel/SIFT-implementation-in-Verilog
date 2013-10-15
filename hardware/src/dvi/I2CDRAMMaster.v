//==============================================================================
//	File:		$URL: svn+ssh://repositorypub@repository.eecs.berkeley.edu/public/Projects/GateLib/trunk/Firmware/I2C/Hardware/DRAM/I2CDRAMMaster.v $
//	Version:	$Revision: 27062 $
//	Author:		Chris Fletcher (http://cwfletcher.net)
//				Ilia Lebedev
//				Greg Gibeling (http://www.gdgib.com/)
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
//	Module:		I2CDRAMMaster
//	Desc:		An implementation of the DRAM interface based on the I2C bus.
//				This module wraps an instance of I2CMaster, and exposes an
//				inteface for byte-wide read and write operations (the address
//				can be wider, but the data is 1-byte).  Currently, this module
//				only supports a 7-bit slave address mode.
//				
//				This module has two primary operating modes single and multiple
//				slave.  In single slave mode this core will interact with only
//				a single I2C slave, and the slave address is hard coded, rather
//				than in the CommandAddress input.  In multiple slave mode the
//				CommandAddress input includes both the slave and word addresses.
//				
//	Params:		WAWidth: The width of the address of a data word to be
//						transferred.
//				SAWidth: The width of the slave address.  By the I2C standard,
//						this can be either 7 or 10.  TODO: 10bit addressing
//						is NOT currently supported.
//				SingleSlave: When SingleSlave == 1, this module will only ever
//						send commands to a single slave address.  In this case,
//						the slave's address is given by the SlaveAddress
//						parameter.  This mode is provided so that:
//						a) the derived circuit can be simplified
//						b) each CommandAddress need not specify a slave  address
//						
//						When SingleSlave == 0, this module can address a
//						different slave with each new command.
//				SlaveAddress: The slave's address when SingleSlave is 1.  If
//						SingleSlave == 0, this parameter is  ignored.
//	Author:		<a href="http://cwfletcher.net/">Chris Fletcher</a>
//				Ilia Lebedev
//				<a href="http://www.gdgib.com/">Greg Gibeling</a>
//	Version:	$Revision: 27062 $
//------------------------------------------------------------------------------
module	I2CDRAMMaster(
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
			//	Command Interface
			//------------------------------------------------------------------
			CommandAddress,
			Command,
			CommandValid,
			CommandReady,
			//------------------------------------------------------------------
			
			//------------------------------------------------------------------
			//	Data Input (Write) Interface
			//------------------------------------------------------------------
			DataIn,
			DataInValid,
			DataInReady,
			//------------------------------------------------------------------
			
			//------------------------------------------------------------------
			//	Data Output (Read) Interface
			//------------------------------------------------------------------
			DataOut,
			DataOutValid,
			DataOutReady
			//------------------------------------------------------------------
		);
	//--------------------------------------------------------------------------
	//	Parameters
	//--------------------------------------------------------------------------
	parameter				ClockFreq =				100000000,
							I2CRate =				100000,
							WAWidth =				8,
							SingleSlave =			1,
							SlaveAddress =			7'b1011111;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Constants
	//--------------------------------------------------------------------------
	`include "I2CDRAMMaster.constants"
	`include "I2CMaster.constants"
	localparam				SAWidth =				7,							// 10b addressing is not current supported (see I2C.v header), TODO: make into a parameter
							DWidth =				8,							// The width of the I2C data
							CAWidth =				SingleSlave ? WAWidth : WAWidth + SAWidth,	// The command address width
	`ifdef MACROSAFE
							WAWords = 				`divceil(WAWidth, DWidth),	// Number of words needed for transfering the word address
							WACWidth =				(WAWords > 1) ? `log2(WAWords) : 1,			// Width of the word address counter
	`else
							WAWords =				WAWidth / DWidth,
							WACWidth =				WAWords,
	`endif
							LRWidth =				I2CDCMD_CWidth + DWidth + ((WAWords > 1) ? (SingleSlave ? 0 : SAWidth) : CAWidth);
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	FSM States
	//--------------------------------------------------------------------------
	localparam				SWidth =				3,
							STATE_Idle =			3'd0,
							STATE_SAddress =		3'd1,
							STATE_Address =			3'd2,
							STATE_Write =			3'd3,
							STATE_Restart =			3'd4,
							STATE_ReAddress =		3'd5,
							STATE_Read =			3'd6,
							STATE_Stop =			3'd7;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Clock & Reset Inputs
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
	//	Command Interface
	//--------------------------------------------------------------------------
	input	[CAWidth-1:0] 	CommandAddress;
	input	[I2CDCMD_CWidth-1:0] Command;
	input					CommandValid;
	output					CommandReady;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Data Input (Write) Interface
	//--------------------------------------------------------------------------
	input	[DWidth-1:0]	DataIn;
	input					DataInValid;
	output 					DataInReady;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Data Output (Read) Interface
	//--------------------------------------------------------------------------
	output	[DWidth-1:0]	DataOut;
	output					DataOutValid;
	input					DataOutReady;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Wires & Regs
	//--------------------------------------------------------------------------
	reg		[SWidth-1:0]	CurrentState, NextState;
	
	reg 	[I2CMCMD_CWidth-1:0] I2CMasterCommand;
	wire 					I2CMasterCommandReady;
	reg						I2CMasterCommandValid;
	
	reg 	[DWidth-1:0] 	I2CMasterDataIn;
	wire 					I2CMasterDataInReady;
	reg						I2CMasterDataInValid;
	
	wire	[DWidth-1:0]	I2CMasterDataOut;
	wire					I2CMasterDataOutReady, I2CMasterDataOutValid;
	
	wire	[SAWidth-1:0]	SlaveAddressResolved;
	
	wire	[DWidth-1:0]	AddressOut;
	wire					AddressInReady, AddressOutValid;
	reg						AddressOutReady;
	
	wire	[LRWidth-1:0]	LatchInData, LatchOutData;
	
	wire	[WACWidth-1:0]	WACount;
	wire					WAMax;
	
	wire					WaitingOnRead;
	wire 					I2CTransferComplete;
	
	wire 	[I2CDCMD_CWidth-1:0] CommandLatched;
	wire 	[DWidth-1:0] 	DataLatched;
	wire 					LatchInValid, LatchInReady, LatchOutValid;
	reg 					LatchOutReady;
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Assigns
	//--------------------------------------------------------------------------
	assign	WaitingOnRead = 						(Command == I2CDCMD_Read) ? DataOutValid : 1'b0;
	
	assign	LatchInValid =							((Command == I2CDCMD_Write) ? DataInValid : 1'b1) & CommandValid;
	assign	CommandReady = 							~WaitingOnRead & AddressInReady & LatchInReady;
	assign	DataInReady = 							(Command == I2CDCMD_Write) ? CommandValid & CommandReady : 1'b0;
	
	assign	I2CTransferComplete = 					I2CMasterDataInValid & I2CMasterDataInReady & I2CMasterCommandValid & I2CMasterCommandReady;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	I2C Core
	//--------------------------------------------------------------------------
	I2CMaster		#(			.ClockFreq(			ClockFreq),
								.I2CRate(			I2CRate))
					Master(		.SDA(				SDA),
								.SCL(				SCL),
								.Clock(				Clock),
								.Reset(				Reset),
								.Command(			I2CMasterCommand),
								.CommandValid(		I2CMasterCommandValid),
								.CommandReady(		I2CMasterCommandReady),
								.DataIn(			I2CMasterDataIn),
								.DataInValid(		I2CMasterDataInValid),
								.DataInReady(		I2CMasterDataInReady),
								.DataOut(			I2CMasterDataOut),
								.DataOutAck(		1'b0),
								.DataOutValid(		I2CMasterDataOutValid),
								.DataOutReady(		I2CMasterDataOutReady),
								.Ack(				/* Unconnected */),
								.AckValid(			/* Unconnected */),
								.AckReady(			1'b1));
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Address & Command Logic
	//--------------------------------------------------------------------------
	generate if (WAWords > 1) begin:LONGADDR
		wire	[WAWidth-1:0] AddressIn;
		wire				AddressInValid;
		
		assign	AddressIn =							SingleSlave ? CommandAddress : CommandAddress[CAWidth-SAWidth-1:0];
		assign	AddressInValid =					LatchInValid & ~WaitingOnRead & LatchInReady;
		assign	LatchInData = 						SingleSlave ? {Command, DataIn} : {Command, CommandAddress[CAWidth-1:CAWidth-SAWidth], DataIn};
		
		FIFOShiftRound #( 		.IWidth(			WAWidth),
								.OWidth(			DWidth),
								.Reverse(			0),
								.Bottom(			0),
								.Class1(			0),
								.Variable(			0),
								.Register(			0))
					AInShift(	.Clock(				Clock),
								.Reset(				Reset),
								.RepeatLimit(		/* Unconnected */),
								.RepeatMin(			/* Unconnected */),
								.RepeatPreMax(		/* Unconnected */),
								.RepeatMax(			/* Unconnected */),
								.InData(			AddressIn),
								.InValid(			AddressInValid),
								.InAccept(			AddressInReady),
								.OutData(			AddressOut),
								.OutValid(			AddressOutValid),
								.OutReady(			AddressOutReady));
								
		Counter		#(			.Width(				WACWidth))
					WACnt(		.Clock(				Clock),
								.Reset(				Reset | (WAMax & I2CTransferComplete)),
								.Set(				1'b0),
								.Load(				1'b0),
								.Enable(			I2CTransferComplete & (CurrentState == STATE_Address)),
								.In(				{WACWidth{1'bx}}),
								.Count(				WACount));
		CountCompare #(			.Width(				WACWidth),
								.Compare(			WAWords-1))
					WACmp(		.Count(				WACount),
								.TerminalCount(		WAMax));
		
		if (SingleSlave) begin:LASS
			assign	{CommandLatched, DataLatched} =	LatchOutData;
		end else begin:LAMS
			assign	{CommandLatched, SlaveAddressResolved, DataLatched} = LatchOutData;
		end
	end else begin:SHORTADDR
		assign	AddressInReady =					1'b1;
		assign	AddressOutValid =					LatchOutValid;
		assign	WAMax =								1'b1;
		assign	LatchInData = 						{Command, CommandAddress, DataIn};
		
		if (SingleSlave) begin:SASS
			assign	{CommandLatched, AddressOut, DataLatched} = LatchOutData;
		end else begin:SAMS
			assign	{CommandLatched, SlaveAddressResolved, AddressOut, DataLatched} = LatchOutData;
		end
	end endgenerate
	
	FIFORegister 	#(			.Width(				LRWidth))
					InLatch(	.Clock(				Clock),
								.Reset(				Reset),
								.InData(			LatchInData),
								.InValid(			LatchInValid & ~WaitingOnRead & AddressInReady),
								.InAccept(			LatchInReady),
								.OutData(			LatchOutData),
								.OutSend(			LatchOutValid),
								.OutReady(			LatchOutReady));
	
	generate if (SingleSlave) begin:SSSAL
		assign	SlaveAddressResolved =				SlaveAddress;
	end endgenerate
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Data Output Buffer
	//--------------------------------------------------------------------------
	FIFORegister 	#(			.Width(				DWidth))
					DOBuff(		.Clock(				Clock),
								.Reset(				Reset),
								.InData(			I2CMasterDataOut),
								.InValid(			I2CMasterDataOutValid),
								.InAccept(			I2CMasterDataOutReady),
								.OutData(			DataOut),
								.OutSend(			DataOutValid),
								.OutReady(			DataOutReady));
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	State Register
	//--------------------------------------------------------------------------
	always @(posedge Clock) begin
		if (Reset) CurrentState <=					STATE_Idle;
		else CurrentState <=						NextState;
		
		//if (CurrentState != NextState) $display("DEBUG[%m @ %t]: %d to %d", $time, CurrentState, NextState);
	end
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Next State Logic
	//--------------------------------------------------------------------------
	always @ (*) begin
		I2CMasterCommand =							{I2CMCMD_CWidth{1'bx}};
		I2CMasterCommandValid =						1'b1;
		I2CMasterDataIn =							{DWidth{1'bx}};
		I2CMasterDataInValid =						1'b1;
		LatchOutReady =								1'b0;
		AddressOutReady =							1'b0;
		NextState =									CurrentState;
		
		case(CurrentState)
			STATE_Idle: begin
				I2CMasterCommandValid =				1'b0;
				I2CMasterDataInValid =				1'b0;
				if (LatchOutValid) NextState = 		STATE_SAddress;
			end
			STATE_SAddress: begin
				I2CMasterDataIn =					{SlaveAddressResolved, 1'b0};
				I2CMasterCommand =					I2CMCMD_Write;
				if (I2CMasterDataInReady & I2CMasterCommandReady) NextState = STATE_Address;
			end
			STATE_Address: begin
				I2CMasterDataIn =					AddressOut;
				I2CMasterCommand = 					I2CMCMD_Write;
				I2CMasterDataInValid =				AddressOutValid;
				AddressOutReady =					I2CMasterDataInReady;
				if (WAMax & AddressOutValid & I2CMasterDataInReady & I2CMasterCommandReady) case (CommandLatched)
					I2CDCMD_Write: NextState =		STATE_Write;
					I2CDCMD_Read: NextState =		STATE_Restart;
					default: NextState = 			{SWidth{1'bx}};
				endcase
			end
			STATE_Write: begin
				I2CMasterDataIn =					DataLatched;
				I2CMasterCommand = 					I2CMCMD_Write;
				I2CMasterDataInValid =				LatchOutValid;
				if (LatchOutValid & I2CMasterDataInReady & I2CMasterCommandReady) begin
					LatchOutReady = 				1'b1;
					NextState = 					STATE_Idle;
				end
			end
			STATE_Restart: begin
				I2CMasterCommand =					I2CMCMD_Restart;
				I2CMasterDataInValid =				1'b0;
				if (I2CMasterCommandReady) NextState = STATE_ReAddress;
			end
			STATE_ReAddress: begin
				I2CMasterDataIn =					{SlaveAddressResolved, 1'b1};
				I2CMasterCommand =					I2CMCMD_Write;
				if (I2CMasterDataInReady & I2CMasterCommandReady) NextState = STATE_Read;
			end
			STATE_Read: begin
				I2CMasterCommand =					I2CMCMD_Read;
				I2CMasterDataInValid =				1'b0;
				if (I2CMasterDataOutValid) begin
					LatchOutReady =					1'b1;
					NextState = 					STATE_Stop;
				end
			end
			STATE_Stop: begin
				I2CMasterCommandValid =				1'b0;
				I2CMasterDataInValid =				1'b0;
				if (I2CMasterCommandReady) NextState = STATE_Idle;
			end
			default: begin
				I2CMasterDataIn =					{DWidth{1'bx}};
				I2CMasterCommand =					{I2CMCMD_CWidth{1'bx}};
				I2CMasterCommandValid =				1'bx;
				I2CMasterDataInValid =				1'bx;
				LatchOutReady =						1'bx;
				AddressOutReady =					1'bx;
				NextState =							{SWidth{1'bx}};
			end
		endcase
	end
	//--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
