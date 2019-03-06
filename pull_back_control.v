
module pull_back_control(
		input clk,
    		input resetn,

			
		// for audio
		output reg [6:0] audio,
		
		
		input [4:0] type_reached,
    		input start_pull_back, 	// signal to start this control
		output reg pull_back_done,

    		input draw_object_done,
			
			input [9:0] counter_object,

		// for pull back a object
		output reg reset_object_pullback, read_object_location,
		input [26:0] object_location_length,   // [26:22] is length, [21:13] is x location, [13:9] is object height, [7:0] is y location

		input enable_next_nothingback_state, // from counter time to go to the next state
		output reg enable_counter_nothingback,  // tell counter time to start
		input enable_next_GLRL_state,
		output reg enable_counter_GLRL,
		input enable_next_GMRM_state,
		output reg enable_counter_GMRM,
		input enable_pull_back_done_state,
		output reg enable_counter_point5sec,


		// signal to tell upper control to update current background
		output reg update_currentbackground,
		
		// the location at which when the it was released
		input [8:0] current_release_x,
		input [7:0] current_release_y,
		input reach_bottom,
		
		output reg erase_back_hook,    //singal for erasing hook at current location, need to take background colour
    		output reg start_draw_back_hook,   // for draw hook

		output reg erase_back_object,
		output reg start_draw_back_object,
		
		output reg erase_back_reached_object,

    		output reg [8:0] back_x_start,
    		output reg [7:0] back_y_start,
		output reg [4:0] pull_back_type
		);
    reg enable_125;
	 wire enable_next_counter_125;
	 
    reg decrement = 1'b1;
    reg found, compare_done, reset_compare_done;
    reg [8:0] x_current;
    reg [7:0] y_current;
    reg [8:0] x_compare;
	 
    reg [4:0] compare_counter;

    reg ld_xy, update_flip, update_position, ld_object, compare;

    //reg [4:0] counter_object_number;   // 12 objects altogether

    reg [4:0] current_state, next_state; 
    
    localparam  		
		S_WAIT_FOR_COMMAND		= 5'd1,

		S_DRAW_HOOK			= 5'd2,
		S_WAIT_NOTHINGBACK		= 5'd3,
		S_ERASE_HOOK			= 5'd4,
		S_UPDATE_FLIP_HOOK		= 5'd5,
		S_CHECK_FOR_TOP_HOOK		= 5'd6,
		S_UPDATE_POSITION_HOOK		= 5'd7,

		S_RESET_OBJECT_LOCATION		= 5'd8,
		S_WAIT_FOR_AUDIO			= 5'd25,
		S_WAIT_FOR_RESET_READ	= 5'd9,
		S_COMPARE_POSITION		= 5'd10,
		S_READ_LOCATION			= 5'd11,
		S_WAIT_FOR_READ_LOCATION	= 5'd12,

		S_ERASE_REACHED_OBJECT		= 5'd13,
		S_LOAD_OBJECT_LOCATION		= 5'd14,
		S_DRAW_OBJECT		= 5'd15,
		S_WAIT_OBJECT			= 5'd16,
		S_ERASE_OBJECT		= 5'd17,
		S_UPDATE_FLIP_OBJECT		= 5'd18,
		S_CHECK_FOR_TOP_OBJECT		= 5'd19,
		S_LOAD_AUDIO2		= 5'd28,
		S_LOAD_AUDIO3		= 5'd27,
		S_WAIT_FOR_AUDIO2			= 5'd26,
		S_UPDATE_POSITION_OBJECT	= 5'd20,

		S_DRAW_FINAL_OBJECT		= 5'd21,
		S_WAIT_FOR_POINT5_SEC		= 5'd22,
		S_ERASE_FINAL_OBJECT		= 5'd23,
		S_EXIT_RELEASE			= 5'd24;


    // Next state logic aka our state table
    always@(*)
    begin: state_table 
           case (current_state)
      S_WAIT_FOR_COMMAND: 
		
				if(start_pull_back) begin
					if (reach_bottom)
						next_state = S_DRAW_HOOK;
					else
						next_state = S_RESET_OBJECT_LOCATION;
				end
			  
			   else
					next_state = S_WAIT_FOR_COMMAND;

		S_DRAW_HOOK: next_state = draw_object_done? S_WAIT_NOTHINGBACK: S_DRAW_HOOK;
		S_WAIT_NOTHINGBACK: next_state = enable_next_nothingback_state? S_ERASE_HOOK: S_WAIT_NOTHINGBACK;
		S_ERASE_HOOK:next_state = draw_object_done? S_UPDATE_FLIP_HOOK: S_ERASE_HOOK;
		S_UPDATE_FLIP_HOOK: next_state = S_CHECK_FOR_TOP_HOOK;
		S_CHECK_FOR_TOP_HOOK: next_state = (!decrement)? S_EXIT_RELEASE: S_UPDATE_POSITION_HOOK;
		S_UPDATE_POSITION_HOOK: next_state = S_DRAW_HOOK;

		S_RESET_OBJECT_LOCATION: next_state = enable_next_counter_125? S_WAIT_FOR_AUDIO: S_RESET_OBJECT_LOCATION;
		S_WAIT_FOR_AUDIO: next_state = S_WAIT_FOR_RESET_READ;
		S_WAIT_FOR_RESET_READ: next_state = enable_next_counter_125? S_COMPARE_POSITION: S_WAIT_FOR_RESET_READ;
		S_COMPARE_POSITION: if (found)
										next_state = S_ERASE_REACHED_OBJECT;
								  else if(compare_done)
										next_state = S_READ_LOCATION;
								  else
										next_state = S_COMPARE_POSITION;
		S_READ_LOCATION: next_state = S_WAIT_FOR_READ_LOCATION;
		S_WAIT_FOR_READ_LOCATION: next_state = S_COMPARE_POSITION;
		S_ERASE_REACHED_OBJECT: next_state = draw_object_done? S_LOAD_OBJECT_LOCATION: S_ERASE_REACHED_OBJECT;
		// need to clear memory
		// add a clear signal to main control,  main control is select is equal to time i wanna write into current background
		
		S_LOAD_OBJECT_LOCATION: next_state = S_DRAW_OBJECT;
		S_DRAW_OBJECT: next_state = draw_object_done? S_WAIT_OBJECT: S_DRAW_OBJECT;
		S_WAIT_OBJECT: 	begin
				if (type_reached == 4'd11 || type_reached == 4'd13) begin	// large gold & large rock
					next_state = enable_next_GLRL_state ? S_ERASE_OBJECT: S_WAIT_OBJECT;
				end
				else if (type_reached == 4'd10 || type_reached == 4'd14) begin	// medium gold & medium rock
					next_state = enable_next_GMRM_state ? S_ERASE_OBJECT: S_WAIT_OBJECT;
				end
				else
					next_state = S_EXIT_RELEASE;
				end
		S_ERASE_OBJECT: next_state = draw_object_done? S_UPDATE_FLIP_OBJECT: S_ERASE_OBJECT;
		S_UPDATE_FLIP_OBJECT: next_state = S_CHECK_FOR_TOP_OBJECT;
		S_CHECK_FOR_TOP_OBJECT: next_state = (!decrement)? S_LOAD_AUDIO2: S_UPDATE_POSITION_OBJECT;
		S_UPDATE_POSITION_OBJECT: next_state = S_DRAW_OBJECT;

		S_LOAD_AUDIO2: next_state = enable_next_counter_125? S_WAIT_FOR_AUDIO2: S_LOAD_AUDIO2;
		S_WAIT_FOR_AUDIO2: next_state = S_LOAD_AUDIO3;
		S_LOAD_AUDIO3: next_state = enable_next_counter_125? S_WAIT_FOR_POINT5_SEC: S_LOAD_AUDIO3;
		
		S_DRAW_FINAL_OBJECT: next_state = draw_object_done? S_WAIT_FOR_POINT5_SEC: S_DRAW_FINAL_OBJECT;
		S_WAIT_FOR_POINT5_SEC: next_state = enable_pull_back_done_state? S_EXIT_RELEASE : S_WAIT_FOR_POINT5_SEC;
		S_ERASE_FINAL_OBJECT: next_state = draw_object_done? S_EXIT_RELEASE: S_ERASE_FINAL_OBJECT;	
		


		S_EXIT_RELEASE: next_state = S_WAIT_FOR_COMMAND;

            
			default:     next_state = S_WAIT_FOR_COMMAND;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		
		pull_back_done = 1'b0;
		enable_counter_nothingback = 1'b0;
		enable_counter_GLRL = 1'b0;
		enable_counter_GMRM = 1'b0;
		enable_counter_point5sec = 1'b0;

		erase_back_hook = 1'b0;   
    		start_draw_back_hook = 1'b0;
			
			erase_back_reached_object = 1'b0;

		erase_back_object = 1'b0;
		start_draw_back_object = 1'b0;

    		back_x_start = 9'b0;
    		back_y_start = 8'b0;
			pull_back_type = 5'd0;

		reset_object_pullback = 1'b0;
		read_object_location = 1'b0;

		update_currentbackground = 1'b0;

		// signals for changing x_start, y_start
		ld_xy = 1'b0;
		update_flip = 1'b0;
		update_position = 1'b0;

		ld_object = 1'b0;
		compare = 1'b0;
		reset_compare_done = 1'b0;
		audio = 7'b0;
		enable_125 = 1'b0;
		

      case (current_state)
		
		S_WAIT_FOR_COMMAND: begin
			ld_xy = 1'b1;
		end


		S_DRAW_HOOK: begin
			back_x_start = x_current;
			back_y_start = y_current;
			start_draw_back_hook = 1'b1;
			erase_back_hook = 1'b0;
			pull_back_type = 5'd12;
		end

		S_ERASE_HOOK: begin 
			back_x_start = x_current;
			back_y_start = y_current;
			start_draw_back_hook = 1'b1;
			erase_back_hook = 1'b1;
			pull_back_type = 5'd12;
		end

		S_WAIT_NOTHINGBACK: begin
			enable_counter_nothingback = 1'b1;
		end


		S_UPDATE_FLIP_HOOK: begin
			update_flip = 1'b1;
		end
 
		S_UPDATE_POSITION_HOOK: begin
			update_position = 1'b1;
		end

		S_RESET_OBJECT_LOCATION: begin
			enable_125 = 1'b1;
			reset_object_pullback = 1'b1;
			if (type_reached == 5'd10 || type_reached == 5'd11)
			audio = 7'b0000110;
			else if (type_reached == 5'd13 || type_reached == 5'd14)
			audio = 7'b1100000;
			else
			audio = 7'b0;
		end
		
		S_WAIT_FOR_RESET_READ: begin
			enable_125 = 1'b1;
			if (type_reached == 5'd10 || type_reached == 5'd11)
			audio = 7'b0000111;
			else if (type_reached == 5'd13 || type_reached == 5'd14)
			audio = 7'b1110000;
			else
			audio = 7'b0;
		end

		S_COMPARE_POSITION: compare = 1'b1;

		S_READ_LOCATION: begin
					read_object_location = 1'b1;
					reset_compare_done = 1'b1;
					end

		S_ERASE_REACHED_OBJECT: begin
			back_x_start = object_location_length[21:13];
			back_y_start = object_location_length[7:0];

			erase_back_reached_object = 1'b1;
			start_draw_back_object = 1'b1;
			pull_back_type = type_reached;
			
			
			if(type_reached == 5'd0 || type_reached == 5'd1 || type_reached == 5'd2 || type_reached == 5'd3 ||
				  type_reached == 5'd4 || type_reached == 5'd5 || type_reached == 5'd6 || type_reached == 5'd7 ||
				  type_reached == 5'd8 || type_reached == 5'd9) begin
					 if (counter_object == 10'd225)
						update_currentbackground = 1'b0;
					 else
						update_currentbackground = 1'b1;
			end
				else if(type_reached == 5'd10) begin
					 if (counter_object == 10'd385)
						update_currentbackground = 1'b0;
					 else
						update_currentbackground = 1'b1;
				end
				else if(type_reached == 5'd11) begin
					if (counter_object == 10'd737)
						update_currentbackground = 1'b0; 
					else
						update_currentbackground = 1'b1;
				end
				else if(type_reached == 5'd12) begin
					if (counter_object == 10'd321)
						update_currentbackground = 1'b0;
					else
						update_currentbackground = 1'b1;
				end
				else if(type_reached == 5'd13) begin
					if (counter_object == 10'd545)
						update_currentbackground = 1'b0;
					else
						update_currentbackground = 1'b1;
				end
				else if(type_reached == 5'd14) begin
					if (counter_object == 10'd417)
						update_currentbackground = 1'b0;
					else
						update_currentbackground = 1'b1;
				end
				else if (type_reached == 5'd15 || type_reached == 5'd16 || type_reached == 5'd17 || type_reached == 5'd18 ||
				  type_reached == 5'd19 || type_reached == 5'd20 || type_reached == 5'd21 || type_reached == 5'd22 ||
				  type_reached== 5'd23 || type_reached == 5'd24 || type_reached== 5'd25 || type_reached== 5'd26 || type_reached == 5'd27 || 
				  type_reached == 5'd28 || type_reached == 5'd29 || type_reached== 5'd30 || type_reached == 5'd31) begin
						if (counter_object == 10'd481)
						update_currentbackground = 1'b0;
						else
						update_currentbackground = 1'b1;
				end
			end


		S_LOAD_OBJECT_LOCATION: ld_object = 1'b1;

		S_DRAW_OBJECT: begin
			back_x_start = x_current;
			back_y_start = y_current;
			erase_back_object = 1'b0;
			start_draw_back_object = 1'b1;
			pull_back_type = type_reached;

		end

		S_WAIT_OBJECT: 	begin
				if (type_reached == 5'd11 || type_reached == 5'd13)	// large gold & large rock
					enable_counter_GLRL = 1'b1;
			
				else if (type_reached == 5'd10 || type_reached == 5'd14)	// medium gold & medium rock
					enable_counter_GMRM = 1'b1;
		end

		S_ERASE_OBJECT: begin
			back_x_start = x_current;
			back_y_start = y_current;
			erase_back_object = 1'b1;
			start_draw_back_object = 1'b1;
			pull_back_type = type_reached;
		end

		S_UPDATE_FLIP_OBJECT: update_flip = 1'b1;
		
		
		S_LOAD_AUDIO2: begin
			enable_125 = 1'b1;
			audio = 7'b0000101;
		end

		S_LOAD_AUDIO3: begin
			enable_125 = 1'b1;
			audio = 7'b0000111;
		end

		S_UPDATE_POSITION_OBJECT: update_position = 1'b1;

		S_DRAW_FINAL_OBJECT: begin
			back_x_start = x_current;
			back_y_start = y_current;
			erase_back_object = 1'b0;
			start_draw_back_object = 1'b1;
			pull_back_type = type_reached;
		end

		S_WAIT_FOR_POINT5_SEC: begin
		enable_counter_point5sec = 1'b1;

		end
		S_ERASE_FINAL_OBJECT: begin
			back_x_start = x_current;
			back_y_start = y_current;
			erase_back_object = 1'b1;
			start_draw_back_object = 1'b1;
			pull_back_type = type_reached;
		end

		S_EXIT_RELEASE: begin
			pull_back_done = 1'b1;
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
        x_current <= current_release_x;
	y_current <= current_release_y;
	x_compare <= current_release_x;
	decrement <= 1'b1;  
	found <= 1'b0;
	compare_done <= 1'b0;
	end
			
	if(update_flip) begin
		if(y_current == 8'd40) 
			decrement <= ~decrement;
		else 
			decrement <= decrement;
					
	end

	if(update_position)
		y_current <= y_current - 1'b1;


	if(ld_object) begin
		if (type_reached == 5'd11) begin	// large gold
			x_current <= x_current - 3'd4;
			y_current <= y_current + 4'd10;
		end
		if (type_reached == 5'd10) begin	// medium gold
			x_current <= x_current + 2'd2;
			y_current <= y_current + 4'd10;
		end
		if (type_reached == 5'd13) begin	// large rock
			x_current <= x_current - 2'd3;
			y_current <= y_current + 4'd10;
		end
		if (type_reached == 5'd14) begin	// medium rock
			x_current <= x_current;
			y_current <= y_current + 4'd10;
		end
	end
	
	if(reset_compare_done) 
		compare_done <= 1'b0;

	if(compare) begin
		// compare y first
		if ((y_current + 4'd10 >= object_location_length[7:0]) && ((y_current + 4'd10) <= (object_location_length[7:0] + object_location_length[12:8]))) begin
			if ((x_compare >= object_location_length[21:13]) && (x_compare <= (object_location_length[21:13] + object_location_length[26:22])))
				found <= 1'b1;
			else begin
				if(compare_counter == 5'd16) begin
					compare_counter <= 5'b0;
					compare_done <= 1'b1;
					x_compare <= current_release_x;
				end

				else begin
					compare_counter <= compare_counter + 1'b1;
					compare_done <= 1'b0;
					x_compare <= x_compare + 1'b1;
				end
			end
		end
		
		else
			compare_done <= 1'b1;

	end
end



	counter_point125sec(.clk(clk),
					.enable_my_counter(enable_125),
					.enable_next(enable_next_counter_125)	
					);
	 
endmodule



