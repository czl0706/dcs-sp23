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

parameter [1:0] IDLE = 2, WB = 0, MOD = 1, OUT = 3;

// inter wires
logic [15:0] rs_val, rt_val;
logic [4:0] wb_addr; 
logic inst_fail;
//

wire [5:0]  opcode;
wire [4:0]  rs, rt, rd;
wire [3:0]  shamt;
wire [6:0]  funct;
wire [15:0] imm;

assign {opcode, rs, rt, rd, shamt, funct} = instruction;
assign imm = instruction[15:0];

logic [95:0] regfile, regfile_nxt;
// addr: 10001, 10010, 01000, 10111, 11111, 10000 

logic [3:0] out_addr     [3:0];
logic [3:0] out_addr_nxt [3:0];

logic out_valid_nxt, instruction_fail_nxt;

logic [1:0] state, state_nxt;

logic [15:0] wb_val_gcd_A, wb_val_gcd_A_nxt;
logic [2:0] sh_addr, sh_addr_nxt;

logic [15:0] gcd_B, gcd_B_nxt;
logic [3:0] fact_shift, fact_shift_nxt;

function [35:0] shift_sub;
    input [3:0] fact_shift;
    input [15:0] a;
    input [15:0] b;
    logic [15:0] a_nxt;
    logic [15:0] b_nxt;

    a_nxt = a;
    b_nxt = b;
    fact_shift_nxt = fact_shift;
    case ({a[0], b[0]}) 
        2'b00: begin
            fact_shift_nxt = fact_shift + 1;
            a_nxt = a >> 1;
            b_nxt = b >> 1;
        end
        2'b01: begin
            a_nxt = a >> 1;
        end
        2'b10: begin
            b_nxt = b >> 1;
        end
        2'b11: begin
            if (a > b) begin
                a_nxt = (a - b) >> 1;
                b_nxt = b;
            end
            else begin
                a_nxt = (b - a) >> 1;
                b_nxt = a;
            end
        end
    endcase
    shift_sub = {fact_shift_nxt, a_nxt, b_nxt};
endfunction

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
    instruction_fail_nxt = 0;
    out_valid_nxt = 0;
    regfile_nxt = regfile;
    state_nxt = state;
    {out_addr_nxt[0], out_addr_nxt[1], out_addr_nxt[2], out_addr_nxt[3]} = 
    {out_addr[0], out_addr[1], out_addr[2], out_addr[3]};
    sh_addr_nxt = sh_addr;
    wb_val_gcd_A_nxt = 0;

    wb_val_gcd_A_nxt = 0;
    gcd_B_nxt = 0;

    fact_shift_nxt = 0;

    case (state) 
        IDLE: begin
            if (in_valid) begin
                sh_addr_nxt = 0;
                inst_fail   = 0;
                state_nxt = WB;
                
                rs_val = 'hx;
                case (rs) 
                    5'b10001: rs_val = regfile[95:80];
                    5'b10010: rs_val = regfile[79:64];
                    5'b01000: rs_val = regfile[63:48];
                    5'b10111: rs_val = regfile[47:32];
                    5'b11111: rs_val = regfile[31:16];
                    5'b10000: rs_val = regfile[15:0];
                    default: begin
                        inst_fail = 1;
                    end
                endcase

                rt_val = 'hx;
                case (rt) 
                    5'b10001: rt_val = regfile[95:80];
                    5'b10010: rt_val = regfile[79:64];
                    5'b01000: rt_val = regfile[63:48];
                    5'b10111: rt_val = regfile[47:32];
                    5'b11111: rt_val = regfile[31:16];
                    5'b10000: rt_val = regfile[15:0];
                    default: begin
                        inst_fail = 1;
                    end
                endcase

                wb_addr = 'hx;
                wb_val_gcd_A_nxt = 'hx;

                case (opcode) 
                    6'b000000: begin
                        wb_addr = rd;
                        case (funct) 
                            7'b0100000: wb_val_gcd_A_nxt = rs_val + rt_val;
                            7'b0100100: wb_val_gcd_A_nxt = rs_val & rt_val;
                            7'b0100101: wb_val_gcd_A_nxt = rs_val | rt_val;
                            7'b0100111: wb_val_gcd_A_nxt = ~(rs_val | rt_val);
                            7'b0000000: wb_val_gcd_A_nxt = rt_val << shamt;
                            7'b0000010: wb_val_gcd_A_nxt = rt_val >> shamt; 
                            7'b1111000: begin
                                if (rs_val == 0 | rt_val == 0) begin
                                    inst_fail = 1;
                                    // wb_val_gcd_A_nxt = 0;
                                    state_nxt = WB;
                                end
                                else if (rs_val == rt_val) begin
                                    wb_val_gcd_A_nxt = rs_val;
                                    state_nxt = WB;
                                end
                                else begin
                                    state_nxt = MOD;
                                    fact_shift_nxt = 0;

                                    wb_val_gcd_A_nxt = rs_val;
                                    gcd_B_nxt = rt_val;

                                    {fact_shift_nxt, wb_val_gcd_A_nxt, gcd_B_nxt}
                                    = shift_sub(0, rs_val, rt_val);
                                    if (wb_val_gcd_A_nxt == gcd_B_nxt) begin
                                        wb_val_gcd_A_nxt = wb_val_gcd_A_nxt << fact_shift_nxt;
                                        state_nxt = WB;
                                    end
                                    else begin
                                        {fact_shift_nxt, wb_val_gcd_A_nxt, gcd_B_nxt}
                                        = shift_sub(fact_shift_nxt, wb_val_gcd_A_nxt, gcd_B_nxt);
                                        if (wb_val_gcd_A_nxt == gcd_B_nxt) begin
                                            wb_val_gcd_A_nxt = wb_val_gcd_A_nxt << fact_shift_nxt;
                                            state_nxt = WB;
                                        end
                                    end
                                end
                            end
                            default: inst_fail = 1;
                        endcase
                    end
                    6'b001000: begin
                        wb_addr = rt;
                        wb_val_gcd_A_nxt = rs_val + imm;
                    end
                    default: begin 
                        inst_fail = 1;
                    end
                endcase
                
                sh_addr_nxt = inst_fail ? 0 : short_addr(wb_addr);
                
                if (sh_addr_nxt) begin
                    out_addr_nxt[0] = short_addr(output_reg[4:0]);
                    out_addr_nxt[1] = short_addr(output_reg[9:5]);
                    out_addr_nxt[2] = short_addr(output_reg[14:10]);
                    out_addr_nxt[3] = short_addr(output_reg[19:15]);
                end
                else begin
                    state_nxt = WB;
                end
            end
        end
        WB: begin
            case (sh_addr) 
                3'h6: regfile_nxt[95:80] = wb_val_gcd_A;
                3'h5: regfile_nxt[79:64] = wb_val_gcd_A;
                3'h4: regfile_nxt[63:48] = wb_val_gcd_A;
                3'h3: regfile_nxt[47:32] = wb_val_gcd_A;
                3'h2: regfile_nxt[31:16] = wb_val_gcd_A;
                3'h1: regfile_nxt[15:0]  = wb_val_gcd_A;
                default: instruction_fail_nxt = 1;
            endcase
            out_valid_nxt = 1;
            state_nxt = OUT;
        end
        MOD: begin
            {fact_shift_nxt, wb_val_gcd_A_nxt, gcd_B_nxt} 
            = shift_sub(fact_shift, wb_val_gcd_A, gcd_B);

            if (wb_val_gcd_A_nxt == gcd_B_nxt) begin
                case (sh_addr) 
                    3'h6: regfile_nxt[95:80] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                    3'h5: regfile_nxt[79:64] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                    3'h4: regfile_nxt[63:48] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                    3'h3: regfile_nxt[47:32] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                    3'h2: regfile_nxt[31:16] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                    3'h1: regfile_nxt[15:0]  = (wb_val_gcd_A_nxt << fact_shift_nxt);
                    default: instruction_fail_nxt = 1;
                endcase
                out_valid_nxt = 1;
                state_nxt = OUT;
            end
            else begin
                {fact_shift_nxt, wb_val_gcd_A_nxt, gcd_B_nxt}
                = shift_sub(fact_shift_nxt, wb_val_gcd_A_nxt, gcd_B_nxt);
                if (wb_val_gcd_A_nxt == gcd_B_nxt) begin
                    case (sh_addr) 
                        3'h6: regfile_nxt[95:80] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                        3'h5: regfile_nxt[79:64] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                        3'h4: regfile_nxt[63:48] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                        3'h3: regfile_nxt[47:32] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                        3'h2: regfile_nxt[31:16] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                        3'h1: regfile_nxt[15:0]  = (wb_val_gcd_A_nxt << fact_shift_nxt);
                        default: instruction_fail_nxt = 1;
                    endcase
                    out_valid_nxt = 1;
                    state_nxt = OUT;
                end
                else begin
                    {fact_shift_nxt, wb_val_gcd_A_nxt, gcd_B_nxt}
                    = shift_sub(fact_shift_nxt, wb_val_gcd_A_nxt, gcd_B_nxt);
                    if (wb_val_gcd_A_nxt == gcd_B_nxt) begin
                        case (sh_addr) 
                            3'h6: regfile_nxt[95:80] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                            3'h5: regfile_nxt[79:64] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                            3'h4: regfile_nxt[63:48] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                            3'h3: regfile_nxt[47:32] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                            3'h2: regfile_nxt[31:16] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                            3'h1: regfile_nxt[15:0]  = (wb_val_gcd_A_nxt << fact_shift_nxt);
                            default: instruction_fail_nxt = 1;
                        endcase
                        out_valid_nxt = 1;
                        state_nxt = OUT;
                    end
                    else begin
                        {fact_shift_nxt, wb_val_gcd_A_nxt, gcd_B_nxt}
                        = shift_sub(fact_shift_nxt, wb_val_gcd_A_nxt, gcd_B_nxt);
                        if (wb_val_gcd_A_nxt == gcd_B_nxt) begin
                            case (sh_addr) 
                                3'h6: regfile_nxt[95:80] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                                3'h5: regfile_nxt[79:64] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                                3'h4: regfile_nxt[63:48] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                                3'h3: regfile_nxt[47:32] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                                3'h2: regfile_nxt[31:16] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                                3'h1: regfile_nxt[15:0]  = (wb_val_gcd_A_nxt << fact_shift_nxt);
                                default: instruction_fail_nxt = 1;
                            endcase
                            out_valid_nxt = 1;
                            state_nxt = OUT;
                        end
                        else begin
                            {fact_shift_nxt, wb_val_gcd_A_nxt, gcd_B_nxt}
                            = shift_sub(fact_shift_nxt, wb_val_gcd_A_nxt, gcd_B_nxt);
                            if (wb_val_gcd_A_nxt == gcd_B_nxt) begin
                                case (sh_addr) 
                                    3'h6: regfile_nxt[95:80] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                                    3'h5: regfile_nxt[79:64] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                                    3'h4: regfile_nxt[63:48] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                                    3'h3: regfile_nxt[47:32] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                                    3'h2: regfile_nxt[31:16] = (wb_val_gcd_A_nxt << fact_shift_nxt);
                                    3'h1: regfile_nxt[15:0]  = (wb_val_gcd_A_nxt << fact_shift_nxt);
                                    default: instruction_fail_nxt = 1;
                                endcase
                                out_valid_nxt = 1;
                                state_nxt = OUT;
                            end
                            else begin
                            end
                        end
                    end
                end
            end
      
        end
        OUT: begin
            state_nxt = IDLE;
        end
    endcase
end

always_comb begin
    out_1 = out_valid && !instruction_fail ? short_addr_val(out_addr[0]) : 0;
    out_2 = out_valid && !instruction_fail ? short_addr_val(out_addr[1]) : 0;
    out_3 = out_valid && !instruction_fail ? short_addr_val(out_addr[2]) : 0;
    out_4 = out_valid && !instruction_fail ? short_addr_val(out_addr[3]) : 0;
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        regfile <= 'h0;
    end
    else begin
        regfile <= regfile_nxt;
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        state   <= IDLE;
        out_valid <= 0;
        instruction_fail <= 0;
    end
    else begin
        state   <= state_nxt;
        out_valid <= out_valid_nxt;
        instruction_fail <= instruction_fail_nxt;
    end
end

always_ff @(posedge clk) begin
    {out_addr[0], out_addr[1], out_addr[2], out_addr[3]} <= 
    {out_addr_nxt[0], out_addr_nxt[1], out_addr_nxt[2], out_addr_nxt[3]};
    sh_addr <= sh_addr_nxt;
    wb_val_gcd_A  <= wb_val_gcd_A_nxt;
    gcd_B <= gcd_B_nxt;
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        fact_shift <= 0;
    end
    else begin
        fact_shift <= fact_shift_nxt;
    end
end

endmodule