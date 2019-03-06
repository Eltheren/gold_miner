module counterDown(input enable, 
	    input clk,
	    input resetn,
	    output reg [3:0] tenth,
	    output reg [3:0] oneth,
	    output reg time_done
	    );

wire one_second;

always @(posedge clk) begin
    if (!resetn) begin
	oneth <= 4'd5;
	tenth <= 4'd4;
	time_done <= 1'b0;
    end

    else if (enable) begin
	 
	 if (time_done == 1'b1) begin
		time_done <= 1'b1;
		oneth <= 4'd5;
	   tenth <= 4'd4;
	 end
	 
    else if(one_second) begin
	   if (oneth == 4'b0 && tenth == 4'b0) begin
	     time_done <= 1'b1;
	     oneth <= 4'd5;
	     tenth <= 4'd4;
	   end
	   else if (oneth == 4'b0) begin
	     tenth <= tenth - 1'b1;
 	     oneth <= 4'd9;
		  time_done <= 1'b0;
	   end
	   else begin
	     tenth <= tenth;
	     oneth <= oneth - 1'b1;
		  time_done <= 1'b0;
	   end
	end
    end
    else begin
	oneth <= 4'd5;
	tenth <= 4'd4;
	time_done <= 1'b0;
    end

end

RateDivider r1(clk, one_second, enable);

endmodule

// select which speed 
module RateDivider (clock, Enable_one_sec, enable);
	input enable;
	input clock;
	output Enable_one_sec;
   reg [27:0] Q = 26'b10111110101111000001111111;

	
	counterUP c0(Q, clock, Enable_one_sec, enable);

endmodule


module counterUP(Q, clock, Enable_one_sec, enable);
		input enable;
		input clock;
		output reg Enable_one_sec;
		input [27:0] Q;
		reg [27:0] counter = 0;
		
		always @(posedge clock) begin
		if (enable) begin
			if (counter == Q) begin
				counter <= 0;
				Enable_one_sec <= 1;
			end
			else begin
				counter <= counter + 1'b1;
				Enable_one_sec <= 0;
			end
		end

		else begin
			counter <= 0;
		end
		end
		

endmodule


