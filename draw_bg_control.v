
module draw_bg_control(input clock, resetn, start_draw_bg,
		    	input [16:0] counter_address_background,
			input clear_screen,
			output reg draw_bg_done, writeEn,
			output reg ld_bg, ld_colour_bg,	ld_black,
			output reg enable_counter_address_background, reset_counter_address_background
			   );

    reg[4:0] current_state, next_state;

    localparam  S_WAIT_DRAW	     = 5'd0,
	   	S_LOAD_BG		= 5'd1,
		S_WAIT_FOR_READ_BG = 5'd2,
		S_LOAD_COLOUR_BG  =5'd3,
		S_DRAW_BG	     = 5'd5,
		S_DONE_BG	     = 5'd6;

		
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_WAIT_DRAW: next_state = start_draw_bg ? S_LOAD_BG: S_WAIT_DRAW;
		// for drawing background
		S_LOAD_BG: next_state = S_WAIT_FOR_READ_BG;  // load initial x,y
		S_WAIT_FOR_READ_BG: next_state = S_LOAD_COLOUR_BG;  // wait for address to change and read in colour
		S_LOAD_COLOUR_BG: next_state = S_DRAW_BG;  // wait one pulse to read in colour
		S_DRAW_BG: next_state = (counter_address_background == 17'd76800) ? S_DONE_BG: S_WAIT_FOR_READ_BG;
		S_DONE_BG: next_state = start_draw_bg ? S_DONE_BG : S_WAIT_DRAW;

            default:     next_state = S_WAIT_DRAW;
        endcase
    end // state_table

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
   	draw_bg_done = 0;
	enable_counter_address_background = 0;
	reset_counter_address_background = 0;
	ld_bg = 0;
	ld_colour_bg = 0;
	ld_black = 0;
	writeEn = 0;

        case (current_state)
		  
		S_WAIT_DRAW: begin
				reset_counter_address_background = 1;
			     end
				  
		S_LOAD_BG: 
				ld_bg = 1; // for initialize x,y to be 0,0
				
		S_LOAD_COLOUR_BG: begin
				if (clear_screen)
				ld_black = 1;
				else
				ld_colour_bg = 1;
				end
				
		S_DRAW_BG: begin
				writeEn = 1;
				enable_counter_address_background = 1;
			   end

		S_DONE_BG: draw_bg_done = 1;
		 
	
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(!resetn)
            current_state <= S_WAIT_DRAW;
        else
            current_state <= next_state;
    end // state_FFS

endmodule
