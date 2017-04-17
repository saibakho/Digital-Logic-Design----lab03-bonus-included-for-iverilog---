module ALU(A, B, Cin, FS, Y, N, C, V, Z);
	parameter n = 32;
	input [n-1:0] A, B;
	input Cin;
	input [3:0] FS;

	output reg [n-1:0] Y;
	output reg N, C, V, Z;

	wire [n-1:0] Yt;
	wire Cout;
	wire mode;
	wire cin;

	wire [n-1:0] tmpA, tmpB;
	assign tmpA[15:0] = A[15:0];
	assign tmpB[15:0] = B[15:0];
	assign tmpA[n-1:16] = {n-16{A[15]}};
	assign tmpB[n-1:16] = {n-16{B[15]}};

	AdderSubstractor AddSub(A, B, cin, mode, Cout, Yt);

	assign cin = (FS==4'b0101) ? Cin : 1'b0 ;
	assign mode = (FS==4'b0110||FS==4'b0111) ? 1'b1 : 1'b0 ;

	always@(*)begin
		N = Y[n-1];
		Z = (Y==32'd0)?1'b1:1'b0;
		case(FS)
			4'b0000, 4'b0010,
			4'b1100, 4'b1101, 4'b1110, 4'b1111:begin
				N = 1'b0;
				Z = 1'b0;
			end
		endcase
	end

	always@(*)begin
		C = 1'b0;
		V = 1'b0;
		case(FS)
			4'b0001:begin
				C = A[n-1];
				V = A[n-1] ^ A[n-2];					
			end
			4'b0100, 4'b0101, 
			4'b0110, 4'b0111:begin
				C = Cout;
				V =
				  (	( (A[n-1]==1'b1) & (B[n-1]==1'b0) & (mode==1'b1) & (Y[n-1]==1'b0) ) |
					( (A[n-1]==1'b0) & (B[n-1]==1'b1) & (mode==1'b1) & (Y[n-1]==1'b1) ) |
					( (A[n-1]==1'b1) & (B[n-1]==1'b1) & (mode==1'b0) & (Y[n-1]==1'b0) ) |
					( (A[n-1]==1'b0) & (B[n-1]==1'b0) & (mode==1'b0) & (Y[n-1]==1'b1) ) ) ?
				  		1'b1 : 1'b0 ;
			end
		endcase
	end

	always@(*)begin
		case(FS)
			// logic left shift
			4'b0000:begin
				Y[n-1:1] = A[n-2:0];
				Y[0] = 1'b0;
			end
			// arithmetic left shift 
			4'b0001:begin
				Y[n-1:1] = A[n-2:0];
				Y[0] = 1'b0;

			end
			// srl
			4'b0010:begin
				Y[n-2:0] = A[n-1:1];
				Y[n-1] = 1'b0;
			end
			// sra
			4'b0011:begin
				Y[n-2:0] = A[n-1:1];
				Y[n-1] = (Y[n-2]==1'b1)?1'b1:1'b0;
			end
			// add
			4'b0100:begin
				Y = Yt;
			end
			// add with carry
			4'b0101:begin
				Y = Yt;
			end
			// sub
			4'b0110:begin
				Y = Yt;
			end
			// abs
			4'b0111:begin
				Y = (Yt[n-1]==1'b1) ? (Yt ^ {n{1'b1}}) + 1 : Yt ;
			end
			// multi
			4'b1000:begin
				Y = tmpA * tmpB;
			end
			// zero
			4'b1001:begin
				Y = 32'd0;
			end
			// output A
			4'b1010:begin
				Y = A;
			end
			// output B
			4'b1011:begin
				Y = B;
			end
			// and
			4'b1100:begin
				Y = A & B;
			end
			// or
			4'b1101:begin
				Y = A | B;
			end
			// xor
			4'b1110:begin
				Y = A ^ B;
			end
			// not
			4'b1111:begin
				Y = ~A;
			end
		endcase
	end

endmodule

module HalfAdder(A, B, Cin, Cout, Y);
	input A, B, Cin;
	output Cout, Y;

	wire o1, o2, o3;

	xor xor1(Y, A, B, Cin);
	and and1(o1, A, B);
	and and2(o2, A, Cin);
	and and3(o3, B, Cin);
	or or1(Cout, o1, o2, o3);
endmodule

module AdderSubstractor(A, B, Cin, mode, Cout, Y);
	parameter n = 32;
	input [n-1:0] A, B;
	input mode, Cin;
	output Cout;
	output [n-1:0] Y;

	wire Cout;
	wire [n-1:0] Bx;
	wire [n:0] C;

	assign C[0] = mode | Cin;
	assign Bx = B ^ {n{mode}};
	assign Y = A ^ Bx ^ C[n-1:0];
	assign C[n:1] = A & Bx | A & C[n-1:0] | Bx & C[n-1:0];
	assign Cout = C[n];
endmodule