module parity_check (
	input       [7:0] P_DATA,
	input             sampled_bit,
	input             PAR_TYP,
	input             par_chk_en,
	output reg        par_err
);

localparam Even_Parity = 1'b0, 
           Odd_Parity  = 1'b1;

always @(*) begin
	if (par_chk_en) 
		begin
			if (PAR_TYP == Even_Parity) 
				begin
					par_err = (^P_DATA) ^ sampled_bit;
				end 
			else 
				begin
					par_err = ~((^P_DATA) ^ sampled_bit);
				end
		end 
	else 
		begin
			par_err = 1'b0;
		end
end

endmodule