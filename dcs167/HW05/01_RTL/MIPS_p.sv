module MIPS(
    //Input
    clk,
    rst_n,
    in_valid,
    instruction,
	output_reg,
    //OUTPUT
    out_valid,
    out_1,
	out_2,
	out_3,
	out_4,
	instruction_fail
);

//Input
input clk;
input rst_n;
input in_valid;
input [31:0] instruction;
input [19:0] output_reg;
//OUTPUT
output logic out_valid, instruction_fail;
output logic [15:0] out_1, out_2, out_3, out_4;
//Logic
logic instruction_fail_s, out_valid_s;
logic [2:0] Rs_index, Rt_index, Rd_index, Rd_store, Rd_store_s;
logic [2:0] out1_index, out2_index, out3_index, out4_index,
            out1_index_c, out2_index_c, out3_index_c, out4_index_c;
logic [15:0] reg_c[5:0], reg_s[5:0];
//gcd
logic [15:0] GCD_big, GCD_small, GCD_big_s, GCD_small_s;
logic [15:0] GCD_itr_small[3:0], GCD_itr_big[3:0];
logic [3:0] GCD_cal, GCD_cal_s, GCD_itr_cal[2:0];
//state
logic [3:0] status, NS;
parameter [3:0] {PARAMS};
/*
parameter IDLE = 4'b0000; parameter R = 4'b0010;
parameter R_GCD = 4'b1000;
parameter I = 4'b1001; parameter INST_FAIL = 4'b1010; parameter OUTPUT = 4'b1011;
*/
//---------------------DFF---------------------//
always_ff @( posedge clk, negedge rst_n) begin
    if (!rst_n) status <= IDLE;
    else status <= NS;
end

always_ff @( posedge clk, negedge rst_n) begin
    if (!rst_n) out_valid <= 0;
    else out_valid <= out_valid_s;
end

always_ff @( posedge clk, negedge rst_n) begin
    if (!rst_n) instruction_fail <= 0;
    else instruction_fail <= instruction_fail_s;
end

always_ff @( posedge clk, negedge rst_n ) begin
    if (!rst_n) reg_s[5:0] <= {16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0};
    else reg_s[5:0] <= reg_c[5:0];
end

always_ff @(posedge clk) begin
    out1_index <= out1_index_c; out2_index <= out2_index_c;
    out3_index <= out3_index_c; out4_index <= out4_index_c;
    GCD_big <= GCD_big_s; GCD_small <= GCD_small_s; GCD_cal <= GCD_cal_s;
    Rd_store <= Rd_store_s;
end

//---------------------COMBINATIONAL---------------------//
//input & read & cal
always_comb begin
    instruction_fail_s = 0;
    out_valid_s = 0;
    reg_c = reg_s;
    out1_index_c = out1_index; out2_index_c = out2_index;
    out3_index_c = out3_index; out4_index_c = out4_index;
    Rd_store_s = Rd_store;
    GCD_cal_s = 0;
    GCD_big_s = 0;
    GCD_small_s = 0;
    case (instruction[25:21])
        5'b10001 : Rs_index = 0;
        5'b10010 : Rs_index = 1;
        5'b01000 : Rs_index = 2;
        5'b10111 : Rs_index = 3;
        5'b11111 : Rs_index = 4;
        5'b10000 : Rs_index = 5;
        default : Rs_index = 7;
    endcase
    case (instruction[20:16])
        5'b10001 : Rt_index = 0;
        5'b10010 : Rt_index = 1;
        5'b01000 : Rt_index = 2;
        5'b10111 : Rt_index = 3;
        5'b11111 : Rt_index = 4;
        5'b10000 : Rt_index = 5;
        default : Rt_index = 7;
    endcase
    case (instruction[15:11])
        5'b10001 : Rd_index = 0;
        5'b10010 : Rd_index = 1;
        5'b01000 : Rd_index = 2;
        5'b10111 : Rd_index = 3;
        5'b11111 : Rd_index = 4;
        5'b10000 : Rd_index = 5;
        default : Rd_index = 7;
    endcase

    if (in_valid) begin
        Rd_store_s = Rd_index;
        case (output_reg[19:15])
        5'b10001 : out4_index_c = 0;
        5'b10010 : out4_index_c = 1;
        5'b01000 : out4_index_c = 2;
        5'b10111 : out4_index_c = 3;
        5'b11111 : out4_index_c = 4;
        5'b10000 : out4_index_c = 5;
        default : out4_index_c = 7;
        endcase
        case (output_reg[14:10])
        5'b10001 : out3_index_c = 0;
        5'b10010 : out3_index_c = 1;
        5'b01000 : out3_index_c = 2;
        5'b10111 : out3_index_c = 3;
        5'b11111 : out3_index_c = 4;
        5'b10000 : out3_index_c = 5;
        default : out3_index_c = 7;
        endcase
        case (output_reg[9:5])
        5'b10001 : out2_index_c = 0;
        5'b10010 : out2_index_c = 1;
        5'b01000 : out2_index_c = 2;
        5'b10111 : out2_index_c = 3;
        5'b11111 : out2_index_c = 4;
        5'b10000 : out2_index_c = 5;
        default : out2_index_c = 7;
        endcase
        case (output_reg[4:0])
        5'b10001 : out1_index_c = 0;
        5'b10010 : out1_index_c = 1;
        5'b01000 : out1_index_c = 2;
        5'b10111 : out1_index_c = 3;
        5'b11111 : out1_index_c = 4;
        5'b10000 : out1_index_c = 5;
        default : out1_index_c = 7;
        endcase
        if (instruction[31:26] == 6'b000000) begin
            if (Rs_index == 7 || Rt_index == 7 || Rd_index == 7) begin
                NS = INST_FAIL;
            end
            else begin
                case (instruction[6:0])
                    7'b0100000 : begin//+
                        NS = R;
                        reg_c[Rd_index] = reg_s[Rs_index] + reg_s[Rt_index];
                    end
                    7'b0100100 : begin//&
                        NS = R;
                        reg_c[Rd_index] = reg_s[Rs_index] & reg_s[Rt_index];
                    end
                    7'b0100101 : begin//|
                        NS = R;
                        reg_c[Rd_index] = reg_s[Rs_index] | reg_s[Rt_index];
                    end
                    7'b0100111 : begin//nor
                        NS = R;
                        reg_c[Rd_index] = ~(reg_s[Rs_index] | reg_s[Rt_index]);
                    end
                    7'b0000000 : begin// <<
                        NS = R;
                        reg_c[Rd_index] = reg_s[Rt_index] << instruction[10:7];
                    end
                    7'b0000010 : begin// >>
                        NS = R;
                        reg_c[Rd_index] = reg_s[Rt_index] >> instruction[10:7];
                    end
                    7'b1111000 : begin//GCD
                        if (reg_s[Rs_index] == 0 || reg_s[Rt_index] == 0) begin
                            NS = INST_FAIL;
                        end
                        else if ((reg_s[Rs_index] ^ reg_s[Rt_index]) == 16'd0) begin//totally same
                            NS = R;
                            reg_c[Rd_index] = reg_s[Rs_index];
                        end
                        else begin
                            NS = R_GCD;
                            GCD_small_s = ((reg_s[Rt_index]) >= (reg_s[Rs_index])) ? (reg_s[Rs_index]) : (reg_s[Rt_index]);
                            GCD_big_s = ((reg_s[Rt_index]) >= (reg_s[Rs_index])) ? (reg_s[Rt_index]) : (reg_s[Rs_index]);
                            GCD_cal_s = 0;
                        end
                    end
                    default : begin
                        NS = INST_FAIL;
                    end
                endcase
            end
        end
        else if (instruction[31:26] == 6'b001000) begin
            if (Rs_index == 7 || Rt_index == 7) begin
                NS = INST_FAIL;
            end
            else begin
                NS = I;
                reg_c[Rt_index] = reg_s[Rs_index] + instruction[15:0];
            end
        end
        else begin
            NS = INST_FAIL;
        end
    end
    //output
    else begin
        if (status == INST_FAIL) begin
            out_valid_s = 1;
            NS = OUTPUT;
            instruction_fail_s = 1;
        end
        else if (status == R) begin
            out_valid_s = 1;
            NS = OUTPUT;
        end
        else if (status == I) begin
            out_valid_s = 1;
            NS = OUTPUT;
        end
        else if (status == R_GCD) begin
            NS = R_GCD;
            GCD_small_s = GCD_itr_small[2];
            GCD_big_s = GCD_itr_big[2];
            GCD_cal_s = GCD_itr_cal[2];
            if (GCD_itr_small[0] == GCD_itr_big[0]) begin
                reg_c[Rd_store] = GCD_itr_small[0] << GCD_itr_cal[0];
                out_valid_s = 1;
                NS = OUTPUT;
            end
            else if (GCD_itr_small[0] == 1 || GCD_itr_big[0] == 1) begin
                reg_c[Rd_store] = 1 << GCD_itr_cal[0];
                out_valid_s = 1;
                NS = OUTPUT;
            end
            else if (GCD_itr_small[1] == GCD_itr_big[1]) begin
                reg_c[Rd_store] = GCD_itr_small[1] << GCD_itr_cal[1];
                out_valid_s = 1;
                NS = OUTPUT;
            end
            else if (GCD_itr_small[1] == 1 || GCD_itr_big[1] == 1) begin
                reg_c[Rd_store] = 1 << GCD_itr_cal[1];
                out_valid_s = 1;
                NS = OUTPUT;
            end
            else if (GCD_itr_small[2] == GCD_itr_big[2]) begin
                reg_c[Rd_store] = GCD_itr_small[2] << GCD_itr_cal[2];
                out_valid_s = 1;
                NS = OUTPUT;
            end
            else if (GCD_itr_small[2] == 1 || GCD_itr_big[2] == 1) begin
                reg_c[Rd_store] = 1 << GCD_itr_cal[2];
                out_valid_s = 1;
                NS = OUTPUT;
            end
        end
        else if (status == OUTPUT) begin
            NS = IDLE;
            out_valid_s = 0;
            instruction_fail_s = 0;
        end
        else begin
            NS = IDLE;
            out_valid_s = 0;
            instruction_fail_s = 0;
        end
    end
end
//---------------OUTPUT----------------//
always_comb begin
    if (out_valid && !instruction_fail) begin
        out_1 = reg_s[out1_index];
        out_2 = reg_s[out2_index];
        out_3 = reg_s[out3_index];
        out_4 = reg_s[out4_index];
    end
    else begin
        out_1 = 0;
        out_2 = 0;
        out_3 = 0;
        out_4 = 0;
    end
end

//---------------GCD ITERATION----------------//
always_comb begin
    // both even
    if (~(GCD_big[0] | GCD_small[0])) begin
        GCD_itr_small[0] = ((GCD_big >> 1) >= (GCD_small >> 1)) ? (GCD_small >> 1) : (GCD_big >> 1);
        GCD_itr_big[0] = ((GCD_big >> 1) >= (GCD_small >> 1)) ? (GCD_big >> 1) : (GCD_small >> 1);
        GCD_itr_cal[0] = GCD_cal + 1;
    end
    // big even
    else if (~GCD_big[0]) begin
        GCD_itr_small[0] = ((GCD_big >> 1) >= (GCD_small)) ? (GCD_small) : (GCD_big >> 1);
        GCD_itr_big[0] = ((GCD_big >> 1) >= (GCD_small)) ? (GCD_big >> 1) : (GCD_small);
        GCD_itr_cal[0] = GCD_cal;
    end
    // small even
    else if (~GCD_small[0]) begin
        GCD_itr_small[0] = ((GCD_big) >= (GCD_small >> 1)) ? (GCD_small >> 1) : (GCD_big);
        GCD_itr_big[0] = ((GCD_big) >= (GCD_small >> 1)) ? (GCD_big) : (GCD_small >> 1);
        GCD_itr_cal[0] = GCD_cal;
    end
    // both odd
    else begin
        GCD_itr_small[0] = (((GCD_big - GCD_small) >> 1) >= GCD_small) ? GCD_small : ((GCD_big - GCD_small) >> 1);
        GCD_itr_big[0] = (((GCD_big - GCD_small) >> 1) >= GCD_small) ? ((GCD_big - GCD_small) >> 1) : GCD_small;
        GCD_itr_cal[0] = GCD_cal;
    end

   if (~(GCD_itr_big[0][0] | GCD_itr_small[0][0])) begin
        GCD_itr_small[1] = ((GCD_itr_big[0] >> 1) >= (GCD_itr_small[0] >> 1)) ? (GCD_itr_small[0] >> 1) : (GCD_itr_big[0] >> 1);
        GCD_itr_big[1] = ((GCD_itr_big[0] >> 1) >= (GCD_itr_small[0] >> 1)) ? (GCD_itr_big[0] >> 1) : (GCD_itr_small[0] >> 1);
        GCD_itr_cal[1] = GCD_itr_cal[0] + 1;
    end
    else if (~GCD_itr_big[0][0])begin
        GCD_itr_small[1] = ((GCD_itr_big[0] >> 1) >= (GCD_itr_small[0])) ? (GCD_itr_small[0]) : (GCD_itr_big[0] >> 1);
        GCD_itr_big[1] = ((GCD_itr_big[0] >> 1) >= (GCD_itr_small[0])) ? (GCD_itr_big[0] >> 1) : (GCD_itr_small[0]);
        GCD_itr_cal[1] = GCD_itr_cal[0];
    end
    else if (~GCD_itr_small[0][0])begin
        GCD_itr_small[1] = ((GCD_itr_big[0]) >= (GCD_itr_small[0] >> 1)) ? (GCD_itr_small[0] >> 1) : (GCD_itr_big[0]);
        GCD_itr_big[1] = ((GCD_itr_big[0]) >= (GCD_itr_small[0] >> 1)) ? (GCD_itr_big[0]) : (GCD_itr_small[0] >> 1);
        GCD_itr_cal[1] = GCD_itr_cal[0];
    end
    else begin
        GCD_itr_small[1] = (((GCD_itr_big[0] - GCD_itr_small[0]) >> 1) >= GCD_itr_small[0]) ? GCD_itr_small[0] : ((GCD_itr_big[0] - GCD_itr_small[0]) >> 1);
        GCD_itr_big[1] = (((GCD_itr_big[0] - GCD_itr_small[0]) >> 1) >= GCD_itr_small[0]) ? ((GCD_itr_big[0] - GCD_itr_small[0]) >> 1) : GCD_itr_small[0];
        GCD_itr_cal[1] = GCD_itr_cal[0];
    end

    if (~(GCD_itr_big[1][0] | GCD_itr_small[1][0])) begin
        GCD_itr_small[2] = ((GCD_itr_big[1] >> 1) >= (GCD_itr_small[1] >> 1)) ? (GCD_itr_small[1] >> 1) : (GCD_itr_big[1] >> 1);
        GCD_itr_big[2] = ((GCD_itr_big[1] >> 1) >= (GCD_itr_small[1] >> 1)) ? (GCD_itr_big[1] >> 1) : (GCD_itr_small[1] >> 1);
        GCD_itr_cal[2] = GCD_itr_cal[1] + 1;
    end
    else if (~GCD_itr_big[1][0])begin
        GCD_itr_small[2] = ((GCD_itr_big[1] >> 1) >= (GCD_itr_small[1])) ? (GCD_itr_small[1]) : (GCD_itr_big[1] >> 1);
        GCD_itr_big[2] = ((GCD_itr_big[1] >> 1) >= (GCD_itr_small[1])) ? (GCD_itr_big[1] >> 1) : (GCD_itr_small[1]);
        GCD_itr_cal[2] = GCD_itr_cal[1];
    end
    else if (~GCD_itr_small[1][0])begin
        GCD_itr_small[2] = ((GCD_itr_big[1]) >= (GCD_itr_small[1] >> 1)) ? (GCD_itr_small[1] >> 1) : (GCD_itr_big[1]);
        GCD_itr_big[2] = ((GCD_itr_big[1]) >= (GCD_itr_small[1] >> 1)) ? (GCD_itr_big[1]) : (GCD_itr_small[1] >> 1);
        GCD_itr_cal[2] = GCD_itr_cal[1];
    end
    else begin
        GCD_itr_small[2] = (((GCD_itr_big[1] - GCD_itr_small[1]) >> 1) >= GCD_itr_small[1]) ? GCD_itr_small[1] : ((GCD_itr_big[1] - GCD_itr_small[1]) >> 1);
        GCD_itr_big[2] = (((GCD_itr_big[1] - GCD_itr_small[1]) >> 1) >= GCD_itr_small[1]) ? ((GCD_itr_big[1] - GCD_itr_small[1]) >> 1) : GCD_itr_small[1];
        GCD_itr_cal[2] = GCD_itr_cal[1];
    end
end
endmodule