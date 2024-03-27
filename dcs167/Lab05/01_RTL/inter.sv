module inter(
  // Input signals
  clk,
  rst_n,
  in_valid_1,
  in_valid_2,
  data_in_1,
  data_in_2,
  ready_slave1,
  ready_slave2,
  // Output signals
  valid_slave1,
  valid_slave2,
  addr_out,
  value_out,
  handshake_slave1,
  handshake_slave2
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid_1, in_valid_2;
input [6:0] data_in_1, data_in_2; 
input ready_slave1, ready_slave2;

output logic valid_slave1, valid_slave2;
output logic [2:0] addr_out, value_out;
output logic handshake_slave1, handshake_slave2;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

logic     [1:0] cur_state, nxt_state;
parameter [1:0] S_IDLE = 0, S_wait = 1, S_handshake = 2;

logic valid_slave1_nxt, valid_slave2_nxt;
logic handshake_slave1_nxt, handshake_slave2_nxt;
logic [2:0] addr_out_nxt, value_out_nxt;

logic [6:0] data_1_reg, data_1_reg_nxt;
logic [6:0] data_2_reg, data_2_reg_nxt;
logic in1, in1_nxt;
logic in2, in2_nxt;

always_comb begin
  data_1_reg_nxt = data_1_reg;
  data_2_reg_nxt = data_2_reg;
  in1_nxt = in1;
  in2_nxt = in2;

  if (in_valid_1) begin
    data_1_reg_nxt = data_in_1;
    in1_nxt = 1;
  end
  if (in_valid_2) begin
    data_2_reg_nxt = data_in_2;
    in2_nxt = 1;
  end

  if (handshake_slave1 || handshake_slave2) begin
    if (in1) begin
      data_1_reg_nxt = 0;
      in1_nxt = 0;
    end
    else if (in2) begin
      data_2_reg_nxt = 0;
      in2_nxt = 0;
    end
  end
end

always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    data_1_reg <= 0;
    data_2_reg <= 0;
    in1 <= 0;
    in2 <= 0;
  end
  else begin
    data_1_reg <= data_1_reg_nxt;
    data_2_reg <= data_2_reg_nxt;
    in1 <= in1_nxt;
    in2 <= in2_nxt;
  end
end

logic targ_in_reg1;
logic [2:0] addr_in_reg1, val_in_reg1;
logic targ_in_reg2;
logic [2:0] addr_in_reg2, val_in_reg2;

assign {targ_in_reg1, addr_in_reg1, val_in_reg1} = data_1_reg;
assign {targ_in_reg2, addr_in_reg2, val_in_reg2} = data_2_reg;

always_comb begin
  nxt_state = cur_state;
  valid_slave1_nxt = valid_slave1;
  valid_slave2_nxt = valid_slave2;
  handshake_slave1_nxt = handshake_slave1;
  handshake_slave2_nxt = handshake_slave2;
  addr_out_nxt = addr_out;
  value_out_nxt = value_out;

  case (cur_state)
    S_IDLE: begin
      if (in1) begin
        nxt_state = S_wait;
        addr_out_nxt  = addr_in_reg1;
        value_out_nxt = val_in_reg1;
        valid_slave1_nxt = (targ_in_reg1 == 0);
        valid_slave2_nxt = (targ_in_reg1 == 1);
      end
      else if (in2) begin
        nxt_state = S_wait;
        addr_out_nxt  = addr_in_reg2;
        value_out_nxt = val_in_reg2;
        valid_slave1_nxt = (targ_in_reg2 == 0);
        valid_slave2_nxt = (targ_in_reg2 == 1);
      end
    end

    S_wait: begin
      if (ready_slave1 && valid_slave1) begin
        handshake_slave1_nxt = 1;
        nxt_state = S_handshake;
        valid_slave1_nxt = 0;
      end 
      else if (ready_slave2 && valid_slave2) begin
        handshake_slave2_nxt = 1;
        nxt_state = S_handshake;
        valid_slave2_nxt = 0;
      end 
    end

    S_handshake: begin
      if (handshake_slave1 || handshake_slave2) begin
        handshake_slave1_nxt = 0;
        handshake_slave2_nxt = 0;
        // valid_slave1_nxt = 0;
        // valid_slave2_nxt = 0;
      end 

      else begin
        if (in1) begin
          nxt_state = S_wait;
          addr_out_nxt  = addr_in_reg1;
          value_out_nxt = val_in_reg1;
          valid_slave1_nxt = (targ_in_reg1 == 0);
          valid_slave2_nxt = (targ_in_reg1 == 1);
        end
        else if (in2) begin
          nxt_state = S_wait;
          addr_out_nxt  = addr_in_reg2;
          value_out_nxt = val_in_reg2;
          valid_slave1_nxt = (targ_in_reg2 == 0);
          valid_slave2_nxt = (targ_in_reg2 == 1);
        end
      end
    end
  endcase
end

always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n) cur_state <= S_IDLE;
  else        cur_state <= nxt_state;
end

always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    valid_slave1 <= 0;
    valid_slave2 <= 0;
    handshake_slave1 <= 0;
    handshake_slave2 <= 0;
  end
  else begin 
    valid_slave1 <= valid_slave1_nxt;
    valid_slave2 <= valid_slave2_nxt;
    handshake_slave1 <= handshake_slave1_nxt;
    handshake_slave2 <= handshake_slave2_nxt;
  end
end

always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    addr_out <= 0;
    value_out <= 0;
  end
  else begin
    addr_out <= addr_out_nxt;
    value_out <= value_out_nxt;
  end
end

endmodule
