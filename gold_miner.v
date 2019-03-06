
module gold_miner
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,
		SW,
		HEX0,
		HEX1,
		PS2_CLK,
		PS2_DAT,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,  						//	VGA Blue[9:0]
		
		// for audio
			AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		FPGA_I2C_SDAT,

		// Outputs
		AUD_XCK,
		AUD_DACDAT,

		FPGA_I2C_SCLK
		);

	input		CLOCK_50;					//	50 MHz
	input 	[9:0] 	SW;
	input 	[3:0] 	KEY;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[9:0]
	output	[7:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[9:0]
	
	
	input				AUD_ADCDAT;

	// Bidirectionals
	inout				AUD_BCLK;
	inout				AUD_ADCLRCK;
	inout				AUD_DACLRCK;

	inout				FPGA_I2C_SDAT;

	// Outputs
	output				AUD_XCK;
	output				AUD_DACDAT;

	output				FPGA_I2C_SCLK;
	

	// for audio
	wire [6:0] audio;
	wire [6:0] audio_pull_back;

	wire enable_audio_success;
	wire audio_success_counter_done;
	wire start_audio_success;
	wire audio_success_done;
	wire [6:0] audio_success;

	wire enable_audio_fail;
	wire audio_fail_counter_done;
	wire start_audio_fail;
	wire audio_fail_done;
	wire [6:0] audio_fail;


	output [6:0] HEX0, HEX1;
	
	// for keyboard
	inout PS2_CLK;
	inout PS2_DAT;
	wire [7:0]ps2_key_data;
	wire		 ps2_key_pressed;
	reg	[7:0]	last_data_received;
	
	wire  down_pressed,  enter_pressed;
	
	always @(posedge CLOCK_50)
	begin
	if (~KEY[0] == 1'b1)
		last_data_received <= 8'h00;
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
	else
		last_data_received <= 8'h00;
	end
	
	
	PS2_Controller PS2 (
	// Inputs
	.CLOCK_50		(CLOCK_50),
	.reset			(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)	
	);

	//constant
	reg [7:0]enter_sig = 8'h5A;
	
	reg [7:0]down_sig = 8'h1B;
	
	assign enter_pressed = (last_data_received == enter_sig);
	assign down_pressed = (last_data_received == down_sig);

	wire go_enter;
	assign go_enter = enter_pressed;

	wire go_down;
	assign go_down = down_pressed;

	wire resetn;
	assign resetn = KEY[0];

	// wire for hex1 and hex1
	wire [3:0] tenth;
	wire [3:0] oneth;
	wire time_done;
	wire enable_start_count;

	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [5:0] colour;
	wire [8:0] x;
	wire [7:0] y;
	wire [8:0] x_start;
	wire [7:0] y_start;
	wire writeEn;
	wire [4:0] object_type;
	wire [1:0] levels;

	// for clearing screen
	wire clear_screen;
	wire ld_black;

	// for draw start page
	wire start_page_module;
	wire start_page_done;
	wire [4:0] start_page_type;
	wire start_draw_start_page;
	wire [8:0] x_start_page;
	wire [7:0] y_start_page;
	wire draw_start_page_letter;
	wire enable_5;
	wire enable_next_counter_5;

	// for draw next level page
	wire start_next_level_page;
	wire next_level_page_done;
    	wire [4:0] next_level_page_type;
    	wire start_draw_next_level;
    	wire [8:0] x_next_level;
    	wire [7:0] y_next_level;

	// for draw fail page
	wire start_fail_page;
	wire fail_page_done;
    	wire [4:0] fail_page_type;
    	wire start_draw_fail_page;
    	wire [8:0] x_fail_page;
    	wire [7:0] y_fail_page;

	// for draw win page
    	wire start_win_page;
	wire win_page_done;
   	wire [4:0] win_page_type;
    	wire start_draw_win_page;
    	wire [8:0] x_win_page;
    	wire [7:0] y_win_page;


	// for write or read current background memory, 0 for read, 1 for write
	wire select;

	// for draw_initial_objects module
	wire [8:0] x_initial_position;
   	wire [7:0] y_initial_position;
	wire [4:0] initial_type;
	wire start_draw_object_initial;
	// these two are for random number generator
	wire [8:0] x_random;
	wire [7:0] y_random;


	// same as x_start, y_start, but used in move_hook module
	wire [8:0] hook_x_start;
	wire [7:0] hook_y_start;
	wire [8:0] current_hook_x;
	wire [7:0] current_hook_y;
	wire start_move_hook, erase_move_hook, start_draw_hook;
	wire enable_counter_move_hook, enable_next_state;
	wire done_move_hook;
	//wire move_wait;

	// for release module
  	wire start_release; 	// signal to start this control
	wire done_release;   // signal to tell upper control this is done
	wire enable_counter_release; // tell counter time to start
	wire enable_next_release_state; // from counter time to go to the next state
	// into datapath
	// for comparing whether there's a object exist at that address
	wire [4:0] check_for_touch;	// if 0, go down, else, return up
	wire check_counter_done;
	wire ld_check_address;
	wire enable_check_counter;   // signal for check counter
	wire erase_release_hook;   //singal for erasing hook at current location, need to take background colour
    	wire start_draw_release_hook;  // for draw hook, tell upper control to draw_object
    	wire [8:0] release_x_start;
    	wire [7:0] release_y_start;
	wire ld_black_line;
	wire draw_black_line;
	wire reach_bottom;

	// for pull back module
	wire pull_back_done;
	wire start_pull_back;
	wire [8:0] back_x_start;
	wire [7:0] back_y_start;
	wire [8:0] current_release_x;
	wire [7:0] current_release_y;
	wire [4:0] pull_back_type;
	wire enable_next_nothingback_state;
	wire enable_counter_nothingback;
	wire enable_next_GLRL_state;
	wire enable_counter_GLRL;
	wire enable_next_GMRM_state;
	wire enable_counter_GMRM;
	wire enable_pull_back_done_state;
	wire enable_counter_point5sec;
	wire start_draw_back_hook;
	wire erase_back_hook;
	wire erase_back_object;
	wire erase_back_reached_object;
	wire start_draw_back_object;
	wire reset_object_pullback;
	wire read_object_location;
	wire update_currentbackground;

	// for updating score
	wire [8:0] score_x;
	wire [7:0] score_y;
	wire [4:0] score_number_type;
	wire start_update_score;
	wire update_score_done;
	wire start_draw_score;
	wire reset_score;
	wire [4:0] first;
	wire [4:0] second;
	wire [4:0] third;
	
	// for checking score
	wire enable_check_score_counter;
	wire check_score_counter_done;

	// for storing type into background
	wire store_type;
	wire [4:0] type_for_store;
	wire [4:0] type_for_read;
	wire select_for_type;

	// for determining what object has been reached
	wire [4:0] type_reached;

	// for store every location of the object and its length
	wire [3:0] object_location_address;
	wire [4:0] object_length;  // largest object length is 24
	wire [4:0] object_height; // largest object height is 22
	wire select_for_object_location;   // 0 for read, 1 for write  // in draw object control
	wire select_object_location;
	wire [26:0] object_location_length;   // [26:22] is length, [21:13] is x location, [13:9] is object height, [7:0] is y location
	wire reset_object_location_address;	// enable signal to reset the location address to 0
	wire store_object_location;

	// control signals
	wire add_level;
	wire reset_level;
	wire start_draw_object, draw_object_done; 
	wire start_draw_bg, draw_bg_done;
	wire start_initial_module, initial_module_done;
	wire plot_object, plot_bg;
   	wire read_mem, ld_bg, ld_colour_bg, load_colour, store_current_bg;
	wire enable_counter_object, reset_counter_object;
	wire enable_counter_address_background, reset_counter_address_background;
	
	// for reading colours from memory
	wire [5:0] colour_from_mem;
   	wire [5:0] colour_background;
	wire [5:0] colour_currentbackground;
	 

	wire [16:0] counter_address_background;  // for plotting initial background
	
	// for plotting one object
	wire [9:0] counter_object;	// for counting to draw one object
   	wire [14:0] address_object;  // address of the object in objects.mif file

   	wire [16:0] current_address_background; // address of the memory
   	wire [4:0] counter_current_address_background;  // for matching the memory address to object

	
	// ouput control signals
	control c0 (.clk(CLOCK_50),
    		 .resetn(resetn),
		    .go_enter(go_enter),
		    .go_down(go_down),
			 .writeEn(writeEn),
			 .plot_object(plot_object),
			 .plot_bg(plot_bg),
			 .levels(levels),
			 .add_level(add_level),
			 .reset_level(reset_level),
			 .select(select),
			 .select_for_type(select_for_type),
			 .select_object_location(select_object_location),
			 .select_for_object_location(select_for_object_location),  // this one is output from draw object control


			 // for audio
			 .audio(audio),
			 .audio_pull_back(audio_pull_back),

			.start_audio_success(start_audio_success),
			.audio_success_done(audio_success_done),
			.audio_success(audio_success),

			.start_audio_fail(start_audio_fail),
			.audio_fail_done(audio_fail_done),
			.audio_fail(audio_fail),


			 // for counting 30 seconds
			 .enable_start_count(enable_start_count),
			 .time_done(time_done),

			 // for clearing screen, enable signal
			 .clear_screen(clear_screen),

			 // for drawing start page
			.draw_start_page_letter(draw_start_page_letter),
			.enable_5(enable_5),
		   .enable_next_counter_5(enable_next_counter_5),
			.start_page_module(start_page_module),
    			.start_page_type(start_page_type),
    			.start_draw_start_page(start_draw_start_page), 
  			.start_page_done(start_page_done),
    			.x_start_page(x_start_page),
    			.y_start_page(y_start_page),

			 // for drawing next level page
			.start_next_level_page(start_next_level_page),
    			.next_level_page_type(next_level_page_type),
    			.start_draw_next_level(start_draw_next_level), 
  			.next_level_page_done(next_level_page_done),
    			.x_next_level(x_next_level),
    			.y_next_level(y_next_level),

			 // for drawing win page
			.start_win_page(start_win_page),
    			.win_page_type(win_page_type),
    			.start_draw_win_page(start_draw_win_page), 
  			.win_page_done(win_page_done),
    			.x_win_page(x_win_page),
    			.y_win_page(y_win_page),

			 // for drawing fail page 
			.start_fail_page(start_fail_page),
    			.fail_page_type(fail_page_type),
    			.start_draw_fail_page(start_draw_fail_page), 
  			.fail_page_done(fail_page_done),
    			.x_fail_page(x_fail_page),
    			.y_fail_page(y_fail_page),

			 // this is for reset object location address
			 .reset_object_location_address(reset_object_location_address),

			 // draw_initial_objects_module
			 .initial_type(initial_type),
			 .start_initial_module(start_initial_module), 
			 .initial_module_done(initial_module_done),
			 .start_draw_object_initial(start_draw_object_initial), // for equating start_draw_object
			 .x_initial_position(x_initial_position),
			 .y_initial_position(y_initial_position),

			 // these are for moving hook
			 .hook_x_start(hook_x_start),
			 .hook_y_start(hook_y_start),
			 .start_draw_hook(start_draw_hook),
			 .start_move_hook(start_move_hook),
			 .done_move_hook(done_move_hook),
			 //.move_wait(move_wait),
			 
			 // these are for releasing hook
			.release_x_start(release_x_start),
			.release_y_start(release_y_start),
			.start_draw_release_hook(start_draw_release_hook),
			.start_release(start_release),
			.done_release(done_release),
			.draw_black_line(draw_black_line),

			// these are for pull back hook
			.start_pull_back(start_pull_back),
			.pull_back_done(pull_back_done),
			.start_draw_back_hook(start_draw_back_hook),
			.start_draw_back_object(start_draw_back_object),
			.back_x_start(back_x_start),
			.back_y_start(back_y_start),
			.pull_back_type(pull_back_type),
			.update_currentbackground(update_currentbackground),

			// these are for updating score
			.reset_score(reset_score),
			.score_x(score_x),
			.score_y(score_y),
			.score_number_type(score_number_type),
			.first(first),
			.second(second),
			.third(third),
			.start_update_score(start_update_score),
			.update_score_done(update_score_done),
			.start_draw_score(start_draw_score),
			
			// for checking score counter
			.enable_check_score_counter(enable_check_score_counter),
			.check_score_counter_done(check_score_counter_done),

			 // output for drawing
		   	 .x_start(x_start),
		    	 .y_start(y_start),
			 .object_type(object_type),

			 .start_draw_bg(start_draw_bg),
			 .draw_bg_done(draw_bg_done),

		    	 .start_draw_object(start_draw_object),
		    	 .draw_object_done(draw_object_done)
		    );

	datapath d0(.clock(CLOCK_50), 
		    .resetn(resetn),  
		    .colour_from_mem(colour_from_mem),
		    .colour_background(colour_background),
			 .colour_currentbackground(colour_currentbackground),
			
		    // for drawing start page letters
		    .draw_start_page_letter(draw_start_page_letter),

		    // input from control
		    .object_type(object_type),
		    .x_start(x_start),
		    .y_start(y_start),

		    // for storing object location address
		    .reset_object_location_address(reset_object_location_address),
		    .object_location_address(object_location_address),
		    .store_object_location(store_object_location),
		    .read_object_location(read_object_location),
		    .reset_object_pullback(reset_object_pullback),

		    // erase signals
		    .erase_move_hook(erase_move_hook),
		    .erase_release_hook(erase_release_hook),
		    .erase_back_hook(erase_back_hook),
		    .erase_back_object(erase_back_object),
			 .erase_back_reached_object(erase_back_reached_object),
			 
		    // for release module
			.check_for_touch(check_for_touch),
			.enable_check_counter(enable_check_counter),
			.ld_check_address(ld_check_address),
			.check_counter_done(check_counter_done),
			.ld_black_line(ld_black_line),

		    // for levels
			.levels(levels),
			.add_level(add_level),
			.reset_level(reset_level),
			 
		    // control signals to draw or store information		
		    .read_mem(read_mem),
		    .load_colour(load_colour),
		    .ld_bg(ld_bg),
		    .ld_colour_bg(ld_colour_bg),
			 .ld_black(ld_black),

			.store_current_bg(store_current_bg),
			.store_type(store_type),
			.type_for_store(type_for_store),
			.type_for_read(type_for_read),
			.type_reached(type_reached),

			
			 .start_release(start_release),
			 .start_pull_back(start_pull_back),
			 
		    .enable_counter_address_background(enable_counter_address_background),
		    .reset_counter_address_background(reset_counter_address_background),
		    .enable_counter_object(enable_counter_object),
		    .reset_counter_object(reset_counter_object),
		    .counter_object(counter_object),
		    .address_object(address_object),
		    .current_address_background(current_address_background),
	   	 .counter_current_address_background(counter_current_address_background),
		    .counter_address_background(counter_address_background),
		    
		    //output for vga
		    .x(x),
		    .y(y),
		    .colour(colour)
    		 );

	 draw_start_page_control start_page(.clk(CLOCK_50),
			.resetn(resetn),
			.start_page_module(start_page_module),
    			.draw_object_done(draw_object_done),
    			.start_page_type(start_page_type),
    			.start_draw_start_page(start_draw_start_page), 
  			.start_page_done(start_page_done),
    			.x_start_page(x_start_page),
    			.y_start_page(y_start_page)
			);

	 draw_next_level_page_control next_level_page(.clk(CLOCK_50),
			.resetn(resetn),
			.start_next_level_page(start_next_level_page),
    			.draw_object_done(draw_object_done),
    			.next_level_page_type(next_level_page_type),
    			.start_draw_next_level(start_draw_next_level), 
  			.next_level_page_done(next_level_page_done),
    			.x_next_level(x_next_level),
    			.y_next_level(y_next_level)
			);

	 draw_fail_page_control fail_page(.clk(CLOCK_50),
			.resetn(resetn),
			.start_fail_page(start_fail_page),
    			.draw_object_done(draw_object_done),
    			.fail_page_type(fail_page_type),
    			.start_draw_fail_page(start_draw_fail_page), 
  			.fail_page_done(fail_page_done),
    			.x_fail_page(x_fail_page),
    			.y_fail_page(y_fail_page)
			);

	 draw_win_page_control win_page(.clk(CLOCK_50),
			.resetn(resetn),
			.start_win_page(start_win_page),
    			.draw_object_done(draw_object_done),
    			.win_page_type(win_page_type),
    			.start_draw_win_page(start_draw_win_page), 
  			.win_page_done(win_page_done),
    			.x_win_page(x_win_page),
    			.y_win_page(y_win_page)
			);

	 draw_object_control object(.clock(CLOCK_50),
			.resetn(resetn),
			.start_draw_object(start_draw_object),
			.object_type(object_type),

			.store_object_location(store_object_location),
			.object_location_address(object_location_address),
			.select_for_object_location(select_for_object_location),

			.store_type(store_type),

			.counter_object(counter_object),
			.draw_object_done(draw_object_done),
			.writeEn(plot_object),
			.read_mem(read_mem),
			.load_colour(load_colour),
			.store_current_bg(store_current_bg),
			.enable_counter_object(enable_counter_object),
			.reset_counter_object(reset_counter_object),
			
			// this is for storing object location in ram timing
			.start_initial_module(start_initial_module)
			
			);
			
			
	 draw_bg_control background(.clock(CLOCK_50),
				.resetn(resetn),
				.start_draw_bg(start_draw_bg),
				.writeEn(plot_bg),
				.clear_screen(clear_screen),
				.counter_address_background(counter_address_background),
				.draw_bg_done(draw_bg_done),
				.ld_bg(ld_bg),
				.ld_colour_bg(ld_colour_bg),
				.ld_black(ld_black),
				.enable_counter_address_background(enable_counter_address_background),
				.reset_counter_address_background(reset_counter_address_background)
	 );

	 draw_initial_objects_control  draw_initial(.clk(CLOCK_50),
					 .resetn(resetn),
					 .start_initial_module(start_initial_module),
					 .draw_object_done(draw_object_done),
					 .object_length(object_length),
					 .object_height(object_height),
					 .levels(levels),
					 .initial_type(initial_type),
					 .start_draw_object_initial(start_draw_object_initial), 
					 .initial_module_done(initial_module_done),
    					 .x_initial_position(x_initial_position),
    					 .y_initial_position(y_initial_position),
					 .x_random(x_random),
					 .y_random(y_random)
					 );

	move_hook_control	move_hook(.clk(CLOCK_50),
    					.resetn(resetn),
						.go(go_down),
    					.start_move_hook(start_move_hook), 
    					.draw_object_done(draw_object_done),
						.done_move_hook(done_move_hook),
						.erase_move_hook(erase_move_hook),
    					.start_draw_hook(start_draw_hook),
    					.hook_x_start(hook_x_start),
    					.hook_y_start(hook_y_start),
						.current_hook_x(current_hook_x),
						.current_hook_y(current_hook_y),
						.enable_counter_move_hook(enable_counter_move_hook), 
						.enable_next_state(enable_next_state)
						//.move_wait(move_wait)
					);

	release_control		release_hook(.clk(CLOCK_50),	
					  .resetn(resetn),
					  .draw_object_done(draw_object_done),
  					  .start_release(start_release), 	// signal to start this control
					  .enable_counter_release(enable_counter_release),  // tell counter time to start
					  .enable_next_release_state(enable_next_release_state), // from counter time to go to the next state
	
	
					  .current_hook_x(current_hook_x),
					  .current_hook_y(current_hook_y),
					  // into datapath
					  // for comparing whether there's a object exist at that address
					  .check_for_touch(check_for_touch),	// if 0, go down, else, return up
				  	  .check_counter_done(check_counter_done),
					  .ld_check_address(ld_check_address),
					  .enable_check_counter(enable_check_counter),   // signal for check counter
		
					  .erase_release_hook(erase_release_hook),    //singal for erasing hook at current location, need to take background colour
    					  .start_draw_release_hook(start_draw_release_hook),   // for draw hook, tell upper control to draw_object
					  .done_release(done_release),   // signal to tell upper control this is done
    					  .release_x_start(release_x_start),
    					  .release_y_start(release_y_start),

					  .current_release_x(current_release_x),
					  .current_release_y(current_release_y),
						  
					  .draw_black_line(draw_black_line),
					  .ld_black_line(ld_black_line),

					  .reach_bottom(reach_bottom)
					  );		
					  
		pull_back_control back_control(.clk(CLOCK_50),	
					.resetn(resetn),
					.type_reached(type_reached),
					.start_pull_back(start_pull_back), 
					.pull_back_done(pull_back_done),
					
								 
					// for audio
					.audio(audio_pull_back),

					.draw_object_done(draw_object_done),

					.counter_object(counter_object),
					.reset_object_pullback(reset_object_pullback),
					.read_object_location(read_object_location),

					.enable_next_nothingback_state(enable_next_nothingback_state), // from counter time to go to the next state
					.enable_counter_nothingback(enable_counter_nothingback),  // tell counter time to start
					.enable_next_GLRL_state(enable_next_GLRL_state),
					.enable_counter_GLRL(enable_counter_GLRL),
					.enable_next_GMRM_state(enable_next_GMRM_state),
					.enable_counter_GMRM(enable_counter_GMRM),
					.enable_pull_back_done_state(enable_pull_back_done_state),
					.enable_counter_point5sec(enable_counter_point5sec),
									
					.update_currentbackground(update_currentbackground),

					// the location at which when the it was released
					.current_release_x(current_release_x),
					.current_release_y(current_release_y),
					.reach_bottom(reach_bottom),
		
					.erase_back_hook(erase_back_hook),    
					.start_draw_back_hook(start_draw_back_hook), 
					.back_x_start(back_x_start),
					.back_y_start(back_y_start),
					.pull_back_type(pull_back_type),
					
					// for pull back specific object
					.object_location_length(object_location_length),
					.start_draw_back_object(start_draw_back_object),
					. erase_back_object(erase_back_object),
					
					
					.erase_back_reached_object(erase_back_reached_object)
					);

	update_score_control	update_score(.clk(CLOCK_50),	
					.resetn(resetn),
					.type_reached(type_reached),
					.reset_score(reset_score),
					.score_x(score_x),
					.score_y(score_y),
					.score_number_type(score_number_type),
					.first(first),
					.second(second),
					.third(third),
					.start_update_score(start_update_score),
					.draw_object_done(draw_object_done),
					.update_score_done(update_score_done),
					.start_draw_score(start_draw_score)
					);
	
	
	
	// below are memories

    	ram_objects numObject (.address(address_object),
	    	     .data(6'b0),
	    	     .clock(CLOCK_50),
	    	     .wren(1'b0),
  	    	     .q(colour_from_mem)
	    	     );
				  
    	ram_current_bg rcurrent_bg (.address(current_address_background),
		      .data(colour),
		      .clock(CLOCK_50),
            .wren(select),
		      .q(colour_currentbackground)
		      );	
				
	ram_background rbackground(.address(current_address_background),
		      .data(6'b0),
		      .clock(CLOCK_50),
            .wren(1'b0),
		      .q(colour_background)
		      );	
				
	ram_type rtype(.address(current_address_background),
						.data(type_for_store),
						.clock(CLOCK_50),
						.wren(select_for_type),
						.q(type_for_read)
				);

	ram_object_loaction_length object_loaction(.address(object_location_address),
						.data({object_length, x, object_height, y}),
						.clock(CLOCK_50),
						.wren(select_object_location),
						.q(object_location_length)
						);

	// counters for count time, for example 1/60 s
	counter_move_hook count_move(.clk(CLOCK_50),
		      .enable_my_counter(enable_counter_move_hook),
		      .enable_next(enable_next_state),
				.levels(levels)
		     ); 

	counter_releaseNback_hook count_release(.clk(CLOCK_50),
					.enable_my_counter(enable_counter_release),
					.enable_next(enable_next_release_state)
					);

	counter_releaseNback_hook count_nothingback(.clk(CLOCK_50),
					.enable_my_counter(enable_counter_nothingback),
					.enable_next(enable_next_nothingback_state)	
					);

	counter_GLRL count_GLRL(.clk(CLOCK_50),
					.enable_my_counter(enable_counter_GLRL),
					.enable_next(enable_next_GLRL_state)
					);

	counter_GMRM count_GMRM(.clk(CLOCK_50),
					.enable_my_counter(enable_counter_GMRM),
					.enable_next(enable_next_GMRM_state)
					);	

	counter_point5sec count_for_pull_back(.clk(CLOCK_50),
					.enable_my_counter(enable_counter_point5sec),
					.enable_next(enable_pull_back_done_state)	
					);	
					
	counter_point5sec count_for_check_score(.clk(CLOCK_50),
					.enable_my_counter(enable_check_score_counter),
					.enable_next(check_score_counter_done)	
					);

	counter_point5sec count_for_audio_success(.clk(CLOCK_50),
					.enable_my_counter(enable_audio_success),
					.enable_next(audio_success_counter_done)	
					);

	counter_point5sec count_for_audio_fail(.clk(CLOCK_50),
					.enable_my_counter(enable_audio_fail),
					.enable_next(audio_fail_counter_done)	
					);
					
	counter_5sec  count_for_five_sec(.clk(CLOCK_50),
					.enable_my_counter(enable_5),
					.enable_next(enable_next_counter_5)	
					);

	counterDown   count30sec(.clk(CLOCK_50),	
				.resetn(resetn),
				.tenth(tenth),
				.oneth(oneth),
				.enable(enable_start_count),
				.time_done(time_done)
				);

	decoder decoder0(oneth[3], oneth[2], oneth[1], oneth[0], HEX0);
	decoder decoder1(tenth[3], tenth[2], tenth[1], tenth[0], HEX1);

	lfsr  my_lfsr(.clk(CLOCK_50),
			.resetn(resetn),
			.x_initial(x_random),
			.y_initial(y_random)
			);

	audio_win audio_w (.clk(CLOCK_50),	
			.resetn(resetn),
			.enable_audio_success(enable_audio_success),
			.audio_success_counter_done(audio_success_counter_done),
			.start_audio_success(start_audio_success),
			.audio_success_done(audio_success_done),
			.audio_success(audio_success)
			);

	audio_fail audio_f (.clk(CLOCK_50),	
			.resetn(resetn),
			.enable_audio_fail(enable_audio_fail),
			.audio_fail_counter_done(audio_fail_counter_done),
			.start_audio_fail(start_audio_fail),
			.audio_fail_done(audio_fail_done),
			.audio_fail(audio_fail)
			);
			
			
	DE1_SoC_Audio(.CLOCK_50(CLOCK_50),
						.KEY(KEY),
						.AUD_ADCDAT(AUD_ADCDAT),
						.AUD_BCLK(AUD_BCLK),
						.AUD_ADCLRCK(AUD_ADCLRCK),
						.AUD_DACLRCK(AUD_DACLRCK),

						.FPGA_I2C_SDAT(FPGA_I2C_SDAT),

						// Outputs
						.AUD_XCK(AUD_XCK),
						.AUD_DACDAT(AUD_DACDAT),

						.FPGA_I2C_SCLK(FPGA_I2C_SCLK),
						.SW(audio)
						);

					
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 2;
		defparam VGA.BACKGROUND_IMAGE = "goldminerstart.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	
endmodule


module decoder(C3, C2, C1, C0, OUT);
	input C0,C1,C2,C3;
	output [6:0] OUT;
	assign OUT[0]=(~C3&~C2&~C1&C0)|(~C3&C2&~C1&~C0)|(C3&~C2&C1&C0)|(C3&C2&~C1&C0);
	assign OUT[1]=(~C3&C2&~C1&C0)|(~C3&C2&C1&~C0)|(C3&~C2&C1&C0)|(C3&C2&~C1&~C0)|(C3&C2&C1&~C0)|(C3&C2&C1&C0);
	assign OUT[2]=(~C3&~C2&C1&~C0)|(C3&C2&~C1&~C0)|(C3&C2&C1&~C0)|(C3&C2&C1&C0);
	assign OUT[3]=(~C3&~C2&~C1&C0)|(~C3&C2&~C1&~C0)|(~C3&C2&C1&C0)|(C3&~C2&C1&~C0)|(C3&C2&C1&C0);
	assign OUT[4]=(~C3&~C2&~C1&C0)|(~C3&~C2&C1&C0)|(~C3&C2&~C1&~C0)|(~C3&C2&~C1&C0)|(~C3&C2&C1&C0)|(C3&~C2&~C1&C0);
	assign OUT[5]=(~C3&~C2&~C1&C0)|(~C3&~C2&C1&~C0)|(~C3&~C2&C1&C0)|(~C3&C2&C1&C0)|(C3&C2&~C1&C0);
	assign OUT[6]=(~C3&~C2&~C1&~C0)|(~C3&~C2&~C1&C0)|(~C3&C2&C1&C0)|(C3&C2&~C1&~C0);
endmodule
