module Rx_FSM (
	input              RX_IN,
	input        [5:0] Prescale,
	input        [5:0] edge_cnt,
	input        [3:0] bit_cnt,
	input              PAR_EN,
	input              par_err,
	input              strt_glitch,
	input              stp_err,
	input              CLK,RST,
	output  reg        enable,
	output  reg        dat_samp_en,
	output  reg        par_chk_en,
	output  reg        strt_chk_en,
	output  reg        stp_chk_en,
	output  reg        deser_en,
	output  reg        data_valid
);

reg [2:0] present_state;
reg [2:0] next_state;

localparam IDLE_state      = 0 , strt_check_state     = 1,
		   data_bits_state = 2 ,  parity_Check_state  = 3,
		   stp_check_state = 4 , data_valid_bit_state = 5;

always @(posedge CLK or negedge RST)
	begin
		if(!RST)
			begin
				present_state <= IDLE_state;
			end
		else
			begin
				present_state <= next_state;
			end
	end

always @(*)
	begin
		enable      = 1'b0;
		dat_samp_en = 1'b0;
		strt_chk_en = 1'b0;
		par_chk_en  = 1'b0;
		stp_chk_en  = 1'b0;
		deser_en    = 1'b0;
		data_valid  = 1'b0;
		
		case(present_state)
		
			IDLE_state: 
						begin
							if(RX_IN == 1'b0)
								begin
									next_state = strt_check_state;
								end
							else
								begin
									next_state = IDLE_state;
								end
						end
						
			strt_check_state: 
								begin
									enable      = 1'b1;
									dat_samp_en = 1'b1;
									strt_chk_en = 1'b1;
									
									if(edge_cnt == Prescale - 1)
										begin
											if(strt_glitch == 1'b1)
												begin
													next_state = IDLE_state;
												end
											else
												begin
													next_state = data_bits_state;
												end	
										end
									else
										begin
											next_state = strt_check_state;
										end
								end
								
			data_bits_state:
								begin
									enable      = 1'b1;
									dat_samp_en = 1'b1;
									
									if(edge_cnt == Prescale - 1)
										begin
											deser_en    = 1'b1;
											if(bit_cnt == 'd8)
												begin
													if(PAR_EN == 1'b1)
														begin
															next_state = parity_Check_state;
														end
													else
														begin
															next_state = stp_check_state;
														end
												end
											else
												begin
													next_state = data_bits_state;
												end
										end
									else
										begin
											deser_en    = 1'b0;
											next_state = data_bits_state;
										end	
								end
								
			parity_Check_state:
								begin
									enable      = 1'b1;
									dat_samp_en = 1'b1;
									par_chk_en  = 1'b1;
									
									if(edge_cnt == Prescale - 1)
										begin
											if(par_err == 1'b1)
												begin
													next_state = IDLE_state;
												end
											else
												begin
													next_state = stp_check_state;
												end	
										end
									else
										begin
											next_state = parity_Check_state;
										end
								end
								
			stp_check_state:
								begin
									enable      = 1'b1;
									dat_samp_en = 1'b1;
									stp_chk_en  = 1'b1;
									
									if(edge_cnt == Prescale - 1)
										begin
											if(stp_err == 1'b1)
												begin
													next_state = IDLE_state;
												end
											else
												begin
													next_state = data_valid_bit_state;
												end
										end
									else
										begin
											next_state = stp_check_state;
										end
								end
								
			data_valid_bit_state:
									begin
										enable      = 1'b0;
										data_valid  = 1'b1;
										if (RX_IN == 1'b0)
											begin
												next_state = strt_check_state;
											end 
										else
											begin
												next_state = IDLE_state;
											end
									end
									
			default: next_state = IDLE_state;						
		endcase
	end

endmodule