module stop_check (
	input        sampled_bit,
	input        stp_chk_en,
	output reg   stp_err
);

localparam stop_value = 1;

always @(*) 
	begin
		if (stp_chk_en) 
			begin
				if (sampled_bit == stop_value)
					stp_err = 1'b0;
				else
					stp_err = 1'b1;
			end 
		else
			begin
				stp_err = 1'b0;
			end
	end

endmodule