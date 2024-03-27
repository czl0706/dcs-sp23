module TL(
  // Input signals
  clk,
  rst_n,
  in_valid,
  car_main_s,
  car_main_lt,
  car_side_s,
  car_side_lt,
  // Output signals
  out_valid,
  light_main,
  light_side
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [2:0] car_main_s, car_main_lt, car_side_s, car_side_lt; 
output logic out_valid;
output logic [1:0] light_main, light_side;

parameter [1:0] RED = 0, YELLOW = 1, GREEN = 2, LEFT = 3;
logic     [1:0] light_main_nxt, light_side_nxt;
logic out_valid_nxt;

logic [3:0] cnt_main_lt, cnt_side_s, cnt_side_lt;
logic [3:0] cnt_main_lt_nxt, cnt_side_s_nxt, cnt_side_lt_nxt; 

logic tl_start, tl_start_nxt;

logic [3:0] cnter, cnter_nxt, cnt_in;
logic cnt_done;

logic main_lt_wait, side_s_wait, side_lt_wait;
assign main_lt_wait = |cnt_main_lt; 
assign side_s_wait  = |cnt_side_s;
assign side_lt_wait = |cnt_side_lt;

always_comb begin
  cnt_in = 0;
  out_valid_nxt  = 0;
  tl_start_nxt   = 0;
  light_main_nxt = light_main;
  light_side_nxt = light_side;
  {cnt_main_lt_nxt, cnt_side_s_nxt, cnt_side_lt_nxt} = {cnt_main_lt, cnt_side_s, cnt_side_lt};
  
  if (tl_start) begin
    tl_start_nxt = 1;
    out_valid_nxt = 1;

    case (light_side) 
      GREEN:  begin
        if (cnt_done) begin
          light_side_nxt = YELLOW;
          cnt_side_s_nxt = 0;
        end
      end
      LEFT:   begin
        if (cnt_done) begin
          light_side_nxt = YELLOW;
          cnt_side_lt_nxt = 0;
        end
      end
      YELLOW: begin
        light_side_nxt = RED;
        if (~(light_main == GREEN | main_lt_wait))
          cnt_in = 2;
      end
      RED:    begin
        if (~(light_main == GREEN | main_lt_wait)) begin 
          if (side_s_wait) begin
            if (cnt_done) begin
              light_side_nxt = GREEN;
              cnt_in = cnt_side_s;
            end
          end
          else if (side_lt_wait) begin
            if (cnt_done) begin
              light_side_nxt = LEFT;
              cnt_in = cnt_side_lt;
            end
          end
        end
      end
    endcase

    case (light_main) 
      GREEN:  begin
        if (~(main_lt_wait | side_s_wait | side_lt_wait) & cnt_done)
          tl_start_nxt = 0;
        else if (cnt_done)
          light_main_nxt = YELLOW;
      end
      LEFT:   begin
        if (cnt_done) begin
          light_main_nxt = YELLOW;
          cnt_main_lt_nxt = 0;
        end
      end
      YELLOW: begin
        light_main_nxt = RED;
        if (main_lt_wait) 
          cnt_in = 2;
        else if (side_s_wait | side_lt_wait) 
          cnt_in = 1;
        else 
          cnt_in = 2;
      end
      RED:    begin
        if (main_lt_wait & cnt_done) begin
          light_main_nxt = LEFT;
          cnt_in = cnt_main_lt;
        end
        else if (~(side_s_wait | side_lt_wait) & cnt_done) begin
          light_main_nxt = GREEN;
          tl_start_nxt = 0;
        end
      end
    endcase
  end
  else if (in_valid) begin
    cnt_main_lt_nxt = ((car_main_lt/3) + |(car_main_lt%3)) * 3;
    cnt_side_s_nxt  = (( car_side_s/3) + |( car_side_s%3)) * 3;
    cnt_side_lt_nxt = ((car_side_lt/2) + |(car_side_lt%2)) * 2;
    
    if (|car_main_s) 
      cnt_in = ((car_main_s/4) + |(car_main_s%4)) * 4;
    else 
      cnt_in = |{car_main_lt, car_side_s, car_side_lt} ? 4'd4 : 4'd0;

    cnt_in = cnt_in + 1;
    tl_start_nxt = 1;
  end
end

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    light_main <= GREEN;
  end 
  else begin
    light_main <= light_main_nxt;
  end       
end

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    light_side <= RED;
  end 
  else begin
    light_side <= light_side_nxt;
  end       
end

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    out_valid  <= 0;
  end 
  else begin
    out_valid  <= out_valid_nxt;
  end       
end

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    tl_start   <= 0;
  end 
  else begin
    tl_start   <= tl_start_nxt;
  end       
end

assign cnter_nxt = (cnt_in) ? cnt_in : cnter - 1;
assign cnt_done  = (cnter == 1);
always_ff @(posedge clk) begin
  cnt_main_lt <= cnt_main_lt_nxt;
  cnt_side_s  <= cnt_side_s_nxt;
  cnt_side_lt <= cnt_side_lt_nxt;
  cnter       <= cnter_nxt;
end

endmodule