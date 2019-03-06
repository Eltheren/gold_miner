
module move_hook_control(
		input clk,
    		input resetn,
    		input start_move_hook, 
    		input draw_object_done,
			input enable_next_state,
			input go,
			//input move_wait,
			output reg done_move_hook,
			output reg enable_counter_move_hook,
			output reg erase_move_hook,    //singal for erasing hook at current location, need to take background colour
    		output reg start_draw_hook,
    		output reg [8:0] hook_x_start,
    		output reg [7:0] hook_y_start,
			output reg [8:0] current_hook_x,
			output reg [7:0] current_hook_y
		);
    
    reg decrement = 1'b0;
    reg [8:0] x_current;
    reg [7:0] y_current;
	 
	 reg ld_xy, ld_currentxy, update_flip, update_position;

    reg [4:0] current_state, next_state; 
    
    localparam  
		S_WAIT_FOR_COMMAND		= 5'd1,
		S_DRAW				= 5'd2,
		S_WAIT				= 5'd3,
		S_UPDATE_FLIP			= 5'd4,
		S_UPDATE_POSITION		= 5'd5,
		S_ERASE				= 5'd6,
		S_EXIT_MOVE		= 5'd7;


    // Next state logic aka our state table
    always@(*)
    begin: state_table 
           case (current_state)
      S_WAIT_FOR_COMMAND: next_state = start_move_hook? S_DRAW: S_WAIT_FOR_COMMAND;
		S_DRAW: begin if(!draw_object_done)
						next_state = S_DRAW;
					else if(start_move_hook)
						next_state = S_WAIT;
					else
						next_state = S_EXIT_MOVE;
					end
		S_WAIT: next_state = enable_next_state? S_ERASE: S_WAIT;
		S_ERASE:	next_state = draw_object_done ? S_UPDATE_FLIP: S_ERASE;
		S_UPDATE_FLIP: next_state = S_UPDATE_POSITION;
		S_UPDATE_POSITION: next_state = S_DRAW;
		S_EXIT_MOVE: next_state = S_WAIT_FOR_COMMAND;
		
            
				default:     next_state = S_WAIT_FOR_COMMAND;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		start_draw_hook = 1'b0;
    		hook_x_start = 9'b0;
    		hook_y_start = 8'b0;
		erase_move_hook = 1'b0;
		enable_counter_move_hook = 1'b0;
		done_move_hook = 1'b0;
		
		// signals for changing x_start, y_start
		ld_xy = 1'b0;
		update_flip = 1'b0;
		update_position = 1'b0;
		ld_currentxy = 1'b0;
		


      case (current_state)
		
		S_WAIT_FOR_COMMAND: begin
			ld_xy = 1'b1;
		end

		S_ERASE: begin 
			hook_x_start = x_current;
			hook_y_start = y_current;
			start_draw_hook = 1'b1;
			erase_move_hook = 1'b1;
		end

		S_WAIT: begin
			enable_counter_move_hook = 1'b1;
		end

		S_UPDATE_FLIP: begin
			update_flip = 1'b1;
		end
 
		S_UPDATE_POSITION: begin
			update_position = 1'b1;
		end

		S_DRAW: begin
			hook_x_start = x_current;
			hook_y_start = y_current;
			start_draw_hook = 1'b1;
			erase_move_hook = 1'b0;
		end
		
		S_EXIT_MOVE: begin
			done_move_hook = 1'b1;
			ld_currentxy = 1'b1;
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
            x_current <= 9'd146;
	y_current <= 8'd40;
	decrement <= 1'b0;  
	end
			
	if(update_flip) begin
		if(x_current == 9'd0 || x_current == 9'd303) 
			decrement <= ~decrement;
		else 
			decrement <= decrement;
					
	end

	if(update_position) begin
		if (!decrement)
			x_current <= x_current + 1'b1;
		else
			x_current <= x_current - 1'b1;
	end
	
	if(ld_currentxy) begin
		current_hook_x <= x_current;
		current_hook_y <= y_current;
    end 
	 
	 end
	 
endmodule



