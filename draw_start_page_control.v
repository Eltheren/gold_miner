
module draw_start_page_control(
    input clk,
    input resetn,
    input start_page_module,
    input draw_object_done,

    output reg [4:0] start_page_type,
    output reg start_draw_start_page, start_page_done,
    output reg [8:0] x_start_page,
    output reg [7:0] y_start_page
	
    );

    reg [4:0] current_state, next_state; 

    localparam  S_WAIT_FOR_COMMAND		= 5'd0,
		S_LOAD_E1			= 5'd1,
		S_DRAW_E1			= 5'd2,
		S_LOAD_N1			= 5'd3,
		S_DRAW_N1			= 5'd4,
		S_LOAD_T1			= 5'd5,
		S_DRAW_T1			= 5'd6,
		S_LOAD_E2			= 5'd7,
		S_DRAW_E2			= 5'd8,
		S_LOAD_R			= 5'd9,
		S_DRAW_R			= 5'd10,
		S_LOAD_T2			= 5'd11,
		S_DRAW_T2			= 5'd12,
		S_LOAD_O			= 5'd13,
		S_DRAW_O			= 5'd14,
		S_LOAD_B			= 5'd15,
		S_DRAW_B			= 5'd16,
		S_LOAD_E3			= 5'd17,
		S_DRAW_E3			= 5'd18,
		S_LOAD_G			= 5'd19,
		S_DRAW_G			= 5'd20,
		S_LOAD_I			= 5'd21,
		S_DRAW_I			= 5'd22,
		S_LOAD_N2			= 5'd23,
		S_DRAW_N2			= 5'd24,
		
		S_DONE_DRAW_START_PAGE	= 5'd25;  
					 

    // Next state logic aka our state table
    always@(*)
    begin: state_table 
		case (current_state)
					
			S_WAIT_FOR_COMMAND: next_state = start_page_module? S_LOAD_E1: S_WAIT_FOR_COMMAND;

			S_LOAD_E1: next_state = S_DRAW_E1;
			S_DRAW_E1: next_state = draw_object_done? S_LOAD_N1: S_DRAW_E1;			
			S_LOAD_N1: next_state = S_DRAW_N1;		
			S_DRAW_N1: next_state = draw_object_done? S_LOAD_T1: S_DRAW_N1;		
			S_LOAD_T1: next_state = S_DRAW_T1;		
			S_DRAW_T1: next_state = draw_object_done? S_LOAD_E2: S_DRAW_T1;				
			S_LOAD_E2: next_state = S_DRAW_E2;		
			S_DRAW_E2: next_state = draw_object_done? S_LOAD_R: S_DRAW_E2;			
			S_LOAD_R: next_state = S_DRAW_R;		
			S_DRAW_R: next_state = draw_object_done? S_LOAD_T2: S_DRAW_R;			
			S_LOAD_T2: next_state = S_DRAW_T2;			
			S_DRAW_T2: next_state = draw_object_done? S_LOAD_O: S_DRAW_T2;			
			S_LOAD_O: next_state = S_DRAW_O;			
			S_DRAW_O: next_state = draw_object_done? S_LOAD_B: S_DRAW_O;			
			S_LOAD_B: next_state = S_DRAW_B;			
			S_DRAW_B: next_state = draw_object_done? S_LOAD_E3: S_DRAW_B;				
			S_LOAD_E3: next_state = S_DRAW_E3;			
			S_DRAW_E3: next_state = draw_object_done? S_LOAD_G: S_DRAW_E3;			
			S_LOAD_G: next_state = S_DRAW_G;			
			S_DRAW_G: next_state = draw_object_done? S_LOAD_I: S_DRAW_G;				
			S_LOAD_I: next_state = S_DRAW_I;		
			S_DRAW_I: next_state = draw_object_done? S_LOAD_N2: S_DRAW_I;				
			S_LOAD_N2: next_state = S_DRAW_N2;			
			S_DRAW_N2: next_state = draw_object_done? S_DONE_DRAW_START_PAGE: S_DRAW_N2;

			S_DONE_DRAW_START_PAGE: next_state = start_page_module? S_DONE_DRAW_START_PAGE: S_WAIT_FOR_COMMAND;					
			
            default:   next_state = S_WAIT_FOR_COMMAND;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0

    		start_draw_start_page = 1'b0;
		start_page_done = 1'b0;	
		x_start_page = 9'b0;
     		y_start_page = 8'b0;
		start_page_type = 5'd0;

        case (current_state)
		  
		S_DRAW_E1: begin
			start_draw_start_page = 1'b1;
			x_start_page = 9'd110;
			y_start_page = 8'd76;
			start_page_type = 5'd17; 		
		end

		S_DRAW_N1: begin
			start_draw_start_page = 1'b1;
			x_start_page = 9'd122;
			y_start_page = 8'd76;
			start_page_type = 5'd22; 
		end

		S_DRAW_T1: begin
			start_draw_start_page = 1'b1;
			x_start_page = 9'd134;
			y_start_page = 8'd76;
			start_page_type = 5'd26; 
		end

		S_DRAW_E2: begin
			start_draw_start_page = 1'b1;
			x_start_page = 9'd146;
			y_start_page = 8'd76;
			start_page_type = 5'd17; 
		end

		S_DRAW_R: begin
			start_draw_start_page = 1'b1;
			x_start_page = 9'd158;
			y_start_page = 8'd76;
			start_page_type = 5'd25; 
		end

		S_DRAW_T2: begin
			start_draw_start_page = 1'b1;
			x_start_page = 9'd128;
			y_start_page = 8'd100;
			start_page_type = 5'd26; 
		end

		S_DRAW_O: begin
			start_draw_start_page = 1'b1;
			x_start_page = 9'd140;
			y_start_page = 8'd100;
			start_page_type = 5'd23; 
		end

		S_DRAW_B: begin
			start_draw_start_page = 1'b1;
			x_start_page = 9'd110;
			y_start_page = 8'd121;
			start_page_type = 5'd16; 
		end

		S_DRAW_E3: begin
			start_draw_start_page = 1'b1;
			x_start_page = 9'd122;
			y_start_page = 8'd121;
			start_page_type = 5'd17; 
		end

		S_DRAW_G: begin
			start_draw_start_page = 1'b1;
			x_start_page = 9'd134;
			y_start_page = 8'd121;
			start_page_type = 5'd19; 
		end

		S_DRAW_I: begin
			start_draw_start_page = 1'b1;
			x_start_page = 9'd151;
			y_start_page = 8'd121;
			start_page_type = 5'd20; 
		end

		S_DRAW_N2: begin
			start_draw_start_page = 1'b1;
			x_start_page = 9'd158;
			y_start_page = 8'd121;
			start_page_type = 5'd22; 
		end
		
		S_DONE_DRAW_START_PAGE: start_page_done = 1'b1;
		 

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

