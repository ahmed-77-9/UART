module strt_check (
	input        strt_chk_en,
	input        sampled_bit,
	output reg   strt_glitch
);

localparam start_value = 0;

always @(*)
	begin
		if (strt_chk_en) 
			begin
				if (sampled_bit == start_value)
					strt_glitch = 1'b0;
				else
					strt_glitch = 1'b1;
			end 
		else 
			begin
				strt_glitch = 1'b0;
			end
	end

endmodule