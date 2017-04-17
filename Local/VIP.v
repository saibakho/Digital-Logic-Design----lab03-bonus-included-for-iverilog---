module VIP(clk, rst_n, Start, Data, Addr, Result, Finish, En);

	parameter memWidth = 10;
	parameter dataWidth = 32;

	input clk, rst_n, Start;
	input [dataWidth-1:0]Data;

	output reg [dataWidth-1:0]Result;
	output reg [memWidth-1:0]Addr;
	output reg Finish, En;

	// d flip-flop
	reg  [dataWidth-1:0] nextRomX, nextSum, nextAmt;
	reg  [dataWidth-1:0] romX, sum, prevResult, amt;	// wire
	reg  [memWidth-1:0]  prevAddr;	// wire
	reg  [1:0] state;	// wire
	reg  [1:0] nextState;
	/*DFF #(3) 		status(clk, nextState, 		 state);
	DFF #(dataWidth)    r0(clk,  nextRomX, 		  romX);
	DFF #(dataWidth)   Acc(clk,    Result,  prevResult);
	DFF #(memWidth) memRAM(clk, 	 Addr, 	  prevAddr);
	DFF #(dataWidth)  temp(clk,   nextSum, 		   sum);
	DFF #(dataWidth)  left(clk,   nextAmt, 		   amt);*/
	always@(negedge clk)begin	// a big combined D-flipflop
		state = nextState ;
		romX  =  nextRomX ;
		sum   =   nextSum ;
		amt   =   nextAmt ;
		prevAddr   = Addr ;
		prevResult = Result ;
	end

	// states
	parameter IDLE = 2'b00;
	parameter X_0  = 2'b01;
	parameter MUL  = 2'b10;
	parameter ADD  = 2'b11;

	// ALU
	wire [dataWidth-1:0] A, B, Y;
	wire [3:0] FS;
	wire Cin, N, C, V, Z;
	assign  A = (state == MUL) ? romX : sum ;
	assign  B = (state == MUL) ? Data : prevResult ;
	assign FS = (state == MUL) ? 4'b1000 : 4'b0100 ;
	ALU AddMul(A, B, Cin, FS, Y, N, C, V, Z);

	// finite state machine
	always@(negedge rst_n)begin
		//if (!rst_n) begin	// initialize
			nextState = IDLE;
			En = 1;
			Finish = 0;
			Result = 0;
		//end
	end
	
	always@(posedge clk)begin
		case(state)
			IDLE:begin
				Addr = 10'd1023;
				if (Start)begin
					nextAmt = Data ;
					Addr = 0;
					nextState = X_0;
				end else begin
					nextState = IDLE;
					end
				end
			X_0:begin
				nextRomX = Data;
				Addr = prevAddr + 1;
				nextAmt = amt - 1;
				nextState = MUL;
				end
			MUL:begin
				nextAmt = amt - 1;
				Addr = prevAddr + 1;
				nextSum = Y;	// ALU
				nextState = ADD;
				end
			ADD:begin
				if (amt == 0)begin
					Finish = 1;
				end else begin
					nextRomX = Data;
					Addr = prevAddr + 1 ;
					nextAmt = amt - 1;
					nextState = MUL;
				end
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