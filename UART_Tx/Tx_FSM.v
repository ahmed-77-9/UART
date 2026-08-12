module FSM (
	input               Data_Valid,
	input               PAR_EN,
	input               ser_done,
	input               CLK,RST,
	output  reg         ser_en,
	output  reg         busy,
	output  reg  [2:0]  mux_sel
);
reg [2:0] next_state,current_state;

localparam IDLE = 0, Start_Serializing_State = 1, DATA_Serializing_State = 2,
		   Parity_State = 3 , End_Serializing_State = 4;


always @(posedge CLK or negedge RST)
	begin
		if(!RST)
			begin
				current_state <= IDLE;
			end
		else
			begin
				current_state <= next_state;
			end
	end
	
always @(*)
		begin
			ser_en  = 1'b0;
			busy    = 1'b0;
			mux_sel = 'd0 ; //////////// write_IDLE_bit ////////////
			
			case(current_state)
			
				IDLE: if(Data_Valid)
						begin
							next_state = Start_Serializing_State;
							mux_sel =  'd1; //////////// write_start_bit ////////////
							busy    = 1'b1;
						end
					   else
						begin
							next_state = IDLE;
							mux_sel = 'd0; //////////// write_IDLE_bit ////////////
						end
				
				Start_Serializing_State: 
										begin
											next_state = DATA_Serializing_State;
											ser_en  = 1'b1;
											busy    = 1'b1;
											mux_sel =  'd2; //////////// write_serial_data_bit ////////////
										end
											
				DATA_Serializing_State: begin
											ser_en = 1'b1;
											busy   = 1'b1;
											mux_sel = 3'd2; //////////// write_serial_data_bit ////////////

											if (ser_done) 
												begin
													ser_en = 1'b0;
													if (PAR_EN) begin
														next_state = Parity_State;
													end else begin
														next_state = End_Serializing_State;
													end
												end 
											else 
												begin
													next_state = DATA_Serializing_State;
												end
										end
				
				Parity_State:   		begin
											next_state = End_Serializing_State;
											busy    = 1'b1;
											mux_sel =  'd3; //////////// write_parity_bit ////////////
										end
								
				End_Serializing_State: 
										begin
											next_state = IDLE;
											busy    = 1'b1;
											mux_sel =  'd4; //////////// write_stop_bit ////////////
										end
										
				default: next_state = IDLE;
				
			endcase	
		end
		
endmodule

