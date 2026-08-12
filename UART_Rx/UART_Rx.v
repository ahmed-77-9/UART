module UART_Rx (
	input        RX_IN,
	input  [5:0] Prescale,
	input        PAR_EN,
	input        PAR_TYP,
	input        CLK,RST,
	output       data_valid,
	output [7:0] P_DATA
);

wire        par_err;
wire        strt_glitch;
wire        stp_err;
wire        enable;
wire  [5:0] edge_cnt;
wire  [3:0] bit_cnt;         
wire        dat_samp_en;
wire        par_chk_en;
wire        strt_chk_en;
wire        stp_chk_en;
wire        deser_en;
wire        sampled_bit;

Rx_FSM FSM_0(
	.RX_IN       (RX_IN),
	.Prescale    (Prescale),
	.edge_cnt    (edge_cnt),
	.bit_cnt     (bit_cnt),
	.PAR_EN      (PAR_EN),
	.par_err     (par_err),
	.strt_glitch (strt_glitch),
	.stp_err     (stp_err),
	.CLK         (CLK),
	.RST         (RST),
	.enable      (enable),
	.dat_samp_en (dat_samp_en),
	.par_chk_en  (par_chk_en),
	.strt_chk_en (strt_chk_en),
	.stp_chk_en  (stp_chk_en),
	.deser_en    (deser_en),
	.data_valid  (data_valid)
);

edge_bit_counter   edge_counter_0(
	.enable   (enable),
	.Prescale (Prescale),
	.PAR_EN   (PAR_EN),
	.CLK      (CLK),
	.RST      (RST),
	.bit_cnt  (bit_cnt),
	.edge_cnt (edge_cnt)
);

data_sampling   data_sampling_0(
	.RX_IN         (RX_IN),
	.Prescale      (Prescale),
	.dat_sample_en (dat_samp_en),
	.edge_cnt      (edge_cnt),
	.CLK           (CLK),
	.RST           (RST),
	.sampled_bit   (sampled_bit)
);

deserializer deser_0 (
	.sampled_bit (sampled_bit),
	.deser_en    (deser_en),
	.CLK         (CLK),
	.RST         (RST),
	.P_DATA      (P_DATA)
);
	
strt_check strt_chk_0 (
	.sampled_bit (sampled_bit),
	.strt_chk_en (strt_chk_en),
	.strt_glitch (strt_glitch)
);

parity_check par_chk_0 (
	.P_DATA      (P_DATA),
	.sampled_bit (sampled_bit),
	.PAR_TYP     (PAR_TYP),
	.par_chk_en  (par_chk_en),
	.par_err     (par_err)
);

stop_check stp_chk_0 (
	.sampled_bit (sampled_bit),
	.stp_chk_en  (stp_chk_en),
	.stp_err     (stp_err)
    );	

endmodule