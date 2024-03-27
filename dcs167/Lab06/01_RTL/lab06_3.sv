module lab06_3(
  // Input signals
	clk,
	rst_n,
    in_number,
    mode,
    in_valid,
  // Output signals
	out_valid,
	out_result
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk,rst_n,in_valid;
input signed[3:0] in_number;
input [1:0] mode;
output logic signed [5:0] out_result;
output logic out_valid;
//---------------------------------------------------------------------
//   LOGIC DECLARATION                         
//---------------------------------------------------------------------
logic signed[3:0] in_1, in_2, in_3, in_4;
logic signed[3:0] sort_1, sort_2, sort_3, sort_4;
logic [1:0] mode_ff;
logic signed [6:0] cal_result;
logic go_cal,go_cal1,go_cal2,go_cal3,go_idle,go_out;
logic [2:0]current_state,next_state;
logic test;
assign test =0;
//---------------------------------------------------------------------
//   State DECLARATION                         
//---------------------------------------------------------------------
parameter IDLE = 3'd0,
         CAL = 3'd1,
         OUT = 3'd2;
//---------------------------------------------------------------------
//   Finite State Machine                        
//---------------------------------------------------------------------
//State Register
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        current_state <= IDLE;
    else
        current_state <= next_state;
end
//Next state logic
always_comb begin
        case(current_state)
        IDLE: if (go_cal) next_state = CAL;
            else next_state = IDLE;
        CAL: if (go_out) next_state = OUT;
            else next_state = CAL;
        OUT:   next_state = IDLE;
             
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        in_4<=0;
        in_3<=0;
        in_2<=0;
        in_1<=0;
 
        mode_ff<=0;
    end
    else begin
        if (current_state == IDLE) begin
            if (in_valid) begin
                in_4<=in_number;
                in_3<=in_4;
                in_2<=in_3;
                in_1<=in_2;
                mode_ff<=mode;
                
                go_cal1<=1;
      
                go_cal2<=go_cal1;
                go_cal3<=go_cal2;
                go_cal<=go_cal3;
                
            end
        end
        else begin
            go_cal1<=0;
            go_cal2<=0;
            go_cal3<=0;
            go_cal<=0;
        end
    end
end

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid<=0;
        out_result<=0;
    end
    else begin
        if (current_state==OUT)begin
            out_valid<=1;
            out_result<=cal_result;

        end
        else if(current_state==IDLE) begin
            if(in_number>0)begin
                out_valid<=1;
                out_result<=cal_result;
            end
        end
        else begin
            out_valid<=1'bx;
            out_result<=0;
        end
    end
end

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        go_out<=0;
    end
    else begin
        if (current_state==CAL)begin
            go_out <= 1;

        end
        else begin
            go_out<=0;

        end
    end
end

 


Sort sort(.in_num0(in_1),.in_num1(in_2),.in_num2(in_3),.in_num3(in_4),.out_num0(sort_1),.out_num1(sort_2),.out_num2(sort_3),.out_num3(sort_4));



always_comb begin
    
    case(mode_ff)
        'd0: cal_result = sort_1 + sort_2;
        'd1: cal_result = sort_2 - sort_1;
        'd2: cal_result = (sort_4-sort_3) ;
        'd3: cal_result = sort_1 - sort_4;
       
    endcase

end



endmodule







module Sort(
    // Input signals
	in_num0,
	in_num1,
	in_num2,
	in_num3,
    // Output signals
	out_num0,
	out_num1,
	out_num2,
	out_num3
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input  signed[3:0] in_num0, in_num1, in_num2, in_num3;
output logic signed[3:0] out_num0, out_num1, out_num2, out_num3;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic signed[3:0] lv0_n0, lv0_n1, lv0_n2, lv0_n3;
logic signed[3:0] lv1_n0, lv1_n1, lv1_n2, lv1_n3;
logic signed[3:0] lv2_n0, lv2_n1, lv2_n2, lv2_n3;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
comparator 	comp_lv0_0(.in_0(in_num0), .in_1(in_num1), .out_0(lv0_n0),   .out_1(lv0_n1)),
			comp_lv0_1(.in_0(in_num2), .in_1(in_num3), .out_0(lv0_n2),   .out_1(lv0_n3)),
			comp_lv1_0(.in_0(lv0_n1),  .in_1(lv0_n2),  .out_0(lv1_n1),   .out_1(lv1_n2)),
			comp_lv2_0(.in_0(lv0_n0),  .in_1(lv1_n1),  .out_0(out_num0), .out_1(lv2_n1)),
			comp_lv2_1(.in_0(lv1_n2),  .in_1(lv0_n3),  .out_0(lv2_n2),   .out_1(out_num3)),
			comp_lv3_0(.in_0(lv2_n1),  .in_1(lv2_n2),  .out_0(out_num1), .out_1(out_num2));
endmodule

module comparator(
	in_0,
	in_1,
	out_0,
	out_1
);

input  signed [3:0] in_0, in_1;
output logic signed[3:0] out_0, out_1;

assign out_0 = (in_0 <= in_1) ? in_0 : in_1;
assign out_1 = (in_0 <= in_1) ? in_1 : in_0;

endmodule

