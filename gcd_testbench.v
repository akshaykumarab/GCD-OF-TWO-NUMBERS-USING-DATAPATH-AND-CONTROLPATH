`timescale 1ns / 1ps

module gcd_testbench;

	// Inputs
	reg [15:0] data_in;
	reg clk, start;
	
	// Wires for connections between modules
	wire gt, lt, eq;
	wire ldA, ldB, sel1, sel2, sel_in;
	wire done;

	// Instantiate the Unit Under Test (UUT)
	gcd_datapath DP(
		.gt(gt),
		.lt(lt),
		.eq(eq),
		.ldA(ldA),
		.ldB(ldB),
		.sel1(sel1),
		.sel2(sel2),
		.sel_in(sel_in),
		.dat_in(data_in),
		.clk(clk)
	);
	
	controller CON(
		.ldA(ldA),
		.ldB(ldB),
		.sel1(sel1),
		.sel2(sel2),
		.sel_in(sel_in),
		.done(done),
		.clk(clk),
		.lt(lt),
		.gt(gt),
		.eq(eq),
		.start(start)
	);
	
	initial 
	begin
	   clk = 1'b0;
		start = 1'b0;
		#3 start = 1'b1;
		#1000 $finish;
	end

	always #5 clk = ~clk;

	initial
	begin 
		#12 data_in = 143;
		#10 data_in = 78;
	end

	initial 
	begin 
		$dumpfile("gcd.vcd");
		$dumpvars(0, gcd_testbench);
		$monitor($time, " Aout=%d done=%b", DP.Aout, done);
	end
      
endmodule
