
module datapath(
  input clock, resetn,  
	  	input [4:0] object_type,
		input [5:0] colour_from_mem,
		input [5:0] colour_background,
		input [5:0] colour_currentbackground,

		// for drawing start page letters
		input draw_start_page_letter,

		// for store, read the type of object
		output reg [4:0] type_for_store,

		input [4:0] type_for_read,
		output reg [4:0] type_reached,

		// for storing object_location_address
		input reset_object_location_address,
		output reg [3:0] object_location_address,
		input store_object_location, read_object_location,
		input reset_object_pullback,

		// for release module
		output reg [4:0] check_for_touch,
		input enable_check_counter,
		input ld_check_address,
		output reg check_counter_done,
		
		input erase_release_hook,
		input erase_move_hook,
		input erase_back_hook,
		input erase_back_object,
		input erase_back_reached_object,
		
		input ld_black_line,

		// for levels
		output reg [1:0] levels,
	 	input add_level,
	 	input reset_level,
		
		
		// input from release and pull back, for drawing and erasing
		input start_release,
		input start_pull_back,

		input read_mem, load_colour, ld_bg, ld_colour_bg, ld_black, store_current_bg, store_type,
		input enable_counter_object, reset_counter_object,
		input enable_counter_address_background, reset_counter_address_background,
		input [8:0] x_start,
		input [7:0] y_start,
		output reg [9:0] counter_object,
		output reg [14:0] address_object,
		output reg [16:0] current_address_background,
		output reg [4:0] counter_current_address_background,
		output reg [16:0] counter_address_background,
		output reg [8:0] x,
		output reg [7:0] y,
		output reg [5:0] colour
    );


    // Registers x, y, colour with respective input logic
    always@(posedge clock) begin
        if(!resetn) begin
            address_object <= 15'b0;
	    current_address_background <= 17'b0;
	    counter_object <= 10'd1;
	    counter_current_address_background <= 5'b0;
	    counter_address_background <= 17'b0;
	    colour <= 6'b0;
	    x <= 9'b0;
	    y <= 8'b0;
        end
	

	else begin

	// for levels
		if (reset_level)
			levels <= 2'b1;

		if (add_level)
			levels <= levels + 1'b1;

	// for reset object location address
	 	if(reset_object_location_address || reset_object_pullback)
			object_location_address <= 4'd0;
	
	// for storing object_location
		if(store_object_location || read_object_location)
			object_location_address <= object_location_address + 1'b1;

	// for draw black line

		if(ld_black_line) begin
			x <= x_start + 4'd8;
			y <= y_start;
			colour <= 6'd0;
		end

		

	// for checking whether the hook is going to touch object

		if (ld_check_address) begin
			current_address_background <= (y_start + 4'd10) * 9'd320 + x_start;	// 4'd10 for height of the hook
			check_for_touch <= 5'd0;
			check_counter_done <= 1'b0;
			type_reached <= 5'd0;
		end

		if (enable_check_counter) begin
			current_address_background <= current_address_background + 1'b1;
			check_for_touch <= (colour_currentbackground == colour_background || colour_currentbackground == 6'b0) ? check_for_touch: check_for_touch + 1'b1;
			if (colour_currentbackground != colour_background && colour_currentbackground != 6'b0)
				type_reached <= type_for_read;
			if (current_address_background == (y_start + 4'd10) * 9'd320 + x_start + 5'd16)  // 16 is the length of the hook
				check_counter_done <= 1'b1;
			else
				check_counter_done <= 1'b0;
		end		
	
	
	
	// for drawing background
		if (ld_bg) begin
		   current_address_background <= 17'b0;
			x <= 9'b0;
			y <= 8'b0;
		end	

		if (ld_black)
			colour <= 6'b0;

		if (ld_colour_bg) 
			colour <= colour_background;
				
		if (enable_counter_address_background) begin
			counter_address_background <= counter_address_background + 1'b1;
			current_address_background <= current_address_background + 1'b1;
			if (x == 9'd319) begin
				x <= 9'b0;
				y <= y + 1'b1;
			end
			
			else
				x <= x + 1'b1;
        end	
		
		if(reset_counter_address_background)
			counter_address_background <= 17'b0;

	

	// for drawing single object
		if(read_mem) begin 

		    if(object_type == 5'd0)  begin
			 	    counter_current_address_background <= 5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
                	address_object <= 15'b0;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd1) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd320;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd2) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd640;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd3) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd960;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd4) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd1280;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd5) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd1600;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd6) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd1920;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd7) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd2240;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd8) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd2560;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd9) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd2880;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd10) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd3200;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd11) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd3680;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd12) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd4640;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd13) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd5120;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd14) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd5760;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd15) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd6400;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd16) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd7488;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd17) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd8544;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd18) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd9632;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd19) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd10752;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd20) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd11840;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd21) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd12928;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd22) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd14048;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd23) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd15136;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd24) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd16224;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd25) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd17312;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd26) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd18400;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd27) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd19456;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd28) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd20544;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd29) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd21632;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd30) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd22720;
			x <= x_start;
			y <= y_start;
			end
		    else if(object_type == 5'd31) begin
			 	    counter_current_address_background <=  5'b0;
			 		    current_address_background <= y_start * 9'd320 + x_start;
			address_object <= 15'd23744;
			x <= x_start;
			y <= y_start;
			end
		    else
			x <= x_start;
			y <= y_start;
			end

            
		if(load_colour) begin
		
		   if (draw_start_page_letter)
			colour <= colour_from_mem;

		   // for erase case, use background colour
		   else if (erase_move_hook || erase_release_hook || erase_back_hook || erase_back_object) begin
				if (colour_currentbackground == 6'b0)
					colour <= colour_background;
				else
					colour <= colour_currentbackground;
			end
			
			else if(erase_back_reached_object)
				colour <= colour_background;
		   
			// for not erase cases	
		   else if(colour_from_mem == 6'b111111) begin
				if (start_release || start_pull_back) begin
					if (colour_currentbackground != 6'b0)
						colour <= colour_currentbackground;
					else
						colour <= colour_background;
				end
				else
					colour <= colour_background;
		   end
		  
		   else 
            		colour <= colour_from_mem;
		end
		

		if (store_type) begin
			if (colour == colour_background)
				type_for_store <= 5'd0;
			else
				type_for_store <= object_type;
		end
		
		if (store_current_bg) begin
			address_object <= address_object + 1'b1;
			if (counter_current_address_background == 5'd31) begin
			 counter_current_address_background <= 5'b0;
			  current_address_background <= current_address_background + 9'd320 - 5'd31;
			end
			else begin
			  current_address_background <= current_address_background + 1'b1;
			  counter_current_address_background <= counter_current_address_background + 1'b1;
			end
		end
			
		

			
            
		if(enable_counter_object) begin
			counter_object <= counter_object + 1'b1;
			x <= x_start + counter_object[4:0];	
			y <= y_start + counter_object[9:5];
		end
		
		if(reset_counter_object) begin
		  counter_object <= 10'd1;
		end
   
    end
	 end



 endmodule
