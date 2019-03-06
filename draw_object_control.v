
module draw_object_control(input clock, resetn, start_draw_object,
			   input [4:0] object_type,
			   input [9:0] counter_object,
			   input [3:0] object_location_address,
				input start_initial_module,
			   output reg  select_for_object_location, store_object_location,
			   output reg  store_type, 
			   output reg  draw_object_done, writeEn,
			   output reg  read_mem, load_colour, store_current_bg,
			   output reg  enable_counter_object, reset_counter_object	
			   );

    reg[4:0] current_state, next_state;

    localparam  S_WAIT_DRAW	     	= 5'd0,
		S_READ_MEM           	= 5'd1,
		S_STORE_OBJECT_LOCATION = 5'd2,
		S_WAIT_FOR_READ	     	= 5'd3,
		S_LOAD_COLOUR	     	= 5'd4,
		S_STORE_TYPE	     	= 5'd5,
		S_STORE_CURRENT_BG   	= 5'd6,
		S_DRAW_OBJECT	     	= 5'd7,
		S_DONE_OBJECT	     	= 5'd8;
		
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_WAIT_DRAW: next_state = start_draw_object ? S_READ_MEM: S_WAIT_DRAW;
		
		// for draw objects
		S_READ_MEM:  next_state = start_initial_module? S_STORE_OBJECT_LOCATION: S_WAIT_FOR_READ;
		S_STORE_OBJECT_LOCATION: next_state = S_WAIT_FOR_READ;
		S_WAIT_FOR_READ: next_state = S_LOAD_COLOUR;
		S_LOAD_COLOUR: next_state = S_STORE_TYPE;
		S_STORE_TYPE: next_state = S_STORE_CURRENT_BG;
		S_STORE_CURRENT_BG: next_state = S_DRAW_OBJECT;
		S_DRAW_OBJECT: if(object_type == 5'd0 || object_type == 5'd1 || object_type == 5'd2 || object_type == 5'd3 ||
				  object_type == 5'd4 || object_type == 5'd5 || object_type == 5'd6 || object_type == 5'd7 ||
				  object_type == 5'd8 || object_type == 5'd9)
					next_state = (counter_object == 10'd224) ? S_DONE_OBJECT : S_LOAD_COLOUR;
				else if(object_type == 5'd10)
					next_state = (counter_object == 10'd384) ? S_DONE_OBJECT : S_LOAD_COLOUR;
				else if(object_type == 5'd11)
					next_state = (counter_object == 10'd736) ? S_DONE_OBJECT : S_LOAD_COLOUR;
				else if(object_type == 5'd12)
					next_state = (counter_object == 10'd320) ? S_DONE_OBJECT : S_LOAD_COLOUR;
				else if(object_type == 5'd13)
					next_state = (counter_object == 10'd544) ? S_DONE_OBJECT : S_LOAD_COLOUR;
				else if(object_type == 5'd14)
					next_state = (counter_object == 10'd416) ? S_DONE_OBJECT : S_LOAD_COLOUR;
				else if (object_type == 5'd15 || object_type == 5'd16 || object_type == 5'd17 || object_type == 5'd18 ||
				  object_type == 5'd19 || object_type == 5'd20 || object_type == 5'd21 || object_type == 5'd22 ||
				  object_type == 5'd23 || object_type == 5'd24 || object_type == 5'd25 || object_type == 5'd26 || object_type == 5'd27 || 
				  object_type == 5'd28 || object_type == 5'd29 || object_type == 5'd30 || object_type == 5'd31)
					next_state = (counter_object == 10'd480) ? S_DONE_OBJECT : S_LOAD_COLOUR;
				else
					next_state = S_DONE_OBJECT;
		S_DONE_OBJECT: next_state = start_draw_object ? S_DONE_OBJECT : S_WAIT_DRAW;

            default:     next_state = S_WAIT_DRAW;
        endcase
    end // state_table

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
	draw_object_done = 0;
	writeEn = 0;
	read_mem = 0; 
	load_colour = 0; 
	enable_counter_object = 0;
 	reset_counter_object = 0;
	store_current_bg = 0;
	store_type = 0;
	store_object_location = 0;
	select_for_object_location = 0;

        case (current_state)
		  
		S_WAIT_DRAW: begin
				reset_counter_object = 1;
			     end

		S_READ_MEM: 
				read_mem = 1;
//				if(object_location_address < 4'd12)
//					select_for_object_location = 1;
//				else
//					select_for_object_location = 0;
//				end
		
		S_STORE_OBJECT_LOCATION: begin

				if(object_location_address < 4'd12) begin
					select_for_object_location = 1;
					store_object_location = 1;
				end
				else begin
					select_for_object_location = 0;
					store_object_location = 0;
				end
				
		end

		S_LOAD_COLOUR: load_colour = 1;

		S_STORE_TYPE: store_type = 1;

		S_STORE_CURRENT_BG: 
			store_current_bg = 1;
	
		S_DRAW_OBJECT: begin
				writeEn = 1;
				enable_counter_object = 1;
			       end		
		S_DONE_OBJECT: draw_object_done = 1;
		 
		

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
