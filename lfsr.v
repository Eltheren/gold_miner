
module lfsr(
  input clk,
  input resetn,
  output reg [8:0] x_initial,
  output reg [7:0] y_initial
);

reg [5:0] data = 6'd63;

wire feedback = data[5]^(data[4:0] == 5'b00000);


//always @* begin
//
//	data_next = data;
//	count_next = count;
//	
//	data_next = {data[4:0], feedback}; 
//	count_next = count + 1;
//	
//	if (count == 4'd13) 
//		count = 0;
//
// /* data_next[5] = data[5]^data[4];
//  data_next[4] = data[4]^data[1];
//  data_next[3] = data[3]^data[0];
//  data_next[2] = data[2]^data_next[5];
//  data_next[1] = data[1]^data_next[4];
//  data_next[0] = data[0]^data_next[3]; */
//end



always @(posedge clk or negedge resetn) begin
  if(!resetn) begin
    data <= 6'd63;
	end
	
  else begin
    data[0] <= feedback;
	 data[1] <= data[0] ^ feedback;
	 data[2] <= data[1];
	 data[3] <= data[2];
	 data[4] <= data[3];
	 data[5] <= data[4];
	 end
end

always @(posedge clk) begin
    if (data == 6'd0) begin
	x_initial <= 9'd2;
	y_initial <= 8'd50;
    end

    else if (data == 6'd1) begin
	x_initial <= 9'd44;
	y_initial <= 8'd50;
    end

    else if (data == 6'd2) begin
	x_initial <= 9'd86;
	y_initial <= 8'd50;
    end

    else if (data == 6'd3) begin
	x_initial <= 9'd128;
	y_initial <= 8'd50;
    end

    else if (data == 6'd4) begin
	x_initial <= 9'd170;
	y_initial <= 8'd50;
    end

    else if (data == 6'd5) begin
	x_initial <= 9'd212;
	y_initial <= 8'd50;
    end

    else if (data == 6'd6) begin
	x_initial <= 9'd254;
	y_initial <= 8'd50;
    end

    else if (data == 6'd7) begin
	x_initial <= 9'd296;
	y_initial <= 8'd50;
    end

    else if (data == 6'd8) begin
	x_initial <= 9'd2;
	y_initial <= 8'd74;
    end

    else if (data == 6'd9) begin
	x_initial <= 9'd44;
	y_initial <= 8'd74;
    end

    else if (data == 6'd10) begin
	x_initial <= 9'd86;
	y_initial <= 8'd74;
    end

    else if (data == 6'd11) begin
	x_initial <= 9'd128;
	y_initial <= 8'd74;
    end

    else if (data == 6'd12) begin
	x_initial <= 9'd170;
	y_initial <= 8'd74;
    end

    else if (data == 6'd13) begin
	x_initial <= 9'd212;
	y_initial <= 8'd74;
    end

    else if (data == 6'd14) begin
	x_initial <= 9'd254;
	y_initial <= 8'd74;
    end

    else if (data == 6'd15) begin
	x_initial <= 9'd296;
	y_initial <= 8'd74;
    end

    else if (data == 6'd16) begin
	x_initial <= 9'd2;
	y_initial <= 8'd98;
    end

    else if (data == 6'd17) begin
	x_initial <= 9'd44;
	y_initial <= 8'd98;
    end

    else if (data == 6'd18) begin
	x_initial <= 9'd86;
	y_initial <= 8'd98;
    end

    else if (data == 6'd19) begin
	x_initial <= 9'd128;
	y_initial <= 8'd98;
    end

    else if (data == 6'd20) begin
	x_initial <= 9'd170;
	y_initial <= 8'd98;
    end

    else if (data == 6'd21) begin
	x_initial <= 9'd212;
	y_initial <= 8'd98;
    end

    else if (data == 6'd22) begin
	x_initial <= 9'd254;
	y_initial <= 8'd98;
    end

    else if (data == 6'd23) begin
	x_initial <= 9'd296;
	y_initial <= 8'd98;
    end

    else if (data == 6'd24) begin
	x_initial <= 9'd2;
	y_initial <= 8'd122;
    end

    else if (data == 6'd25) begin
	x_initial <= 9'd44;
	y_initial <= 8'd122;
    end

    else if (data == 6'd26) begin
	x_initial <= 9'd86;
	y_initial <= 8'd122;
    end

    else if (data == 6'd27) begin
	x_initial <= 9'd128;
	y_initial <= 8'd122;
    end

    else if (data == 6'd28) begin
	x_initial <= 9'd170;
	y_initial <= 8'd122;
    end

    else if (data == 6'd29) begin
	x_initial <= 9'd212;
	y_initial <= 8'd122;
    end

    else if (data == 6'd30) begin
	x_initial <= 9'd254;
	y_initial <= 8'd122;
    end

    else if (data == 6'd31) begin
	x_initial <= 9'd296;
	y_initial <= 8'd122;
    end

    else if (data == 6'd32) begin
	x_initial <= 9'd2;
	y_initial <= 8'd146;
    end

    else if (data == 6'd33) begin
	x_initial <= 9'd44;
	y_initial <= 8'd146;
    end

    else if (data == 6'd34) begin
	x_initial <= 9'd86;
	y_initial <= 8'd146;
    end

    else if (data == 6'd35) begin
	x_initial <= 9'd128;
	y_initial <= 8'd146;
    end

    else if (data == 6'd36) begin
	x_initial <= 9'd170;
	y_initial <= 8'd146;
    end

    else if (data == 6'd37) begin
	x_initial <= 9'd212;
	y_initial <= 8'd146;
    end

    else if (data == 6'd38) begin
	x_initial <= 9'd254;
	y_initial <= 8'd146;
    end

    else if (data == 6'd39) begin
	x_initial <= 9'd296;
	y_initial <= 8'd146;
    end

    else if (data == 6'd40) begin
	x_initial <= 9'd2;
	y_initial <= 8'd170;
    end

    else if (data == 6'd41) begin
	x_initial <= 9'd44;
	y_initial <= 8'd170;
    end

    else if (data == 6'd42) begin
	x_initial <= 9'd86;
	y_initial <= 8'd170;
    end

    else if (data == 6'd43) begin
	x_initial <= 9'd128;
	y_initial <= 8'd170;
    end

    else if (data == 6'd44) begin
	x_initial <= 9'd170;
	y_initial <= 8'd170;
    end

    else if (data == 6'd45) begin
	x_initial <= 9'd212;
	y_initial <= 8'd170;
    end

    else if (data == 6'd46) begin
	x_initial <= 9'd254;
	y_initial <= 8'd170;
    end

    else if (data == 6'd47) begin
	x_initial <= 9'd296;
	y_initial <= 8'd170;
    end

    else if (data == 6'd48) begin
	x_initial <= 9'd2;
	y_initial <= 8'd194;
    end

    else if (data == 6'd49) begin
	x_initial <= 9'd44;
	y_initial <= 8'd194;
    end

    else if (data == 6'd50) begin
	x_initial <= 9'd86;
	y_initial <= 8'd194;
    end

    else if (data == 6'd51) begin
	x_initial <= 9'd128;
	y_initial <= 8'd194;
    end

    else if (data == 6'd52) begin
	x_initial <= 9'd170;
	y_initial <= 8'd194;
    end

    else if (data == 6'd53) begin
	x_initial <= 9'd212;
	y_initial <= 8'd194;
    end

    else if (data == 6'd54) begin
	x_initial <= 9'd254;
	y_initial <= 8'd194;
    end

    else if (data == 6'd55) begin
	x_initial <= 9'd296;
	y_initial <= 8'd194;
    end

    else if (data == 6'd56) begin
	x_initial <= 9'd2;
	y_initial <= 8'd218;
    end

    else if (data == 6'd57) begin
	x_initial <= 9'd44;
	y_initial <= 8'd218;
    end

    else if (data == 6'd58) begin
	x_initial <= 9'd86;
	y_initial <= 8'd218;
    end

    else if (data == 6'd59) begin
	x_initial <= 9'd128;
	y_initial <= 8'd218;
    end

    else if (data == 6'd60) begin
	x_initial <= 9'd170;
	y_initial <= 8'd218;
    end

    else if (data == 6'd61) begin
	x_initial <= 9'd212;
	y_initial <= 8'd218;
    end

    else if (data == 6'd62) begin
	x_initial <= 9'd254;
	y_initial <= 8'd218;
    end

    else if (data == 6'd63) begin
	x_initial <= 9'd296;
	y_initial <= 8'd218;
    end

  
 end

endmodule