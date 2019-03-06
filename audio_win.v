
module audio_win(
		input clk,
    		input resetn,
		
		output reg enable_audio_success,
		input audio_success_counter_done,
		input start_audio_success,
		output reg audio_success_done,
		output reg [6:0] audio_success
		);

    reg [4:0] current_state, next_state; 


    reg update;


    localparam  		
		S_WAIT_FOR_COMMAND		= 5'd1,
		S_LOAD_AUDIO1			= 5'd2,
		S_WAIT1				= 5'd3,
		S_LOAD_AUDIO2			= 5'd4,
		S_WAIT2   			= 5'd5,
		S_LOAD_AUDIO3			= 5'd6,
		S_WAIT3				= 5'd7,
		S_LOAD_AUDIO4			= 5'd8,
		S_WAIT4				= 5'd9,
		S_LOAD_AUDIO5			= 5'd10,
		S_WAIT5				= 5'd11,
		S_LOAD_AUDIO6			= 5'd12,
		S_WAIT6 			= 5'd13,
		S_LOAD_AUDIO7			= 5'd14,
		S_WAIT7				= 5'd15,
		S_LOAD_AUDIO8			= 5'd16,		
		S_DONE_AUDIO_SUCCESS		= 5'd17;


    // Next state logic aka our state table
    always@(*)
    begin: state_table 
           case (current_state)
      		
		S_WAIT_FOR_COMMAND: next_state = start_audio_success? S_LOAD_AUDIO1: S_WAIT_FOR_COMMAND;
		S_LOAD_AUDIO1: next_state = audio_success_counter_done? S_WAIT1: S_LOAD_AUDIO1;
		S_WAIT1: next_state = S_LOAD_AUDIO2;			
		S_LOAD_AUDIO2: 	next_state = audio_success_counter_done? S_WAIT2: S_LOAD_AUDIO2;		
		S_WAIT2: next_state = S_LOAD_AUDIO3; 		
		S_LOAD_AUDIO3: next_state = audio_success_counter_done? S_WAIT3: S_LOAD_AUDIO3;		
		S_WAIT3: next_state = S_LOAD_AUDIO4;				
		S_LOAD_AUDIO4: next_state = audio_success_counter_done? S_WAIT4: S_LOAD_AUDIO4;			
		S_WAIT4: next_state = S_LOAD_AUDIO5;				
		S_LOAD_AUDIO5: next_state = audio_success_counter_done? S_WAIT5: S_LOAD_AUDIO5;		
		S_WAIT5: next_state = S_LOAD_AUDIO6;				
		S_LOAD_AUDIO6: next_state = audio_success_counter_done? S_WAIT6: S_LOAD_AUDIO6;			
		S_WAIT6: next_state = S_LOAD_AUDIO7; 			
		S_LOAD_AUDIO7: next_state = audio_success_counter_done? S_WAIT7: S_LOAD_AUDIO7;			
		S_WAIT7: next_state = S_LOAD_AUDIO8;				
		S_LOAD_AUDIO8: next_state = audio_success_counter_done? S_DONE_AUDIO_SUCCESS: S_LOAD_AUDIO8;			
	
		S_DONE_AUDIO_SUCCESS: next_state = start_audio_success? S_DONE_AUDIO_SUCCESS: S_WAIT_FOR_COMMAND;

            
			default:     next_state = S_WAIT_FOR_COMMAND;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		
		enable_audio_success = 1'b0;
		audio_success_done = 1'b0;
		audio_success = 7'b0;

      case (current_state)

		S_LOAD_AUDIO1: begin
			enable_audio_success = 1'b1;
			audio_success = 7'b0001000;
		end
		
		S_LOAD_AUDIO2: begin
			enable_audio_success = 1'b1;
			audio_success = 7'b0001010;			
		end		

		S_LOAD_AUDIO3: begin
			enable_audio_success = 1'b1;
			audio_success = 7'b0001000;
		end			

		S_LOAD_AUDIO4: begin
			enable_audio_success = 1'b1;
			audio_success = 7'b0001100;
		end					
	
		S_LOAD_AUDIO5: begin
			enable_audio_success = 1'b1;
			audio_success = 7'b0001000;
		end					
		
		S_LOAD_AUDIO6: begin
			enable_audio_success = 1'b1;
			audio_success = 7'b0001001;
		end					
	
		S_LOAD_AUDIO7: begin
			enable_audio_success = 1'b1;
			audio_success = 7'b0001010;
		end					
	
		S_LOAD_AUDIO8: begin
			enable_audio_success = 1'b1;
			audio_success = 7'b0001100;
		end			
				
		S_DONE_AUDIO_SUCCESS: audio_success_done = 1'b1;	

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
	 
  
	 
endmodule



