module Cost(clk, rst_n, Start, Data, Addr, Result, Finish, En);

	parameter memWidth = 10;
	parameter dataWidth = 32;

	input clk, rst_n, Start;
	input [dataWidth-1:0]Data;

	output reg [dataWidth-1:0]Result;
	output reg [memWidth-1:0]Addr;
	output reg Finish, En;

	// d flip-flop
	reg  [dataWidth-1:0] nextRomX, nextRomY, nextSum, nextAmt;
	reg  [dataWidth-1:0] romX, romY, sum, prevResult, amt;	// wire
	reg  [memWidth-1:0]  prevAddr;	// wire
	reg  [2:0] state;	// wire
	reg  [2:0] nextState;
	/*DFF #(3) 		status(clk, nextState, 		 state);
	DFF #(dataWidth)    r0(clk,  nextRomX, 		  romX);
	DFF #(dataWidth)   Acc(clk,    Result,  prevResult);
	DFF #(memWidth) memRAM(clk, 	 Addr, 	  prevAddr);
	DFF #(dataWidth)  temp(clk,   nextSum, 		   sum);
	DFF #(dataWidth)  left(clk,   nextAmt, 		   amt);*/
	always@(negedge clk)begin	// a big combined D-flipflop
		state = nextState ;
		romX  =  nextRomX ;
		romY  =  nextRomY ;
		sum   =   nextSum ;
		amt   =   nextAmt ;
		prevAddr   = Addr ;
		prevResult = Result ;
	end

	// states
	parameter IDLE = 3'b000;
	parameter X_0  = 3'b001;
	parameter SUB  = 3'b010;
	parameter SQR  = 3'b011;
	parameter ADD  = 3'b100;
	parameter SHFT = 3'b101;

	// ALU
	wire [dataWidth-1:0] Y;
	reg  [dataWidth-1:0] A, B;
	reg  [3:0] FS;
	wire Cin, N, C, V, Z;
	always@(*)begin
		case(state)
			SUB:begin
				A  = romX ;
				B  = Data ;
				FS = 4'b0110 ;
				end
			SQR:begin
				A  = sum ;
				B  = sum ;
				FS = 4'b1000 ;
				end
			ADD:begin
				A  = sum ;
				B  = prevResult ;
				FS = 4'b0100 ;
				end
			SHFT:begin
				A  = prevResult;
				FS = 4'b0011;
				end
		endcase
	end
	ALU AddMul(A, B, Cin, FS, Y, N, C, V, Z);

	// finite state machine
	always@(posedge clk)begin
		if (!rst_n) begin	// initialize
			nextState = IDLE;
			En = 1;
			Finish = 0;
			Result = 0;
		end
	end
	always@(posedge clk)begin
		case(state)
			IDLE:begin
				Addr = 10'd1023;
				if (Start)begin
					nextAmt = Data;
					Addr = 0;
					nextState = X_0;
				end else begin
					nextState = IDLE;
					end
				end
			X_0:begin
				nextRomX = Data;
				Addr = prevAddr + 1;	// ask for next Y
				nextAmt = amt - 1;
				nextState = SUB;
				end
			SUB:begin
				nextSum = Y;	// ALU
				nextState = SQR;
				end
			SQR:begin
				nextRomX = Data;
				nextAmt = amt - 1;	// ask for next X
				Addr = prevAddr + 1 ;
				nextSum = Y;
				nextState = ADD;
				end
			ADD:begin
				if (amt == 0)begin
					nextState = SHFT;
				end else begin
					nextRomX = Data;
					Addr = prevAddr + 1 ;
					nextAmt = amt - 1;
					nextState = SUB;
				end
				Result = Y;
				end
			SHFT:begin
				En = 0;
				Finish = 1;
				Result = Y;
				end
		endcase
	end
	
endmodule

module DFF(clk, in, out);
	parameter n = 1;
	input clk;
	input [n-1:0] in ;
	output reg [n-1:0] out ;
	
	always @(negedge clk)
		out = in ;
endmodule