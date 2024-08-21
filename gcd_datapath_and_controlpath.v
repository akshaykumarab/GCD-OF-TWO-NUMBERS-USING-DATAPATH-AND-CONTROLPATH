`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Engineer: Akshaykumar Appasheb Biradar
//
// Create Date:    19:54:00 08/15/24
// Design Name:    
// Module Name:    gcd_datapath_and_controlpath
// Project Name:  GCD OF TWO NUMBERS BY CONTINUOUS SUBTRACTION USING DATAPATH AND CONTROLPATH 
////////////////////////////////////////////////////////////////////////////////


//THE DATAPATH

module gcd_datapath(gt,lt,eq, ldA,ldB,sel1,sel2,sel_in, dat_in,clk);
    output gt, lt, eq;
    input ldA, ldB, sel1, sel2, sel_in, clk;
    input [15:0] dat_in;
    wire [15:0] Aout, Bout, x, y, Bus, Subout;

    PIPO A(Aout, Bus, ldA, clk);
    PIPO B(Bout, Bus, ldB, clk);
    MUX Mux_in1(x, Aout, Bout, sel1);
    MUX Mux_in2(y, Aout, Bout, sel2);
    MUX Mux_load(Bus, Subout, dat_in, sel_in);
    SUB SB (Subout, x, y);
    COMPARE COMP (lt, gt, eq, Aout, Bout);
endmodule

//VERILOG CODES FOR BLOCKS IN DATAPATH AND CONTROLPATH
////
module PIPO (data_out, data_in, load, clk);
    input [15:0] data_in;
    input load, clk;
    output reg [15:0] data_out;

    always @(posedge clk)
        if (load) 
            data_out <= data_in;
endmodule

////
module SUB (out, in1, in2);
    input [15:0] in1, in2;
    output reg [15:0] out;

    always @(*)
        out = in1 - in2;
endmodule

////
module MUX(out, in0, in1, sel);
    input [15:0] in0, in1;
    input sel;
    output [15:0] out;

    assign out = sel ? in1 : in0;
endmodule

////
module COMPARE (lt, gt, eq, data1, data2);
    input [15:0] data1, data2;
    output lt, gt, eq;

    assign lt = data1 < data2;
    assign gt = data1 > data2;
    assign eq = data1 == data2;
endmodule




///////////////////////////////////////////////////////////////////////////////////////////

// THE CONTROLPATH

module controller(ldA, ldB, sel1, sel2, sel_in, done, clk, lt, gt, eq, start);
    input clk, lt, gt, eq, start;
    output reg ldA, ldB, sel1, sel2, sel_in, done;
    reg [2:0] state, next_state;
    
    parameter s0 = 3'b000, s1 = 3'b001, s2 = 3'b010, 
              s3 = 3'b011, s4 = 3'b100, s5 = 3'b101;

    always @(posedge clk) begin 
        state <= next_state;
    end

    always @(state or start or eq or lt or gt) begin 
        case (state)
            s0: begin 
                sel_in = 1; ldA = 1; ldB = 0; done = 0; 
                next_state = s1;
            end
            s1: begin 
                sel_in = 1; ldA = 0; ldB = 1; 
                next_state = s2;
            end
            s2: begin 
                if (eq) begin 
                    done = 1; 
                    next_state = s5; 
                end else if (lt) begin 
                    sel1 = 1; sel2 = 0; sel_in = 0; 
                    next_state = s3;
                    #1 ldA = 0; ldB = 1; 
                end else if (gt) begin 
                    sel1 = 0; sel2 = 1; sel_in = 0; 
                    next_state = s4;
                    #1 ldA = 1; ldB = 0; 
                end
            end
            s3: begin 
                if (eq) begin 
                    done = 1; 
                    next_state = s5; 
                end else if (lt) begin 
                    sel1 = 1; sel2 = 0; sel_in = 0; 
                    next_state = s3;
                    #1 ldA = 0; ldB = 1; 
                end else if (gt) begin 
                    sel1 = 0; sel2 = 1; sel_in = 0; 
                    next_state = s4;
                    #1 ldA = 1; ldB = 0; 
                end
            end
            s4: begin 
                if (eq) begin 
                    done = 1; 
                    next_state = s5; 
                end else if (lt) begin 
                    sel1 = 1; sel2 = 0; sel_in = 0; 
                    next_state = s3;
                    #1 ldA = 0; ldB = 1; 
                end else if (gt) begin 
                    sel1 = 0; sel2 = 1; sel_in = 0; 
                    next_state = s4;
                    #1 ldA = 1; ldB = 0; 
                end
            end
            s5: begin 
                done = 1; sel1 = 0; sel2 = 0; 
                ldA = 0; ldB = 0; 
                next_state = s5;
            end
            default: begin 
                ldA = 0; ldB = 0; 
                next_state = s0; 
            end
        endcase
    end
endmodule
