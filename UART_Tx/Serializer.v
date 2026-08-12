module Serializer #(parameter Parallel_Input_Width = 8) (
	input       [Parallel_Input_Width-1:0] Parallel_Input,
	input                                  ser_en,
	input                                  CLK,RST,
	output  reg                            ser_done,
	output  reg                            Serial_Output
);

reg  [Parallel_Input_Width-1 : 0] Parallel_Input_Reg;
reg  [$clog2(Parallel_Input_Width)-1:0] counter;

always @(posedge CLK or negedge RST)
	begin 
		if(!RST)
			begin
				Serial_Output <= 1'b0;
				ser_done      <= 1'b0;
				counter       <= 'd0;
				Parallel_Input_Reg <= 'd0;
			end
		else if(ser_en)
			begin
				if (counter == 'd0)
					begin
						Serial_Output      <= Parallel_Input[0];
						Parallel_Input_Reg <= Parallel_Input >> 1;
						counter <= counter +1;
					end
				else if (counter < 'd7)
					begin
						Serial_Output <= Parallel_Input_Reg[0];
						Parallel_Input_Reg <= Parallel_Input_Reg >>1;
						counter <= counter +1;
						ser_done <= 1'b0;
					end
				else if (counter == 'd7)
					begin
						Serial_Output <= Parallel_Input_Reg[0];
						ser_done <= 1'b1;
						counter  <= 'd0;
					end
			end
		else
			begin
				Serial_Output <= 1'b0;
				ser_done      <= 1'b0;
			end	
	end
	
endmodule	 