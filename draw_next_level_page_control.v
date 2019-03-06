
module draw_next_level_page_control(
    input clk,
    input resetn,
    input start_next_level_page,
    input draw_object_done,

    output reg [4:0] next_level_page_type,
    output reg start_draw_next_level, next_level_page_done,
    output reg [8:0] x_next_level,
    output reg [7:0] y_next_level
	
    );

    reg [4:0] current_state, next_state; 

    localparam  S_WAIT_FOR_COMMAND		= 5'd0,
		S_LOAD_L1			= 5'd1,
		S_DRAW_L1			= 5'd2,
		S_LOAD_E1			= 5'd3,
		S_DRAW_E1			= 5'd4,
		S_LOAD_V			= 5'd5,
		S_DRAW_V			= 5'd6,
		S_LOAD_E2			= 5'd7,
		S_DRAW_E2			= 5'd8,
		S_LOAD_L2			= 5'd9,
		S_DRAW_L2			= 5'd10,
		S_LOAD_U			= 5'd11,
		S_DRAW_U			= 5'd12,
		S_LOAD_P			= 5'd13,
		S_DRAW_P			= 5'd14,
		
		S_DONE_DRAW_NEXT_LEVEL_PAGE	= 5'd15;  
					 

    // Next state logic aka our state table
    always@(*)
    begin: state_table 
		case (current_state)
					
			S_WAIT_FOR_COMMAND: next_state = start_next_level_page? S_LOAD_L1: S_WAIT_FOR_COMMAND;

			S_LOAD_L1: next_state = S_DRAW_L1;
			S_DRAW_L1: next_state = draw_object_done? S_LOAD_E1: S_DRAW_L1;			
			S_LOAD_E1: next_state = S_DRAW_E1;		
			S_DRAW_E1: next_state = draw_object_done? S_LOAD_V: S_DRAW_E1;		
			S_LOAD_V: next_state = S_DRAW_V;		
			S_DRAW_V: next_state = draw_object_done? S_LOAD_E2: S_DRAW_V;				
			S_LOAD_E2: next_state = S_DRAW_E2;		
			S_DRAW_E2: next_state = draw_object_done? S_LOAD_L2: S_DRAW_E2;			
			S_LOAD_L2: next_state = S_DRAW_L2;		
			S_DRAW_L2: next_state = draw_object_done? S_LOAD_U: S_DRAW_L2;			
			S_LOAD_U: next_state = S_DRAW_U;			
			S_DRAW_U: next_state = draw_object_done? S_LOAD_P: S_DRAW_U;			
			S_LOAD_P: next_state = S_DRAW_P;			
			S_DRAW_P: next_state = draw_object_done? S_DONE_DRAW_NEXT_LEVEL_PAGE: S_DRAW_P;			


			S_DONE_DRAW_NEXT_LEVEL_PAGE: next_state = start_next_level_page? S_DONE_DRAW_NEXT_LEVEL_PAGE: S_WAIT_FOR_COMMAND;					
			
            default:   next_state = S_WAIT_FOR_COMMAND;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0

    		start_draw_next_level = 1'b0;
		next_level_page_done = 1'b0;	
		x_next_level = 9'b0;
     		y_next_level = 8'b0;
		next_level_page_type = 5'd0;

        case (current_state)
		  
		S_DRAW_L1: begin
			start_draw_next_level = 1'b1;
			x_next_level = 9'd121;
			y_next_level = 8'd91;
			next_level_page_type = 5'd21; 		
		end

		S_DRAW_E1: begin
			start_draw_next_level = 1'b1;
			x_next_level = 9'd131;
			y_next_level = 8'd91;
			next_level_page_type = 5'd17; 	
		end

		S_DRAW_V: begin
			start_draw_next_level = 1'b1;
			x_next_level = 9'd145;
			y_next_level = 8'd91;
			next_level_page_type = 5'd28; 	
		end

		S_DRAW_E2: begin
			start_draw_next_level = 1'b1;
			x_next_level = 9'd157;
			y_next_level = 8'd91;
			next_level_page_type = 5'd17; 	
		end

		S_DRAW_L2: begin
			start_draw_next_level = 1'b1;
			x_next_level = 9'd169;
			y_next_level = 8'd91;
			next_level_page_type = 5'd21; 	
		end

		S_DRAW_U: begin
			start_draw_next_level = 1'b1;
			x_next_level = 9'd139;
			y_next_level = 8'd115;
			next_level_page_type = 5'd27; 	
		end

		S_DRAW_P: begin
			start_draw_next_level = 1'b1;
			x_next_level = 9'd151;
			y_next_level = 8'd115;
			next_level_page_type = 5'd24; 	 
		end

		S_DONE_DRAW_NEXT_LEVEL_PAGE: next_level_page_done = 1'b1;
		 

        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_WAIT_FOR_COMMAND;
        else
            current_state <= next_state;
    end // state_FFS
	 
endmodule

