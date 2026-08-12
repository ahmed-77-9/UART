module deserializer (
	input              sampled_bit,
	input              deser_en,
	input              CLK,RST,
	output  reg  [7:0] P_DATA
);

reg [2:0] counter;
reg [7:0] shift_sampled_data_reg;

always @(posedge CLK or negedge RST)
	begin
		if(!RST)
			begin
				P_DATA <= 'd0;
				counter <= 'd0;
			end
		else if(deser_en)
			begin
				shift_sampled_data_reg[counter] <= sampled_bit;

				if(counter == 'd7)
					begin
						P_DATA  <= {sampled_bit , shift_sampled_data_reg[6:0]};
						counter <= 'd0;
					end
				else
					begin
						counter <= counter + 'd1;	
					end
			end	
	end
endmodule