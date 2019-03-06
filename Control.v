
module control(
    input clk,
    input resetn,
    input go_enter,
    input go_down,
	 input plot_object,
	 input plot_bg,
	 output reg add_level,
	 output reg reset_level,
	 input [1:0] levels,

	// for audio
	 input [6:0] audio_pull_back,
	 output reg [6:0] audio,
	output reg start_audio_success,
	input audio_success_done,
	input [6:0] audio_success,

	output reg start_audio_fail,
	input audio_fail_done,
	input [6:0] audio_fail,
	 
	// for counting 30 seconds
	output reg enable_start_count,
	input time_done,

	// for clearing screen,
	output reg clear_screen,

	// for drawing start page
	output reg start_page_module,
	input start_page_done,
	output reg draw_start_page_letter,
	input [4:0] start_page_type,
	input start_draw_start_page,
	input [8:0] x_start_page,
	input [7:0] y_start_page,
	output reg enable_5,
	input enable_next_counter_5,

	// for drawing next level page
    	output reg start_next_level_page,
   	input [4:0] next_level_page_type,
    	input start_draw_next_level, next_level_page_done,
    	input [8:0] x_next_level,
    	input [7:0] y_next_level,

	// for drawing fail page
    	output reg start_fail_page,
    	input [4:0] fail_page_type,
    	input start_draw_fail_page, fail_page_done,
    	input [8:0] x_fail_page,
    	input [7:0] y_fail_page,

	// for drawing win page
    	output reg start_win_page,
    	input [4:0] win_page_type,
    	input start_draw_win_page, win_page_done,
    	input [8:0] x_win_page,
    	input [7:0] y_win_page,

	// for drawing black line when releasing hook
	input draw_black_line,
	 
	// output whether read or write into current background memory	 
	 output reg select,
	 output reg select_for_type,
	 output reg select_object_location,
	 input select_for_object_location,

	// done signals from other control modules
	input draw_object_done, draw_bg_done, 

	// this signal is for reset object location address
	output reg reset_object_location_address,

	// these are for drawing initial objects
    	input [4:0] initial_type,
	input [8:0] x_initial_position,
    	input [7:0] y_initial_position,
	input start_draw_object_initial,
	input initial_module_done,

	// these are for moving hook
	input [8:0] hook_x_start,
	input [7:0] hook_y_start,
	input start_draw_hook,
	input done_move_hook,
	//output reg move_wait,

	// these are for release hook
	input [8:0] release_x_start,
	input [7:0] release_y_start,
	input start_draw_release_hook,
	input done_release,

	// these are for pull back hook
	input pull_back_done,
	input start_draw_back_hook,
	input start_draw_back_object,
	input [8:0] back_x_start,
	input [7:0] back_y_start,
	input [4:0] pull_back_type,
	input update_currentbackground,

	// these are for updating score module
	output reg reset_score,
	input [8:0] score_x,
	input [7:0] score_y,
	input [4:0] score_number_type,
	output reg start_update_score,
	input update_score_done,
	input start_draw_score,
	input [4:0] first,
	input [4:0] second,
	input [4:0] third,
	
	// for checking score counter
	output reg enable_check_score_counter,
	input check_score_counter_done,


	// output all the wires for drawing objects
	output reg [4:0] object_type,
	output reg [8:0] x_start,
	output reg [7:0] y_start,
	
	// enable signal to start draw_initial_objects and draw object and draw background
   	 output reg start_draw_object, start_draw_bg, start_initial_module, start_move_hook, start_release, start_pull_back,
	 output reg writeEn
    );

    reg [5:0] current_state, next_state; 
    
    localparam  
					// for drawing start page	
					S_BACKGROUND			  = 6'd0,
					S_WAIT_BACKGROUND		  = 6'd1,
					S_CLEAR_SCREEN1		  = 6'd2,
					S_WAIT_CLEAR_SCREEN1	  = 6'd3,
					S_DRAW_START_PAGE 	  = 6'd4,

					S_START_GAME 		  = 6'd5,
					 S_START_GAME_WAIT  = 6'd6,
					 S_DRAW_BG			  = 6'd7,
					 S_WAIT_DRAW_BG	  = 6'd8,
					 S_CLEAR_CURRENT_BG = 6'd9,
                			S_DRAW_OBJECTS     = 6'd10,
					 S_MOVE_HOOK		  = 6'd11,
					 S_MOVE_HOOK_WAIT   	= 6'd12,
					 S_RELEASE_HOOK 	= 6'd13,
					S_PULL_BACK_HOOK	= 6'd14,
					S_UPDATE_SCORE		= 6'd15,
					S_CHECK_SCORE		= 6'd16,
					
					// for drawing fail page
					S_CLEAR_SCREEN2		  = 6'd17,
					S_WAIT_CLEAR_SCREEN2	  = 6'd18,
					S_FAIL_PAGE 	  = 6'd19,
					 S_FAIL				  = 6'd20,
					 S_FAIL_WAIT		  = 6'd21,
					 
					S_SUCCESS			  = 6'd22,
					
					// for drawing next level
					S_CLEAR_SCREEN3		  = 6'd23,
					S_WAIT_CLEAR_SCREEN3	  = 6'd24,
					S_NEXT_LEVEL_PAGE 	  = 6'd25,
					 S_NEXT_LEVEL		  = 6'd26,


					S_CLEAR_SCREEN4		  = 6'd27,
					S_WAIT_CLEAR_SCREEN4	  = 6'd28,
					S_WIN_PAGE 	  = 6'd29,
					S_WIN				  = 6'd30;
					 

    // Next state logic aka our state table
    always@(*)
    begin: state_table 
			case (current_state)
			
					S_BACKGROUND: next_state = go_enter? S_WAIT_BACKGROUND: S_BACKGROUND;
					
					S_WAIT_BACKGROUND: next_state = go_enter? S_WAIT_BACKGROUND: S_CLEAR_SCREEN1;
					
					S_CLEAR_SCREEN1: next_state = draw_bg_done? S_WAIT_CLEAR_SCREEN1: S_CLEAR_SCREEN1;

					S_WAIT_CLEAR_SCREEN1: next_state = check_score_counter_done? S_DRAW_START_PAGE: S_WAIT_CLEAR_SCREEN1;

					S_DRAW_START_PAGE: next_state = start_page_done? S_START_GAME: S_DRAW_START_PAGE;

					S_START_GAME: next_state = go_enter ? S_START_GAME_WAIT: S_START_GAME;
					
					S_START_GAME_WAIT: next_state = go_enter ? S_START_GAME_WAIT: S_DRAW_BG;
					
					S_DRAW_BG: next_state = draw_bg_done ? S_WAIT_DRAW_BG: S_DRAW_BG;

					S_WAIT_DRAW_BG: next_state = S_CLEAR_CURRENT_BG;
					
					S_CLEAR_CURRENT_BG: next_state = draw_bg_done ? S_DRAW_OBJECTS : S_CLEAR_CURRENT_BG;
					
					S_DRAW_OBJECTS: next_state = initial_module_done ? S_MOVE_HOOK: S_DRAW_OBJECTS;
					
					S_MOVE_HOOK: if (!time_done)
							next_state = go_down ? S_MOVE_HOOK_WAIT: S_MOVE_HOOK;
						     else
							next_state = S_CLEAR_SCREEN2;
					
					S_MOVE_HOOK_WAIT: next_state = done_move_hook? S_RELEASE_HOOK: S_MOVE_HOOK_WAIT;
					
					S_RELEASE_HOOK: next_state = done_release? S_PULL_BACK_HOOK: S_RELEASE_HOOK;
					S_PULL_BACK_HOOK: next_state = pull_back_done? S_UPDATE_SCORE: S_PULL_BACK_HOOK;
					
					S_UPDATE_SCORE: next_state = update_score_done? S_CHECK_SCORE: S_UPDATE_SCORE;

					S_CHECK_SCORE:  if (levels == 2'd1) begin
								if (first >= 5'd2)
							  	next_state = check_score_counter_done? S_SUCCESS : S_CHECK_SCORE;
								else
							  	next_state = check_score_counter_done? S_MOVE_HOOK: S_CHECK_SCORE;
							end
							else if (levels == 2'd2) begin
								if (first >= 5'd3)
								next_state = check_score_counter_done? S_SUCCESS : S_CHECK_SCORE;
								else
								next_state = check_score_counter_done? S_MOVE_HOOK: S_CHECK_SCORE;
							end
							else if (levels == 2'd3) begin
								if (first >= 5'd5)
								next_state = check_score_counter_done? S_SUCCESS : S_CHECK_SCORE;
								else
								next_state = check_score_counter_done? S_MOVE_HOOK: S_CHECK_SCORE;
							end
							else
								next_state = S_START_GAME;	

					S_CLEAR_SCREEN2: next_state = draw_bg_done? S_WAIT_CLEAR_SCREEN2: S_CLEAR_SCREEN2;

					S_WAIT_CLEAR_SCREEN2: next_state = S_FAIL_PAGE;

					S_FAIL_PAGE: next_state = fail_page_done? S_FAIL: S_FAIL_PAGE;

					S_FAIL:	next_state = audio_fail_done? S_CLEAR_SCREEN1: S_FAIL;
					
					S_SUCCESS: next_state = (levels == 2'd3) ? S_CLEAR_SCREEN4: S_CLEAR_SCREEN3;


					S_CLEAR_SCREEN3: next_state = draw_bg_done? S_WAIT_CLEAR_SCREEN3: S_CLEAR_SCREEN3;

					S_WAIT_CLEAR_SCREEN3: next_state = S_NEXT_LEVEL_PAGE;

					S_NEXT_LEVEL_PAGE: next_state = next_level_page_done? S_NEXT_LEVEL: S_NEXT_LEVEL_PAGE;
					
					S_NEXT_LEVEL: // wait counter for 5 seconds, next level page
								next_state = enable_next_counter_5? S_CLEAR_CURRENT_BG: S_NEXT_LEVEL;
					
					S_CLEAR_SCREEN4: next_state = draw_bg_done? S_WAIT_CLEAR_SCREEN4: S_CLEAR_SCREEN4;

					S_WAIT_CLEAR_SCREEN4: next_state = S_WIN_PAGE;

					S_WIN_PAGE: next_state = win_page_done? S_WIN: S_WIN_PAGE;

					S_WIN: next_state = audio_success_done? S_CLEAR_SCREEN1: S_WIN;

            default:   next_state = S_BACKGROUND;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
			start_page_module = 1'b0;
			start_next_level_page = 1'b0;
			start_win_page = 1'b0;
			start_fail_page = 1'b0;
			draw_start_page_letter = 1'b0;
			enable_5 = 1'b0;

			add_level = 1'b0;
			reset_level = 1'b0;
			object_type = 5'b0;
			x_start = 9'b0;
			y_start = 8'b0;
			start_initial_module = 1'b0;
			start_move_hook = 1'b0;
			start_release = 1'b0;
			start_pull_back = 1'b0;
			start_draw_object = 1'b0;
			start_draw_bg = 1'b0;
			writeEn = 1'b0;
			select = 1'b0;
			select_for_type = 1'b0;
			select_object_location = 1'b0;
			reset_object_location_address = 1'b0;
			reset_score = 1'b0;
			start_update_score = 1'b0;
			enable_check_score_counter = 1'b0;
			clear_screen = 1'b0;
			enable_start_count = 1'b0;
			audio = 7'b0;
			start_audio_success = 1'b0;
			start_audio_fail = 1'b0;
			
			
        case (current_state)

		 S_CLEAR_SCREEN1: begin
			start_draw_bg = 1'b1;
			writeEn = plot_bg;
			clear_screen = 1'b1;
			reset_object_location_address = 1'b1;
			reset_score = 1'b1;	
			reset_level = 1'b1;
		 end
		 
		 S_WAIT_CLEAR_SCREEN1: begin
			enable_check_score_counter = 1'b1;
		 end

		 S_CLEAR_SCREEN2: begin
			start_draw_bg = 1'b1;
			writeEn = plot_bg;
			clear_screen = 1'b1;
		 end

		 S_CLEAR_SCREEN3: begin
			start_draw_bg = 1'b1;
			writeEn = plot_bg;
			clear_screen = 1'b1;
		 end

		 S_CLEAR_SCREEN4: begin
			start_draw_bg = 1'b1;
			writeEn = plot_bg;
			clear_screen = 1'b1;
		 end

		 S_DRAW_START_PAGE: begin

			start_page_module = 1'b1;
			draw_start_page_letter = 1'b1;
			start_draw_object = start_draw_start_page;

			object_type = start_page_type;
			x_start = x_start_page;
			y_start = y_start_page;
			writeEn = plot_object;
		 end

		 S_FAIL_PAGE: begin
			start_fail_page = 1'b1;
			draw_start_page_letter = 1'b1;
			start_draw_object = start_draw_fail_page;

			object_type = fail_page_type;
			x_start = x_fail_page;
			y_start = y_fail_page;
			writeEn = plot_object;
		 end
		 
		 S_FAIL: begin
			start_audio_fail = 1'b1;
			audio = audio_fail;
		 end

		 S_NEXT_LEVEL_PAGE: begin
			start_next_level_page = 1'b1;
			draw_start_page_letter = 1'b1;
			start_draw_object = start_draw_next_level;
			object_type = next_level_page_type;
			x_start = x_next_level;
			y_start = y_next_level;
			writeEn = plot_object;
		 end
		 
		 S_NEXT_LEVEL: enable_5 = 1'b1;

		 S_WIN_PAGE: begin
			start_win_page = 1'b1;
			draw_start_page_letter = 1'b1;
			start_draw_object = start_draw_win_page;
			object_type = win_page_type;
			x_start = x_win_page;
			y_start = y_win_page;
			writeEn = plot_object;
		 end
		 
		 S_WIN: begin
			start_audio_success = 1'b1;
			audio = audio_success;
		 end
		 
		 S_DRAW_BG: begin
				start_draw_bg = 1'b1;
				writeEn = plot_bg;
				//select_for_type = 1'b1;
				reset_object_location_address = 1'b1;
				reset_score = 1'b1;
				select = 1'b1;
				
		 end
		 
		 S_CLEAR_CURRENT_BG: begin
		 		start_draw_bg = 1'b1;
				writeEn = plot_bg;
				reset_object_location_address = 1'b1;
				reset_score = 1'b1;
				select = 1'b1;
		 end
		 
	    S_DRAW_OBJECTS: begin
				// start drawing initial objects module
				start_initial_module = 1'b1;
				// enable signal to draw a single object
				start_draw_object = start_draw_object_initial;

			 	object_type = initial_type;
				x_start = x_initial_position;
				y_start = y_initial_position;

				writeEn = plot_object;
				select = 1'b1;
				select_for_type = 1'b1;
				select_object_location = select_for_object_location;
		 end

		S_MOVE_HOOK: begin
			// start move hook module
			start_move_hook = 1'b1;
			// enable signal to draw the hook(also erase)
			start_draw_object = start_draw_hook;

			object_type = 5'd12;
			x_start = hook_x_start;
			y_start = hook_y_start;
			
			writeEn = plot_object;

			enable_start_count = 1'b1;
		end
		
		S_MOVE_HOOK_WAIT: begin
			//move_wait = 1'b1;
			object_type = 5'd12;
			x_start = hook_x_start;
			y_start = hook_y_start;
			start_draw_object = start_draw_hook;
			writeEn = plot_object;
			enable_start_count = 1'b1;

		end

		S_RELEASE_HOOK: begin
			start_release = 1'b1;
			start_draw_object = start_draw_release_hook;
			
			object_type = 5'd12;
			x_start = release_x_start;
			y_start = release_y_start;
			enable_start_count = 1'b1;
			if (draw_black_line)
			 	writeEn = 1'b1;
			else	
				writeEn = plot_object;
		end

		S_PULL_BACK_HOOK: begin
			start_pull_back = 1'b1;
			start_draw_object = (start_draw_back_hook || start_draw_back_object);

			object_type = pull_back_type;
			x_start = back_x_start;
			y_start = back_y_start;
			writeEn = plot_object;
			enable_start_count = 1'b1;

			select = update_currentbackground;
			audio = audio_pull_back;
		end

		S_UPDATE_SCORE: begin
			start_update_score = 1'b1;
			start_draw_object = start_draw_score;

			object_type = score_number_type;
			x_start = score_x;
			y_start = score_y;
			writeEn = plot_object;
			enable_start_count = 1'b1;
		end
		
		S_CHECK_SCORE: begin
			enable_start_count = 1'b1;
			enable_check_score_counter = 1'b1;
		end

		S_SUCCESS: add_level = 1'b1;


        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_BACKGROUND;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

