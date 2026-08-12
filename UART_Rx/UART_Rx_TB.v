`timescale 1ns/1ps

module UART_Rx_TB();

/////////////////////////////////////////////////////////
///////////////////// Parameters ///////////////////////
///////////////////////////////////////////////////////

////////real -> Floating-point values (decimals) that//////////
////////////////change dynamically during simulation//////////

///////Default for 8x oversampling (115.2 kHz * 8)///////
real CLK_Period = 1085.069; 

/////////////////////////////////////////////////////////
//////////////////// DUT Signals ///////////////////////
///////////////////////////////////////////////////////
reg        RX_IN_TB;
reg  [5:0] Prescale_TB;
reg        PAR_EN_TB;
reg        PAR_TYP_TB;
reg        CLK_TB,RST_TB;
wire       data_valid_TB;
wire [7:0] P_DATA_TB;

////////////////////////////////////////////////////////
////////////////// initial block /////////////////////// 
////////////////////////////////////////////////////////
initial
	begin
		$dumpfile("UART_Rx.vcd");
		$dumpvars;
		CLK_TB     = 1'b0;
		RST_TB     = 1'b0;
		RX_IN_TB   = 1'b1;
		PAR_EN_TB  = 1'b0;
		PAR_TYP_TB = 1'b0;
	
		$display("\n---RST_Test_Case---");
		#(CLK_Period/2)
		if(P_DATA_TB == 'd0 && data_valid_TB == 1'b0)
			begin
				$display("\nRST_Test_passed");
			end
		else
			begin
				$display("\n---RST_Test_failed---");
			end
		
		#(CLK_Period/2)
		@(posedge CLK_TB)
		RST_TB     = 1'b1;
		
		///////////////////////////////////////////////////
		////////////// CASE 1: 8 Oversampling /////////////
		///////////////////////////////////////////////////
		Prescale_TB = 6'd8;
		CLK_Period  = 1085.069;
		$display("\n--- TESTING PRESCALE = 8 ---");
		
		// 1.1: Even Parity Test
		PAR_EN_TB  = 1'b1;
		PAR_TYP_TB = 1'b0;
		$display("[TEST 1.1] Even Parity: 8'b10101101");
		send_frame(8'b10101101, PAR_EN_TB, PAR_TYP_TB);

		// 1.2: Odd Parity Test
		PAR_EN_TB  = 1'b1;
		PAR_TYP_TB = 1'b1;
		$display("[TEST 1.2] Odd Parity: 8'b01100100");
		send_frame(8'b01100100, PAR_EN_TB, PAR_TYP_TB);

		// 1.3: No Parity Test
		PAR_EN_TB  = 1'b0;
		PAR_TYP_TB = 1'b0;
		$display("[TEST 1.3] No Parity: 8'b11001101");
		send_frame(8'b11001101, PAR_EN_TB, PAR_TYP_TB);


		////////////////////////////////////////////////////
		////////////// CASE 2: 16 Oversampling /////////////
		////////////////////////////////////////////////////
		Prescale_TB = 6'd16;
		CLK_Period  = 542.535;
		$display("\n--- TESTING PRESCALE = 16 ---");
		
		// 2.1: Even Parity Test
		PAR_EN_TB  = 1'b1;
		PAR_TYP_TB = 1'b0;
		$display("[TEST 2.1] Even Parity: 8'b11100011");
		send_frame(8'b11100011, PAR_EN_TB, PAR_TYP_TB);

		// 2.2: Odd Parity Test
		PAR_EN_TB  = 1'b1;
		PAR_TYP_TB = 1'b1;
		$display("[TEST 2.2] Odd Parity: 8'b10010110");
		send_frame(8'b10010110, PAR_EN_TB, PAR_TYP_TB);

		// 2.3: No Parity Test
		PAR_EN_TB  = 1'b0;
		PAR_TYP_TB = 1'b0;
		$display("[TEST 2.3] No Parity: 8'b00111100");
		send_frame(8'b00111100, PAR_EN_TB, PAR_TYP_TB);


		////////////////////////////////////////////////////
		////////////// CASE 3: 32 Oversampling /////////////
		////////////////////////////////////////////////////
		Prescale_TB = 6'd32;
		CLK_Period  = 271.267;
		$display("\n--- TESTING PRESCALE = 32 ---");
		
		// 3.1: Even Parity Test
		PAR_EN_TB  = 1'b1;
		PAR_TYP_TB = 1'b0;
		$display("[TEST 3.1] Even Parity: 8'b11001100");
		send_frame(8'b11001100, PAR_EN_TB, PAR_TYP_TB);

		// 3.2: Odd Parity Test
		PAR_EN_TB  = 1'b1;
		PAR_TYP_TB = 1'b1;
		$display("[TEST 3.2] Odd Parity: 8'b10101010");
		send_frame(8'b10101010, PAR_EN_TB, PAR_TYP_TB);

		// 3.3: No Parity Test
		PAR_EN_TB  = 1'b0;
		PAR_TYP_TB = 1'b0;
		$display("[TEST 3.3] No Parity: 8'b01010101");
		send_frame(8'b01010101, PAR_EN_TB, PAR_TYP_TB);
		
		#300 $stop;
	end
	
 always @(posedge data_valid_TB) 
	begin
	$display("SUCCESS: data_valid asserted! P_DATA = 0x%h (0b%b)", P_DATA_TB, P_DATA_TB);
	end	

////////////////////////////////////////////////////////
/////////////////////// TASKS //////////////////////////
////////////////////////////////////////////////////////

////////Task to drive a single bit held for Prescale_TB clock cycles////////
task send_single_bit(
	input bit_value
);
	begin
		RX_IN_TB = bit_value;
		repeat (Prescale_TB) @(posedge CLK_TB);
	end	
endtask

////////Task to transmit a full UART frame////////
task send_frame(
	input [7:0] data_in,
	input       par_en,
	input       par_type
);
	reg parity_bit;
	integer i;
	
	begin
		///////calc parity bit///////
		parity_bit = (par_type == 0) ? ^data_in : ~^data_in;
		
		///////1- sending start bit///////
		send_single_bit(1'b0);
		
		///////2- sending data bits from the LSB to MSB///////
		for(i=0 ; i<8 ; i=i+1)
			begin
				send_single_bit(data_in[i]);
			end
		
		///////3- sending parity bit///////
		if(par_en)
			begin
				send_single_bit(parity_bit);
			end
		
		///////4- sending stop bit///////
		send_single_bit(1'b1);	
		
		@(posedge data_valid_TB);
		if (P_DATA_TB == data_in) begin
			$display("[PASSED] Expected: 0x%h (0b%b) | Received: 0x%h (0b%b)", data_in, data_in, P_DATA_TB, P_DATA_TB);
		end else begin
			$display("[FAILED] Expected: 0x%h (0b%b) | Received: 0x%h (0b%b) | data_valid = %b", data_in, data_in, P_DATA_TB, P_DATA_TB, data_valid_TB);
		end
	end
endtask


/////////////////////////////////////////////////////////
////////////////// Clock Generator  ////////////////////
///////////////////////////////////////////////////////
always #(CLK_Period/2.0) CLK_TB = ~CLK_TB;

////////////////////////////////////////////////////////
////////////////// Design Instaniation  ///////////////
//////////////////////////////////////////////////////
UART_Rx DUT (
    .RX_IN      (RX_IN_TB),
    .Prescale   (Prescale_TB),
    .PAR_EN     (PAR_EN_TB),
    .PAR_TYP    (PAR_TYP_TB),
    .CLK        (CLK_TB),
    .RST        (RST_TB),
    .data_valid (data_valid_TB),
    .P_DATA     (P_DATA_TB)
);

endmodule