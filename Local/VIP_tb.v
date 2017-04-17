`define SDFFILE   "./VIP.sdf"
`define End_CYCLE  1000000000

`define info  "./info.dat"   

module IP_tb;
	//Clock period
	parameter cyc = 24;
	
	parameter dataWidth=32;
	parameter memWidth=10;

	// #pattern
	parameter PAT = 1026;

	reg [dataWidth-1:0]dataROM[0:PAT-1];
	reg [memWidth-1:0]maxSize;

	reg clk, rst_n, Start;
	reg [dataWidth-1:0]Data;
	wire Finish, En;
	wire [dataWidth-1:0]Result;
	wire [memWidth-1:0]Addr;

	//VIP module
	VIP vip( 
		.clk(clk),
		.rst_n(rst_n), 
		.Start(Start), 
		.Data(Data),
		.Addr(Addr),
		.Result(Result),
		.Finish(Finish),
		.En(En)
	);
	
	always #(cyc/2) clk = ~clk;
	
	initial begin
		`ifdef SDF
			$sdf_annotate(`SDFFILE, vip);
			$dumpfile("VIP_syn.vcd");
		`else
			$dumpfile("VIP.vcd");
		`endif
		$dumpvars;
	end

	
	initial begin
		
		//Init ROM
		$readmemb ("info.dat", dataROM);

		maxSize = 10'd1023;
	
		rst_n = 1'b1;
		clk = 1'b0;
		Start = 1'b0;
		Data = 'hz;

		@(negedge clk)  rst_n = 1'b0; 
		#(cyc*2);    rst_n = 1'b1; 
		
		@(negedge clk)  Start = 1'b1;
		while (Finish == 0) begin             
			if(En && Addr <= maxSize) begin
				Data = dataROM[Addr];  
				
			end else begin
				Data = 'hz;  
		
			end                    
			@(negedge clk);  

		end 
		$display(" ");
		if($signed(Result) == $signed(dataROM[1024]))begin
			$display("Congratulations !! :)");
			$display(" ");
			$finish;

		end

		$display("Wrong Answer !! :(");
	    $display("Result = %d, Answer = %d", $signed(Result), $signed(dataROM[1024]));
		$display(" ");
		$finish;
	end
	
	initial  begin
		#`End_CYCLE ;
		$display("-----------------------------------------------------\n");
		$display("Error!!! Somethings' wrong with your code ...!\n");
		$display("-------------------------FAIL------------------------\n");
		$display("-----------------------------------------------------\n");
		$finish;
	end

endmodule
