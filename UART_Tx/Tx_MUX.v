module Tx_MUX (
	input        [2:0] mux_sel,
	input              ser_data,
	input              par_bit,
	output  reg        TX_OUT
);
localparam IDLE_Value = 1;
localparam start_bit = 0;
localparam stop_bit  = 1;

localparam write_IDLE_bit=0 , write_start_bit=1 ,
		   write_serial_data_bit=2, write_parity_bit=3,
		   write_stop_bit=4;

always @(*)
	begin
		case(mux_sel)
		
			write_IDLE_bit:          TX_OUT = IDLE_Value;
			
			write_start_bit:         TX_OUT = start_bit;
			
			write_serial_data_bit:   TX_OUT = ser_data;
			
			write_parity_bit:        TX_OUT = par_bit;
			
			write_stop_bit:          TX_OUT = stop_bit;
			
			default:                 TX_OUT = IDLE_Value;
			
		endcase
	end
	
endmodule	