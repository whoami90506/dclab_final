module DE2_115(
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	// inout AUD_DACLRCK,
	input AUD_DACLRCK,
	output AUD_XCK,
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
);
/******************
    User Input
******************/
logic RST_N;
logic p1_up, p1_down, p1_left, p1_right, p1_fire;
logic p2_up, p2_down, p2_left, p2_right, p2_fire;
logic [4:0] p1_led, p2_led;

assign RST_N = KEY[0];

assign p1_up    = GPIO[1];
assign p1_down  = GPIO[3];
assign p1_left  = GPIO[5];
assign p1_right = GPIO[7];
assign p1_fire  = GPIO[9];
assign p1_led   = LEDG[4:0];

assign p2_up    = GPIO[27];
assign p2_down  = GPIO[29];
assign p2_left  = GPIO[31];
assign p2_right = GPIO[33];
assign p2_fire  = GPIO[35];
assign p2_led   = LEDR[4:0];

/******************
       Clock
******************/
logic CLOCK_25;
pll pll(.clk_clk(CLOCK_50), .reset_reset_n(RST_N), .altpll_0_c0_clk(CLOCK_25));

/******************
       Module
******************/

//top
logic [1:0] state;

//VGA
logic VGA_buzy;

//timer
logic [2:0] min_ten, sec_ten;
logic [3:0] min_one, sec_one;

Debounce debounce0(.i_in(KEY[1]), .i_clk(CLOCK_50), .i_rst(RST_N), .o_debounced(state[0]));
Debounce debounce1(.i_in(KEY[2]), .i_clk(CLOCK_50), .i_rst(RST_N), .o_debounced(state[1]));

VGA vga(.clk(CLOCK_25), .rst_n(RST_N), .VGA_B(VGA_B), .VGA_BLANK_N(VGA_BLANK_N), .VGA_CLK(VGA_CLK), .VGA_G(VGA_G), 
	.VGA_HS(VGA_HS), .VGA_R(VGA_R), .VGA_SYNC_N(VGA_SYNC_N), .VGA_VS(VGA_VS), .i_state({~state[1], state[0]}), .i_tank0_x(6'd2), 
	.i_tank0_y(6'd2), .i_tank0_dir(SW[1:0]), .o_buzy(VGA_buzy), .i_min_ten(min_ten), .i_min_one(min_one), 
	.i_sec_ten(sec_ten), .i_sec_one(sec_one), .i_tank1_x(6'd32), .i_tank1_y(6'd22), .i_tank1_dir(SW[3:2]));

timer t(.clk(CLOCK_25), .rst_n(RST_N), .i_top_state({~state[1], state[0]}), .i_VGA_buzy(VGA_buzy), .o_min_ten(min_ten), .o_min_one(min_one), 
	.o_sec_ten(sec_ten), .o_sec_one(sec_one));


Joystick p1(.clk(CLOCK_50), .rst_n(RST_N), .i_up(p1_up), .i_down (p1_down), .i_left (p1_left), .i_right(p1_right), 
	.i_fire (p1_fire), .o_led  (p1_led));
Joystick p2(.clk(CLOCK_50), .rst_n(RST_N), .i_up(p2_up), .i_down (p2_down), .i_left (p2_left), .i_right(p2_right), 
	.i_fire (p2_fire), .o_led  (p2_led));


endmodule
