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

parameter [1:0] IDLE = 0, EX = 1, WB = 2;
logic [1:0] state, state_nxt;

logic out_valid_nxt, instruction_fail_nxt;

logic [95:0] regfile, regfile_nxt;
// addr: 10001, 10010, 01000, 10111, 11111, 10000 

logic [5:0]  opcode;
logic [4:0]  rs, rt, rd;
logic [3:0]  shamt;
logic [6:0]  funct;
logic [15:0] imm;

logic [15:0] rs_val, rt_val, wb_nxt;
logic [4:0]  wb_addr;

logic gcd_A, gcd_B;

logic [3:0] out_addr     [3:0];
logic [3:0] out_addr_nxt [3:0];

function [2:0] short_addr;
    input [4:0] addr_org;
    case (addr_org) 
        5'b10001: short_addr = 6;
        5'b10010: short_addr = 5;
        5'b01000: short_addr = 4;
        5'b10111: short_addr = 3;
        5'b11111: short_addr = 2;
        5'b10000: short_addr = 1;
        default:  short_addr = 0;
    endcase
endfunction

function [15:0] short_addr_val;
    input [2:0] short_addr;
    case (short_addr) 
        3'h6: short_addr_val = regfile[95:80];
        3'h5: short_addr_val = regfile[79:64];
        3'h4: short_addr_val = regfile[63:48];
        3'h3: short_addr_val = regfile[47:32];
        3'h2: short_addr_val = regfile[31:16];
        3'h1: short_addr_val = regfile[15:0];
        default:  short_addr_val = 0;
    endcase
endfunction

always_comb begin
    state_nxt = state;
    instruction_fail_nxt = 0;
    regfile_nxt = regfile;
    {out_addr_nxt[0], out_addr_nxt[1], out_addr_nxt[2], out_addr_nxt[3]} = 'h0;
    out_valid_nxt = 0;

    {opcode, rs, rt, rd, shamt, funct} = instruction;
    imm = instruction[15:0];
    
    case (state) 
        IDLE: begin
            if (in_valid) begin
                case (rs) 
                    5'b10001: rs_val = regfile[95:80];
                    5'b10010: rs_val = regfile[79:64];
                    5'b01000: rs_val = regfile[63:48];
                    5'b10111: rs_val = regfile[47:32];
                    5'b11111: rs_val = regfile[31:16];
                    5'b10000: rs_val = regfile[15:0];
                    default: begin
                        instruction_fail_nxt = 1;
                        rs_val = 'hx;
                    end
                endcase

                case (rt) 
                    5'b10001: rt_val = regfile[95:80];
                    5'b10010: rt_val = regfile[79:64];
                    5'b01000: rt_val = regfile[63:48];
                    5'b10111: rt_val = regfile[47:32];
                    5'b11111: rt_val = regfile[31:16];
                    5'b10000: rt_val = regfile[15:0];
                    default: begin
                        instruction_fail_nxt = 1;
                        rt_val = 'hx;
                    end
                endcase
                wb_addr = 'hx;
                wb_nxt = 'hx;
                case (opcode) 
                    6'b000000: begin
                        wb_addr = rd;
                        case (funct) 
                            7'b0100000: wb_nxt = rs_val + rt_val;
                            7'b0100100: wb_nxt = rs_val & rt_val;
                            7'b0100101: wb_nxt = rs_val | rt_val;
                            7'b0100111: wb_nxt = ~(rs_val | rt_val);
                            7'b0000000: wb_nxt = rt_val << shamt;
                            7'b0000010: wb_nxt = rt_val >> shamt; 
                            7'b1111000: begin
                                wb_nxt = 0; // Not Implemented
                                if (rs_val == 0 | rt_val == 0) begin
                                    instruction_fail_nxt = 1;
                                end
                                else begin
                                    wb_nxt = 4;
                                    state_nxt = WB;
                                    out_valid_nxt = 0;
                                end
                            end
                            default: instruction_fail_nxt = 1;
                        endcase
                    end
                    6'b001000: begin
                        wb_addr = rt;
                        wb_nxt = rs_val + imm;
                    end
                    default: begin 
                        wb_nxt = 'hx;
                        instruction_fail_nxt = 1;
                    end
                endcase

                if (!instruction_fail_nxt) begin
                    out_addr_nxt[0] = short_addr(output_reg[4:0]);
                    out_addr_nxt[1] = short_addr(output_reg[9:5]);
                    out_addr_nxt[2] = short_addr(output_reg[14:10]);
                    out_addr_nxt[3] = short_addr(output_reg[19:15]);
                    case (wb_addr) 
                        5'b10001: regfile_nxt[95:80] = wb_nxt;
                        5'b10010: regfile_nxt[79:64] = wb_nxt;
                        5'b01000: regfile_nxt[63:48] = wb_nxt;
                        5'b10111: regfile_nxt[47:32] = wb_nxt;
                        5'b11111: regfile_nxt[31:16] = wb_nxt;
                        5'b10000: regfile_nxt[15:0]  = wb_nxt;
                        default: begin
                            regfile_nxt = regfile;
                            instruction_fail_nxt = 1;
                            {out_addr_nxt[0], out_addr_nxt[1], out_addr_nxt[2], out_addr_nxt[3]} = 'h0;
                        end
                    endcase
                end
                state_nxt = WB;
                out_valid_nxt = 1;
            end           
        end
        EX: begin
        end
        WB: begin
            state_nxt = IDLE;
        end
    endcase

    out_1 = short_addr_val(out_addr[0]);
    out_2 = short_addr_val(out_addr[1]);
    out_3 = short_addr_val(out_addr[2]);
    out_4 = short_addr_val(out_addr[3]);
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        state   <= IDLE;
        regfile <= 'h0;
        instruction_fail <= 0;
        {out_addr[0], out_addr[1], out_addr[2], out_addr[3]} <= 'h0;
        out_valid <= 0;
    end
    else begin
        state   <= state_nxt;
        regfile <= regfile_nxt;
        instruction_fail <= instruction_fail_nxt;
        {out_addr[0], out_addr[1], out_addr[2], out_addr[3]} <= {out_addr_nxt[0], out_addr_nxt[1], out_addr_nxt[2], out_addr_nxt[3]};
        out_valid <= out_valid_nxt;
    end
end

endmodule

