`timescale 1ns/1ps

module UART_Tx_TB ();

/////////////////////////////////////////////////////////
///////////////////// Parameters ////////////////////////
/////////////////////////////////////////////////////////

parameter Parallel_Input_Width = 8;
parameter Clock_PERIOD         = 5;
parameter Test_Cases           = 10;


/////////////////////////////////////////////////////////
//////////////////// DUT Signals ////////////////////////
/////////////////////////////////////////////////////////

reg  [Parallel_Input_Width-1:0]  P_DATA_TB;
reg                              DATA_VALID_TB;
reg                              PAR_EN_TB;
reg                              PAR_TYP_TB;
reg                              CLK_TB,RST_TB;
wire                             TX_OUT_TB;
wire                             Busy_TB;


/////////////////////////////////////////////////////////
///////////////// Loops Variables ///////////////////////
/////////////////////////////////////////////////////////
integer                       TEST_NUM ;


/////////////////////////////////////////////////////////
/////////////////////// Memories ////////////////////////
/////////////////////////////////////////////////////////

reg [Parallel_Input_Width-1:0] Parallel_DATA_IN [Test_Cases-1:0];
reg [Parallel_Input_Width+2:0] Expec_Outs       [Test_Cases-1:0];
reg                            Par_Typ          [Test_Cases-1:0];
reg                            Par_En           [Test_Cases-1:0];	
	
////////////////////////////////////////////////////////
////////////////// initial block /////////////////////// 
////////////////////////////////////////////////////////	
initial 
	begin
		 // System Functions
		 $dumpfile("UART_Tx.vcd") ;       
		 $dumpvars;
		 
		 // Read Input Files
		 $readmemb("Parallel_Data_b.txt", Parallel_DATA_IN);
		 $readmemb("Expec_Out_b.txt", Expec_Outs);
		 $readmemb("PAR_TYP.txt" , Par_Typ);
		 $readmemb("PAR_EN.txt" , Par_En);
		 
		  // initialization
         initialization() ;
		 
		 //Reset
		 reset();
		 
		 for(TEST_NUM = 0 ; TEST_NUM < Test_Cases ; TEST_NUM = TEST_NUM + 1)
			begin
				parallel_data_load(Parallel_DATA_IN[TEST_NUM] , Par_Typ[TEST_NUM] , Par_En[TEST_NUM]);
				Check_UART_Tx_Out(Expec_Outs[TEST_NUM] , Par_En[TEST_NUM]);
			end
		
		 #100  $stop ;	
	end


////////////////////////////////////////////////////////
/////////////////////// TASKS //////////////////////////
////////////////////////////////////////////////////////

/////////////// Signals Initialization //////////////////
task initialization;
	begin
		P_DATA_TB     = 8'b00000000;
		CLK_TB        = 1'b0;
		RST_TB        = 1'b0;
		PAR_EN_TB     = 1'b1;
		PAR_TYP_TB    = 1'b0;
		DATA_VALID_TB = 1'b0;
	end
endtask	

///////////////////////// RESET /////////////////////////
task reset;
	begin
		@(posedge CLK_TB)
		RST_TB = 1'b0;
		@(posedge CLK_TB)
		RST_TB = 1'b1;
	end
endtask

////////////////// Do UART_Tx TEST_NUM ////////////////////	
task parallel_data_load;
	input [Parallel_Input_Width-1:0] parallel_Data;
	input                            par_typ;
	input                            par_en; 
	
	begin
		@(posedge CLK_TB)
		P_DATA_TB     = parallel_Data;
		PAR_TYP_TB    = par_typ;
		PAR_EN_TB     = par_en;
	
		DATA_VALID_TB = 1'b1;
		@(posedge CLK_TB)
		DATA_VALID_TB = 1'b0;	
	end
endtask

//////////////////  Check UART_Tx Out  ////////////////////
task Check_UART_Tx_Out;
		input [Parallel_Input_Width+2:0] expected_out;
		input                            par_en;
		
		reg [Parallel_Input_Width+2:0] captured_out;
		
		integer i;
		integer n;
				
		begin	
			captured_out = 'd0;
			n = par_en ? 11:10;    ////////////////if par_en=1 -> n=11bit or if par_en=0 -> n=10bit////////////////
			
			@(negedge TX_OUT_TB);
			@(posedge CLK_TB)
			
			captured_out[n-1]=TX_OUT_TB;
			
			for(i=n-2 ; i>=0 ; i=i-1)
				begin
					@(posedge CLK_TB)
					captured_out[i] = TX_OUT_TB;
				end
			
			  if (par_en)
				begin
					if (captured_out[10:0] == expected_out[10:0])
						$display("TEST_NUM=%0d PASSED : Expected=%b Got=%b", TEST_NUM, expected_out[10:0], captured_out[10:0]);
					else
						$display("TEST_NUM=%0d FAILED : Expected=%b Got=%b", TEST_NUM, expected_out[10:0], captured_out[10:0]);
				end 
			  else 
				begin
					if (captured_out[9:0] == expected_out[9:0])
						$display("TEST_NUM=%0d PASSED : Expected=%b Got=%b", TEST_NUM, expected_out[9:0], captured_out[9:0]);
					else
						$display("TEST_NUM=%0d FAILED : Expected=%b Got=%b", TEST_NUM, expected_out[9:0], captured_out[9:0]);
				end
		end	
endtask


////////////////////////////////////////////////////////
////////////////// Clock Generator  ////////////////////
////////////////////////////////////////////////////////
always #(Clock_PERIOD/2.0) CLK_TB = ~CLK_TB;


////////////////////////////////////////////////////////
////////////////// Design Instaniation  ////////////////////
////////////////////////////////////////////////////////

UART_Tx #(.Parallel_Input_Width(Parallel_Input_Width)) DUT (
    .P_DATA     (P_DATA_TB),
    .DATA_VALID (DATA_VALID_TB),
    .PAR_EN     (PAR_EN_TB),
    .PAR_TYP    (PAR_TYP_TB),
    .CLK        (CLK_TB),
    .RST        (RST_TB),
    .TX_OUT     (TX_OUT_TB),
    .Busy       (Busy_TB)
);
endmodule