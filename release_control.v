
module release_control(
		input clk,
    		input resetn,
    		input start_release, 	// signal to start this control
    		input draw_object_done,
		input enable_next_release_state, // from counter time to go to the next state
		// the location at which when the key is pressed
		input [8:0] current_hook_x,
		input [7:0] current_hook_y,

		// into datapath
		// for comparing whether there's a object exist at that address
		input [4:0] check_for_touch,	// if 0, go down, else, return up
		input check_counter_done,
		output reg ld_check_address,
		output reg enable_check_counter,   // signal for check counter
		
		output reg enable_counter_release,  // tell counter time to start
		output reg erase_release_hook,    //singal for erasing hook at current location, need to take background colour
    		output reg start_draw_release_hook,   // for draw hook
		output reg done_release,   // signal to tell upper control this is done
    		output reg [8:0] release_x_start,
    		output reg [7:0] release_y_start,
			
		// for draw black lines behind
		output reg draw_black_line,
		output reg ld_black_line,

		// input into pull back module
		output reg [8:0] current_release_x,
		output reg [7:0] current_release_y,
		output reg reach_bottom
		);
    
    reg decrement = 1'b0;
    reg [8:0] x_current;
    reg [7:0] y_current;
	 
    reg ld_xy, ld_currentxy, update_flip, update_position;

    reg [4:0] current_state, next_state; 

    reg [3:0] counter_black_line;	// need to draw 9 more pixels of black
    reg enable_counter_black, reset_counter_black;
    
    localparam  
		S_WAIT_FOR_COMMAND		= 5'd1,
		S_DRAW				= 5'd2,
		S_WAIT				= 5'd3,
		S_ERASE				= 5'd4,
		S_LOAD_CHECK_ADDRESS		= 5'd5,
		S_WAIT_FOR_CHECK_COUNTER	= 5'd6,
		S_UPDATE_FLIP			= 5'd7,
		S_CHECK_FOR_PULL_BACK		= 5'd8,
		S_UPDATE_POSITION		= 5'd9,
		S_DRAW_BLACK_LINE		= 5'd10,
		S_LOAD_FINISHED_BLACK_LINE	= 5'd11,
		S_DRAW_FINISHED_BLACK_LINE	= 5'd12,
		S_UPDATE_BLACK_LINE		= 5'd13,	
		S_EXIT_RELEASE			= 5'd14;


    // Next state logic aka our state table
    always@(*)
    begin: state_table 
           case (current_state)
      S_WAIT_FOR_COMMAND: next_state = start_release? S_DRAW: S_WAIT_FOR_COMMAND;
		S_DRAW: next_state = draw_object_done? S_WAIT: S_DRAW;
		S_WAIT: next_state = enable_next_release_state? S_ERASE: S_WAIT;
		S_ERASE: next_state = draw_object_done? S_LOAD_CHECK_ADDRESS: S_ERASE;
		S_LOAD_CHECK_ADDRESS: next_state = S_WAIT_FOR_CHECK_COUNTER;
		S_WAIT_FOR_CHECK_COUNTER: next_state = check_counter_done ? S_UPDATE_FLIP: S_WAIT_FOR_CHECK_COUNTER;
		S_UPDATE_FLIP: next_state = S_CHECK_FOR_PULL_BACK;
		S_CHECK_FOR_PULL_BACK: next_state = decrement? S_LOAD_FINISHED_BLACK_LINE: S_UPDATE_POSITION;	
		S_UPDATE_POSITION: next_state = S_DRAW_BLACK_LINE;
		S_DRAW_BLACK_LINE: next_state = S_DRAW;
	
		S_LOAD_FINISHED_BLACK_LINE: next_state = S_DRAW_FINISHED_BLACK_LINE;
		S_DRAW_FINISHED_BLACK_LINE: next_state = (counter_black_line == 4'd9) ? S_EXIT_RELEASE: S_UPDATE_BLACK_LINE;
		S_UPDATE_BLACK_LINE: next_state = S_LOAD_FINISHED_BLACK_LINE;

		S_EXIT_RELEASE: next_state = start_release? S_EXIT_RELEASE: S_WAIT_FOR_COMMAND;
            
				default:     next_state = S_WAIT_FOR_COMMAND;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		enable_counter_release = 1'b0;

		enable_check_counter = 1'b0;
		ld_check_address = 1'b0;

		erase_release_hook = 1'b0;  
    		start_draw_release_hook = 1'b0; 
    		release_x_start = 9'b0;
    		release_y_start = 8'b0;

		done_release = 1'b0;
		draw_black_line = 1'b0;
		ld_black_line = 1'b0;

		// signals for changing x_start, y_start
		ld_xy = 1'b0;
		ld_currentxy = 1'b1;
		update_flip = 1'b0;
		update_position = 1'b0;

		enable_counter_black = 1'b0;
		reset_counter_black = 1'b0;

      case (current_state)
		
		S_WAIT_FOR_COMMAND: begin
			ld_xy = 1'b1;
			reset_counter_black = 1'b1;
		end

		S_ERASE: begin 
			release_x_start = x_current;
			release_y_start = y_current;
			start_draw_release_hook = 1'b1;
			erase_release_hook = 1'b1;
		end

		S_WAIT: begin
			enable_counter_release = 1'b1;
		end

		S_LOAD_CHECK_ADDRESS: begin
			ld_check_address = 1'b1;
			release_x_start = x_current;
			release_y_start = y_current;
		end

		S_WAIT_FOR_CHECK_COUNTER: begin
			enable_check_counter = 1'b1;
			release_x_start = x_current;
			release_y_start = y_current;
		end

		S_UPDATE_FLIP: begin
			update_flip = 1'b1;
		end

		S_UPDATE_POSITION: begin
			update_position = 1'b1;
			release_x_start = x_current;
			release_y_start = y_current;
			ld_black_line = 1'b1;
		end

		S_DRAW_BLACK_LINE: begin
			draw_black_line = 1'b1;
		end

		S_LOAD_FINISHED_BLACK_LINE: begin
			release_x_start = x_current;
			release_y_start = y_current;
			ld_black_line = 1'b1;
		end
		S_DRAW_FINISHED_BLACK_LINE: begin
			draw_black_line = 1'b1;
			enable_counter_black = 1'b1;
		end

		S_UPDATE_BLACK_LINE: update_position = 1'b1;

		S_DRAW: begin
			release_x_start = x_current;
			release_y_start = y_current;
			start_draw_release_hook = 1'b1;
			erase_release_hook = 1'b0;
		end
		
		S_EXIT_RELEASE: begin
			ld_currentxy = 1'b1;
			done_release = 1'b1;
		end
		
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
	 
	 
	 
    always@(posedge clk)
    begin
        if(ld_xy) begin
        x_current <= current_hook_x;
	y_current <= current_hook_y;
	decrement <= 1'b0;  
	end
			
	if(update_flip) begin
		if(y_current == 8'd230 || check_for_touch != 0) begin
			decrement <= ~decrement;
			if(y_current == 8'd230)
				reach_bottom <= 1'b1;
			else
				reach_bottom <= 1'b0;
		end

		else 
			decrement <= decrement;
					
	end

	if(update_position) begin
		y_current <= y_current + 1'b1;
	end

	if (ld_currentxy) begin
		current_release_x <= x_current;
		current_release_y <= y_current - 4'd9;
	end

	if (enable_counter_black)
		counter_black_line <= counter_black_line + 1'b1;

	if (reset_counter_black)
		counter_black_line <= 4'b0;	

	end
	 
endmodule



