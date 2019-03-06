
module draw_initial_objects_control(
    input clk,
    input resetn,
    input start_initial_module,
    input draw_object_done,
    input [1:0] levels,
    input [8:0] x_random,
    input [7:0] y_random,
    output reg [4:0] object_length,
    output reg [4:0] object_height,
    output reg [4:0] initial_type,
    output reg start_draw_object_initial, initial_module_done,
    output reg [8:0] x_initial_position,
    output reg [7:0] y_initial_position
	
    );

    reg [5:0] current_state, next_state; 
	 reg [8:0] x_initial;
	 reg [7:0] y_initial;
	 
	 reg load_xy;
    
    localparam  S_WAIT_FOR_COMMAND		= 6'd0,
		S_LOAD_GL1_POSITION		= 6'd1,
		S_DRAW_GL1			= 6'd2,
		S_LOAD_RL1_POSITION		= 6'd3,
		S_DRAW_RL1			= 6'd4,
		S_LOAD_GM1_POSITION		= 6'd5,
		S_DRAW_GM1			= 6'd6,
		S_LOAD_RM1_POSITION		= 6'd7,
		S_DRAW_RM1			= 6'd8,
		
		
		S_LOAD_GL2_POSITION		= 6'd9,
		S_DRAW_GL2			= 6'd10,
		S_LOAD_RL2_POSITION		= 6'd11,
		S_DRAW_RL2			= 6'd12,
		S_LOAD_GM2_POSITION		= 6'd13,
		S_DRAW_GM2			= 6'd14,
		S_LOAD_RM2_POSITION		= 6'd15,
		S_DRAW_RM2			= 6'd16,
		
		S_LOAD_RL3_POSITION		= 6'd17,
		S_DRAW_RL3			= 6'd18,		
		S_LOAD_GM3_POSITION		= 6'd19,
		S_DRAW_GM3			= 6'd20,
		S_LOAD_RM3_POSITION		= 6'd21,
		S_DRAW_RM3			= 6'd22,
		S_LOAD_GM4_POSITION		= 6'd23,
		S_DRAW_GM4			= 6'd24,

		S_LOAD_COUNTER_NUM1_POSITION	= 6'd27,
		S_DRAW_COUNTER_NUM1		= 6'd28,
		S_LOAD_COUNTER_NUM2_POSITION	= 6'd29,
		S_DRAW_COUNTER_NUM2		= 6'd30,
		S_LOAD_LEVEL_POSITION		= 6'd31,
		S_DRAW_LEVEL			= 6'd32,
		S_LOAD_GOAL_NUM1_POSITION	= 6'd33,
		S_DRAW_GOAL_NUM1		= 6'd34,
		S_LOAD_GOAL_NUM2_POSITION	= 6'd35,
		S_DRAW_GOAL_NUM2		= 6'd36,
		S_LOAD_GOAL_NUM3_POSITION	= 6'd37,
		S_DRAW_GOAL_NUM3		= 6'd38,
		S_LOAD_MONEY_POSITION		= 6'd39,
		S_DRAW_MONEY			= 6'd40,
		S_DONE_DRAW_INITIAL	= 6'd41;  
					 

    // Next state logic aka our state table
    always@(*)
    begin: state_table 
		case (current_state)
					
			S_WAIT_FOR_COMMAND: next_state = start_initial_module? S_LOAD_GL1_POSITION: S_WAIT_FOR_COMMAND;
			
			S_LOAD_GL1_POSITION: next_state = S_DRAW_GL1;
			S_DRAW_GL1: next_state = draw_object_done? S_LOAD_RL1_POSITION: S_DRAW_GL1;
			
			S_LOAD_RL1_POSITION: next_state = S_DRAW_RL1;
			S_DRAW_RL1: next_state = draw_object_done? S_LOAD_GM1_POSITION: S_DRAW_RL1;
			
			S_LOAD_GM1_POSITION: next_state = S_DRAW_GM1;
			S_DRAW_GM1: next_state = draw_object_done? S_LOAD_RM1_POSITION: S_DRAW_GM1;
			
			S_LOAD_RM1_POSITION: next_state = S_DRAW_RM1;
			S_DRAW_RM1: next_state = draw_object_done? S_LOAD_GL2_POSITION: S_DRAW_RM1;
			
			S_LOAD_GL2_POSITION: next_state = S_DRAW_GL2;
			S_DRAW_GL2: next_state = draw_object_done? S_LOAD_RL2_POSITION: S_DRAW_GL2;
			
			S_LOAD_RL2_POSITION: next_state = S_DRAW_RL2;
			S_DRAW_RL2: next_state = draw_object_done? S_LOAD_GM2_POSITION: S_DRAW_RL2;
			
			S_LOAD_GM2_POSITION: next_state = S_DRAW_GM2;
			S_DRAW_GM2: next_state = draw_object_done? S_LOAD_RM2_POSITION: S_DRAW_GM2;
						
			S_LOAD_RM2_POSITION: next_state = S_DRAW_RM2;
			S_DRAW_RM2: next_state = draw_object_done? S_LOAD_RL3_POSITION: S_DRAW_RM2;
			
			S_LOAD_RL3_POSITION: next_state = S_DRAW_RL3;
			S_DRAW_RL3: next_state = draw_object_done? S_LOAD_GM3_POSITION: S_DRAW_RL3;
			
			S_LOAD_GM3_POSITION: next_state = S_DRAW_GM3;
			S_DRAW_GM3: next_state = draw_object_done? S_LOAD_RM3_POSITION: S_DRAW_GM3;				
					
			S_LOAD_RM3_POSITION: next_state = S_DRAW_RM3;
			S_DRAW_RM3: next_state = draw_object_done? S_LOAD_GM4_POSITION: S_DRAW_RM3;
			
			S_LOAD_GM4_POSITION: next_state = S_DRAW_GM4; 
			S_DRAW_GM4: next_state = draw_object_done? S_LOAD_LEVEL_POSITION : S_DRAW_GM4;
			

			
			
			//S_LOAD_HOOK_POSITION: next_state = S_DRAW_HOOK;
			//S_DRAW_HOOK: next_state = draw_object_done? S_LOAD_COUNTER_NUM1_POSITION: S_DRAW_HOOK;
			
//			S_LOAD_COUNTER_NUM1_POSITION: next_state = S_DRAW_COUNTER_NUM1;
//			S_DRAW_COUNTER_NUM1: next_state = draw_object_done? S_LOAD_COUNTER_NUM2_POSITION: S_DRAW_COUNTER_NUM1;
//			
//			S_LOAD_COUNTER_NUM2_POSITION: next_state = S_DRAW_COUNTER_NUM2;
//			S_DRAW_COUNTER_NUM2: next_state = draw_object_done? S_LOAD_LEVEL_POSITION: S_DRAW_COUNTER_NUM2;

			S_LOAD_LEVEL_POSITION: next_state = S_DRAW_LEVEL;
			S_DRAW_LEVEL: next_state = draw_object_done? S_LOAD_GOAL_NUM1_POSITION: S_DRAW_LEVEL;
			
			S_LOAD_GOAL_NUM1_POSITION: next_state = S_DRAW_GOAL_NUM1;
			S_DRAW_GOAL_NUM1: next_state = draw_object_done? S_LOAD_GOAL_NUM2_POSITION: S_DRAW_GOAL_NUM1;

			S_LOAD_GOAL_NUM2_POSITION: next_state = S_DRAW_GOAL_NUM2;
			S_DRAW_GOAL_NUM2: next_state = draw_object_done? S_LOAD_GOAL_NUM3_POSITION: S_DRAW_GOAL_NUM2;

			S_LOAD_GOAL_NUM3_POSITION: next_state = S_DRAW_GOAL_NUM3;
			S_DRAW_GOAL_NUM3: next_state = draw_object_done? S_LOAD_MONEY_POSITION: S_DRAW_GOAL_NUM3;

			S_LOAD_MONEY_POSITION: next_state = S_DRAW_MONEY;
			S_DRAW_MONEY: next_state = draw_object_done? S_DONE_DRAW_INITIAL: S_DRAW_MONEY;
			
			S_DONE_DRAW_INITIAL: next_state = start_initial_module? S_DONE_DRAW_INITIAL: S_WAIT_FOR_COMMAND;	

            default:   next_state = S_WAIT_FOR_COMMAND;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0

    		start_draw_object_initial = 1'b0;
			initial_module_done = 1'b0;
			x_initial_position = 9'b0;
			y_initial_position = 8'b0;
			object_length = 5'b0;
			object_height = 5'b0;
			initial_type = 5'b0;
			
			load_xy = 1'b0;


        case (current_state)
		  
		S_LOAD_GL1_POSITION: load_xy = 1'b1;
       
		S_DRAW_GL1: begin
				     start_draw_object_initial = 1'b1;
				     x_initial_position = x_initial; //9'd55;
				     y_initial_position = y_initial; //8'd160;
				     initial_type = 5'd11; 
				     object_length = 5'd24;
				     object_height = 5'd22;
		end				
		
		S_LOAD_GL2_POSITION: load_xy = 1'b1;

		S_DRAW_GL2:  begin
				     start_draw_object_initial = 1'b1;
				     x_initial_position = x_initial; //9'd280;
				     y_initial_position = y_initial; //8'd105;
				     initial_type = 5'd11;
				     object_length = 5'd24;
				     object_height = 5'd22;
		end
		
		S_LOAD_GM1_POSITION: load_xy = 1'b1;

		S_DRAW_GM1: begin
					start_draw_object_initial = 1'b1;
				     x_initial_position = x_initial; //9'd15;
				     y_initial_position = y_initial; //8'd58;
				     initial_type = 5'd10;  
				     object_length = 5'd12;
				     object_height = 5'd11;
		end
		
		S_LOAD_GM2_POSITION: load_xy = 1'b1;

		S_DRAW_GM2: begin
					start_draw_object_initial = 1'b1;
				     x_initial_position = x_initial; //9'd246;
				     y_initial_position = y_initial; //8'd167;
				     initial_type = 5'd10;
				     object_length = 5'd12;
				     object_height = 5'd11;
		end

		S_LOAD_GM3_POSITION: load_xy = 1'b1;

		S_DRAW_GM3: begin
					start_draw_object_initial = 1'b1;
				     x_initial_position = x_initial; //9'd287;
				     y_initial_position = y_initial; //8'd82;
				     initial_type = 5'd10;
				     object_length = 5'd12; 
				     object_height = 5'd11; 
		end
		
		S_LOAD_GM4_POSITION: load_xy = 1'b1;

		S_DRAW_GM4:  begin
					start_draw_object_initial = 1'b1;
				     x_initial_position = x_initial; //9'd201;
				     y_initial_position = y_initial; //8'd205;
				     initial_type = 5'd10;  
				     object_length = 5'd12;
				     object_height = 5'd11;
		end
		
		S_LOAD_RL1_POSITION: load_xy = 1'b1;

		S_DRAW_RL1: begin
					start_draw_object_initial = 1'b1;
				     x_initial_position = x_initial; //9'd143;
				     y_initial_position = y_initial; //8'd186;
				     initial_type = 5'd13; 
				     object_length = 5'd19; 
				     object_height = 5'd16;
		end
		
		S_LOAD_RL2_POSITION: load_xy = 1'b1;

		S_DRAW_RL2: begin
					start_draw_object_initial = 1'b1;
				     x_initial_position = x_initial; //9'd95;
				     y_initial_position = y_initial; //8'd127;
				     initial_type = 5'd13; 
				     object_length = 5'd19; 
				     object_height = 5'd16; 
		end
		
		S_LOAD_RL3_POSITION: load_xy = 1'b1;

		S_DRAW_RL3: begin
					start_draw_object_initial = 1'b1;
				     x_initial_position = x_initial; //9'd253;
				     y_initial_position = y_initial; //8'd135;
				     initial_type = 5'd13;  
				     object_length = 5'd19; 
				     object_height = 5'd16;
		end
		
		S_LOAD_RM1_POSITION: load_xy = 1'b1;

		S_DRAW_RM1: begin
					start_draw_object_initial = 1'b1;
				     x_initial_position = x_initial; //9'd30;
				     y_initial_position = y_initial; //8'd108;
				     initial_type = 5'd14;
				     object_length = 5'd14; 
				     object_height = 5'd12;  
		end 
		
		S_LOAD_RM2_POSITION: load_xy = 1'b1;

		S_DRAW_RM2: begin
					start_draw_object_initial = 1'b1;
				     x_initial_position = x_initial; //9'd168;
				     y_initial_position = y_initial; //8'd87;
				     initial_type = 5'd14; 
				     object_length = 5'd14; 
				     object_height = 5'd12;  
		end
		
		S_LOAD_RM3_POSITION: load_xy = 1'b1;

		S_DRAW_RM3:  begin
					start_draw_object_initial = 1'b1;
				     x_initial_position = x_initial; //9'd90;
				     y_initial_position = y_initial; //8'd204;
				     initial_type = 5'd14;
				     object_length = 5'd14; 
				     object_height = 5'd12;  
		end


//		S_DRAW_COUNTER_NUM1: begin
//					start_draw_object_initial = 1'b1;
//				     x_initial_position = 9'd284;
//				     y_initial_position = 8'd9;
//				     initial_type = 5'd6;
//		end
//
//		S_DRAW_COUNTER_NUM2: begin
//					start_draw_object_initial = 1'b1;
//				     x_initial_position = 9'd292;
//				     y_initial_position = 8'd9;
//				     initial_type = 5'd0; 
//		end

		S_DRAW_LEVEL: begin
				   
				start_draw_object_initial = 1'b1;
				x_initial_position = 9'd284;
				y_initial_position = 8'd21;
				if (levels == 2'd1)
				     initial_type = 5'd1; 
				else if (levels == 2'd2)
				     initial_type = 5'd2;
				else if (levels == 2'd3)
				     initial_type = 5'd3;
		end

		S_DRAW_GOAL_NUM1: begin
				start_draw_object_initial = 1'b1;
				x_initial_position = 9'd39;
				y_initial_position = 8'd21;
				if (levels == 2'd1)
				     initial_type = 5'd2; 
				else if (levels == 2'd2)
				     initial_type = 5'd3;
				else if (levels == 2'd3)
				     initial_type = 5'd5;

		end

		S_DRAW_GOAL_NUM2: begin
					start_draw_object_initial = 1'b1;
				     x_initial_position = 9'd47;
				     y_initial_position = 8'd21;
				     initial_type = 5'd0;  
		end

		S_DRAW_GOAL_NUM3: begin
					start_draw_object_initial = 1'b1;
				     x_initial_position = 9'd55;
				     y_initial_position = 8'd21;
				     initial_type = 5'd0;  
		end

		S_DRAW_MONEY: begin
					start_draw_object_initial = 1'b1;
				     x_initial_position = 9'd67;
				     y_initial_position = 8'd9;
				     initial_type = 5'd0; 
		end

		S_DONE_DRAW_INITIAL: initial_module_done = 1'b1;
		 

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
	 
	 
	 
	 
	 always@(posedge clk)
    begin
        if(load_xy) begin
        x_initial <= x_random;
		  y_initial <= y_random;
		  end
	 end
	
endmodule

