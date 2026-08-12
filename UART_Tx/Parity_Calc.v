module Parity_Calc #(parameter Parallel_Input_Width = 8) (
	input       [Parallel_Input_Width-1:0] Input_Data,
	input                                  Data_Valid,
	input                                  PAR_TYP,
	input                                  CLK,RST,
	output  reg                            par_bit
);

localparam Even_Parity = 0;
localparam Odd_Parity  = 1;

always @(posedge CLK or negedge RST)
	begin
		if(!RST)
			begin
				par_bit <= 0;
			end
		else if(Data_Valid)
			begin
				if(PAR_TYP == Even_Parity)
					/////////////////////////////////////////////////////////////////////
					////////////////par_bit = 1 -> if no. of 1's are odd////////////////
					///////////////////////////////////////////////////////////////////
					begin
						par_bit <= ^Input_Data;
					end
				else if(PAR_TYP == Odd_Parity)
					/////////////////////////////////////////////////////////////////////
					////////////////par_bit = 1 -> if no. of 1's are even///////////////
					///////////////////////////////////////////////////////////////////
					begin
						par_bit <= ~(^Input_Data);
					end	
			end
	end

endmodule