module UART_Tx #(parameter Parallel_Input_Width=8) (
	input  [Parallel_Input_Width-1:0]  P_DATA,
	input                              DATA_VALID,
	input                              PAR_EN,
	input                              PAR_TYP,
	input                              CLK,RST,
	output                             TX_OUT,
	output                             Busy
);

wire       ser_en;
wire       ser_done;
wire       par_bit;
wire       ser_data;
wire [2:0] mux_sel;

Serializer  #(.Parallel_Input_Width(Parallel_Input_Width)) Serializer_0 (
	.Parallel_Input (P_DATA),
	.ser_en         (ser_en),
    .CLK            (CLK),
    .RST            (RST),
    .ser_done       (ser_done),
    .Serial_Output  (ser_data)
);

Parity_Calc  #(.Parallel_Input_Width(Parallel_Input_Width)) Parity_Calc_0 (
    .Input_Data (P_DATA),
    .Data_Valid (DATA_VALID && !Busy),
    .PAR_TYP    (PAR_TYP),
    .CLK        (CLK),
    .RST        (RST),
    .par_bit    (par_bit)
);

FSM FSM_0 (
    .Data_Valid (DATA_VALID),
    .PAR_EN     (PAR_EN),
    .ser_done   (ser_done),
    .CLK        (CLK),
    .RST        (RST),
    .ser_en     (ser_en),
    .busy       (Busy),
    .mux_sel    (mux_sel)
);

Tx_MUX Tx_MUX_0 (
    .mux_sel (mux_sel),
    .ser_data(ser_data),
    .par_bit (par_bit),
    .TX_OUT  (TX_OUT)
);

endmodule