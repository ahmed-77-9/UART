module data_sampling (
	input              RX_IN,
	input        [5:0] Prescale,
	input              dat_sample_en,
	input        [5:0] edge_cnt,
	input              CLK,RST,
	output  reg        sampled_bit
);

reg [2:0] data_bit_samples;

always @(posedge CLK or negedge RST)
	begin
		if(!RST)
			begin
				sampled_bit      <= 1'b1;
				data_bit_samples <=  'd0;
			end
		else if(dat_sample_en)
			begin
				if(edge_cnt == (Prescale/2)-1'b1)
					begin
						data_bit_samples[0] <= RX_IN;
					end
				else if(edge_cnt == (Prescale/2))
					begin
						data_bit_samples[1] <= RX_IN;
					end
				else if(edge_cnt == (Prescale/2)+1'b1)
					begin
						data_bit_samples[2] <= RX_IN;
						sampled_bit <= (data_bit_samples[0] & data_bit_samples[1]) | 
                                       (data_bit_samples[0] & RX_IN) |
                                       (data_bit_samples[1] & RX_IN);
					end	
			end
		else
			begin
				sampled_bit      <= 1'b1;
				data_bit_samples <= 3'b111;
			end
	end
endmodule