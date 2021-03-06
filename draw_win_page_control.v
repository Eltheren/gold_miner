
module draw_win_page_control(
    input clk,
    input resetn,
    input start_win_page,
    input draw_object_done,

    output reg [4:0] win_page_type,
    output reg start_draw_win_page, win_page_done,
    output reg [8:0] x_win_page,
    output reg [7:0] y_win_page
	
    );

    reg [4:0] current_state, next_state; 

    localparam  S_WAIT_FOR_COMMAND		= 5'd0,
		S_LOAD_Y			= 5'd1,
		S_DRAW_Y			= 5'd2,
		S_LOAD_O			= 5'd3,
		S_DRAW_O			= 5'd4,
		S_LOAD_U			= 5'd5,
		S_DRAW_U			= 5'd6,
		S_LOAD_W			= 5'd7,
		S_DRAW_W			= 5'd8,
		S_LOAD_I			= 5'd9,
		S_DRAW_I			= 5'd10,
		S_LOAD_N			= 5'd11,
		S_DRAW_N			= 5'd12,
		
		S_DONE_DRAW_WIN_PAGE	= 5'd13;  
					 

    // Next state logic aka our state table
    always@(*)
    begin: state_table 
		case (current_state)
					
			S_WAIT_FOR_COMMAND: next_state = start_win_page? S_LOAD_Y: S_WAIT_FOR_COMMAND;

			S_LOAD_Y: next_state = S_DRAW_Y;
			S_DRAW_Y: next_state = draw_object_done? S_LOAD_O: S_DRAW_Y;			
			S_LOAD_O: next_state = S_DRAW_O;		
			S_DRAW_O: next_state = draw_object_done? S_LOAD_U: S_DRAW_O;		
			S_LOAD_U: next_state = S_DRAW_U;		
			S_DRAW_U: next_state = draw_object_done? S_LOAD_W: S_DRAW_U;				
			S_LOAD_W: next_state = S_DRAW_W;		
			S_DRAW_W: next_state = draw_object_done? S_LOAD_I: S_DRAW_W;			
			S_LOAD_I: next_state = S_DRAW_I;		
			S_DRAW_I: next_state = draw_object_done? S_LOAD_N: S_DRAW_I;			
			S_LOAD_N: next_state = S_DRAW_N;			
			S_DRAW_N: next_state = draw_object_done? S_DONE_DRAW_WIN_PAGE: S_DRAW_N;			

			S_DONE_DRAW_WIN_PAGE: next_state = start_win_page? S_DONE_DRAW_WIN_PAGE: S_WAIT_FOR_COMMAND;					
			
            default:   next_state = S_WAIT_FOR_COMMAND;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0

    		start_draw_win_page = 1'b0;
		win_page_done = 1'b0;	
		x_win_page = 9'b0;
     		y_win_page = 8'b0;
		win_page_type = 5'd0;

        case (current_state)
		  
		S_DRAW_Y: begin
			start_draw_win_page = 1'b1;
			x_win_page = 9'd98;
			y_win_page = 8'd97;
			win_page_type = 5'd31; 		
		end

		S_DRAW_O: begin
			start_draw_win_page = 1'b1;
			x_win_page = 9'd110;
			y_win_page = 8'd97;
			win_page_type = 5'd23; 	
		end

		S_DRAW_U: begin
			start_draw_win_page = 1'b1;
			x_win_page = 9'd122;
			y_win_page = 8'd97;
			win_page_type = 5'd27; 	 
		end

		S_DRAW_W: begin
			start_draw_win_page = 1'b1;
			x_win_page = 9'd158;
			y_win_page = 8'd97;
			win_page_type = 5'd29; 
		end

		S_DRAW_I: begin
			start_draw_win_page = 1'b1;
			x_win_page = 9'd175;
			y_win_page = 8'd97;
			win_page_type = 5'd20; 	
		end

		S_DRAW_N: begin
			start_draw_win_page = 1'b1;
			x_win_page = 9'd182;
			y_win_page = 8'd97;
			win_page_type = 5'd22; 	
		end

		
		S_DONE_DRAW_WIN_PAGE: win_page_done = 1'b1;
		 

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

