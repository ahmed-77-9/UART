//////////////////////////////////////////////////////////
////////////////oversampling by 8, 16, 32////////////////
//////////////////////////////////////////////////////// 

module edge_bit_counter (
	input              enable,
	input        [5:0] Prescale,
	input              PAR_EN,
	input              CLK,RST,
	output  reg  [3:0] bit_cnt,
	output  reg  [5:0] edge_cnt
);

wire [3:0] bit_cnt_max = PAR_EN ? 4'd10 : 4'd9;

always @(posedge CLK or negedge RST)
	begin
		if(!RST)
			begin
				bit_cnt      <= 'd0;
				edge_cnt     <= 'd0;
			end
		else if(enable)
			begin
				if(edge_cnt == Prescale-1)
					begin
						edge_cnt <= 6'd0;
						if(bit_cnt == bit_cnt_max)
							begin
								bit_cnt <= 4'd0;
							end
						else
							begin
								bit_cnt <= bit_cnt + 1'b1;
							end
					end
				else
					begin
						edge_cnt <= edge_cnt + 1'b1;
					end
			end
		else
			begin
				bit_cnt  <= 'd0;
				edge_cnt <= 'd0;
			end
	end

endmodule