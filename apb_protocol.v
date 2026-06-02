module top_apb #(parameter WIDTH = 8) (
	input PCLK,PRESETn,transfer,READ_WRITE,
	input [WIDTH:0] apb_write_paddr,apb_read_paddr,
	input [WIDTH-1:0] apb_write_data,
	output [WIDTH-1:0] apb_read_data_out,
	output apb_error_out // NEW: Tell the outside world an error happened
);

	wire PWRITE,PENABLE;
	wire PSEL_master,PREADY_master,PSLVERR_master; // Added Master Error wire
	wire [WIDTH:0] paddr; 
	wire [WIDTH-1:0] pwdata,prdata_master;
	
	wire PSEL1,PSEL2,PREADY1,PREADY2,PSLVERR1,PSLVERR2; // Added Slave Error wires
	wire [WIDTH-1:0] prdata1,prdata2;

	// Address Decoder
	assign PSEL1 = PSEL_master & ~paddr[8]; 
	assign PSEL2 = PSEL_master & paddr[8];  

	// Multiplexers to route signals back to the master
	assign prdata_master = PSEL1 ? prdata1 : PSEL2 ? prdata2 : {WIDTH{1'b0}};
	assign PREADY_master = PSEL1 ? PREADY1 : PSEL2 ? PREADY2 : 1'b1;
	
	// NEW: Error Multiplexer
	assign PSLVERR_master = PSEL1 ? PSLVERR1 : PSEL2 ? PSLVERR2 : 1'b0;

	// Instantiate the Master
	master_apb #(.WIDTH(WIDTH)) m_inst(.PCLK(PCLK),.PRESETn(PRESETn),.transfer(transfer),.READ_WRITE(READ_WRITE),.apb_write_paddr(apb_write_paddr),.apb_write_data(apb_write_data),.apb_read_paddr(apb_read_paddr),.apb_read_data_out(apb_read_data_out),.PWRITE(PWRITE),.PREADY(PREADY_master),.PSLVERR(PSLVERR_master),.PSEL1(PSEL_master),.PENABLE(PENABLE),.paddr(paddr),.pwdata(pwdata),.prdata(prdata_master),.apb_error(apb_error_out));

	// Instantiate Slave 1 
	slave_apb #(.WIDTH(WIDTH)) s_inst_1(.PCLK(PCLK),.PRESETn(PRESETn),.PWRITE(PWRITE),.PREADY(PREADY1),.PSLVERR(PSLVERR1),.PSEL1(PSEL1),.PENABLE(PENABLE),.paddr(paddr[7:0]),.pwdata(pwdata),.prdata(prdata1));

	// Instantiate Slave 2 
	slave_apb #(.WIDTH(WIDTH)) s_inst_2(.PCLK(PCLK),.PRESETn(PRESETn),.PWRITE(PWRITE),.PREADY(PREADY2),.PSLVERR(PSLVERR2),.PSEL1(PSEL2),.PENABLE(PENABLE),.paddr(paddr[7:0]),.pwdata(pwdata),.prdata(prdata2));

endmodule
