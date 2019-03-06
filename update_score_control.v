
module update_score_control(
		input clk,
    		input resetn,

		input [4:0] type_reached,
		input reset_score,
		output reg [8:0] score_x,
		output reg [7:0] score_y,
		output reg [4:0] score_number_type,
		output reg [4:0] first,
		output reg [4:0] second,
		output reg [4:0] third,
		input start_update_score,
		input draw_object_done,
		output reg update_score_done,
		output reg start_draw_score
		);

    reg [4:0] current_state, next_state; 


    reg update;


    localparam  		
		S_WAIT_FOR_COMMAND		= 5'd1,
		S_UPDATE_SCORE			= 5'd2,
		S_WAIT_DRAW_FIRST		= 5'd3,
		S_DRAW_FIRST			= 5'd4,
		S_WAIT_DRAW_SECOND		= 5'd5,
		S_DRAW_SECOND_WAIT	= 5'd6,
		S_DRAW_SECOND			= 5'd7,
		S_WAIT_DRAW_THIRD	= 5'd8,
		S_DRAW_THIRD			= 5'd9,
		S_DONE_UPDATE_SCORE		= 5'd10;


    // Next state logic aka our state table
    always@(*)
    begin: state_table 
           case (current_state)
      		S_WAIT_FOR_COMMAND: next_state = start_update_score? S_UPDATE_SCORE: S_WAIT_FOR_COMMAND;
		S_UPDATE_SCORE: next_state = S_WAIT_DRAW_FIRST;
		S_WAIT_DRAW_FIRST: next_state = (first == 5'd0)?  S_WAIT_DRAW_SECOND: S_DRAW_FIRST;
		S_DRAW_FIRST: next_state = draw_object_done? S_DRAW_SECOND_WAIT : S_DRAW_FIRST;
		S_WAIT_DRAW_SECOND: next_state = (second == 5'd0)? S_WAIT_DRAW_THIRD: S_DRAW_SECOND;
		S_DRAW_SECOND_WAIT: next_state = S_DRAW_SECOND;
		S_DRAW_SECOND: next_state = draw_object_done? S_WAIT_DRAW_THIRD : S_DRAW_SECOND;
		S_WAIT_DRAW_THIRD: next_state = S_DRAW_THIRD;
		S_DRAW_THIRD: next_state = draw_object_done? S_DONE_UPDATE_SCORE : S_DRAW_THIRD;
	
		S_DONE_UPDATE_SCORE: next_state = start_update_score? S_DONE_UPDATE_SCORE: S_WAIT_FOR_COMMAND;

            
			default:     next_state = S_WAIT_FOR_COMMAND;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		update = 1'b0;
		update_score_done = 1'b0;
		start_draw_score = 1'b0;
		score_x = 9'b0;
		score_y = 8'b0;
		score_number_type = 5'b0;


      case (current_state)
		
		S_UPDATE_SCORE: update = 1'b1;

		S_DRAW_FIRST: begin
				start_draw_score = 1'b1;
				score_x = 9'd51;
				score_y = 8'd9;
				score_number_type = first;
			end
		
		S_DRAW_SECOND: begin
				start_draw_score = 1'b1;
				score_x = 9'd59;
				score_y = 8'd9;
				score_number_type = second;
			end
		
		S_DRAW_THIRD: begin
				start_draw_score = 1'b1;
				score_x = 9'd67;
				score_y = 8'd9;
				score_number_type = third;
			end
		
		S_DONE_UPDATE_SCORE: update_score_done = 1'b1;



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

	if (reset_score) begin
		first <= 5'd0;
		second <= 5'd0;
		third <= 5'd0;
	end
		
        if (update) begin
        	if (type_reached == 5'd11) begin  // large gold, 200 points
			first <= first + 2'd2;
			second <= second;
		end

		if (type_reached == 5'd10) begin  // medium gold, 50 points
			if (second + 3'd5 >= 4'd10) begin
				first <= first + 1'b1;
				second <= second + 3'd5 - 4'd10;
				third <= third;
			end
			else begin
				first <= first;
				second <= second + 3'd5;
				third <= third;
			end	
		end

		if (type_reached == 5'd13) begin  // large rock, 20 points
			if (second + 2'd2 >= 4'd10) begin
				first <= first + 1'b1;
				second <= second + 2'd2 - 4'd10;
				third <= third;
			end
			else begin
				first <= first;
				second <= second + 2'd2;
				third <= third;
			end	
		end
		
		if (type_reached == 5'd14) begin  // medium rock, 10 points
			if (second + 1'b1 >= 4'd10) begin
				first <= first + 1'b1;
				second <= second + 1'b1 - 4'd10;
				third <= third;
			end
			else begin
				first <= first;
				second <= second + 1'b1;
				third <= third;
			end	
		end
	end

    end
	 
endmodule



