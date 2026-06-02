module #(parameter WIDTH = 8) top_apb(
	input PCLK,PRESETn,transfer,READ_WRITE,
	input [WIDTH:0] apb_write_paddr,apb_read_paddr,
	input [WIDTH-1:0] apb_write_data,
	output [WIDTH-1:0] apb_read_data_out
);

	wire PREADY,PWRITE,PSEL1,PENABLE;
	wire [WIDTH-1:0] paddr,pwdata,prdata;

	// Master
	master_apb #(.WIDTH(WIDTH)) m_inst(.PCLK(PCLK),.PRESETn(PRESETn),.transfer(transfer),.READ_WRITE(READ_WRITE),.apb_write_paddr(apb_write_paddr),.apb_write_data(apb_write_data),.apb_read_paddr(apb_read_paddr),.apb_read_data_out(apb_read_data_out),.PWRITE(PWRITE),.PREADY(PREADY),.PSEL1(PSEL1),.PENABLE(PENABLE),.paddr(paddr),.pwdata(pwdata),.prdata(prdata));

	// Slave
	slave_apb #(.WIDTH(WIDTH)) s_inst(.PCLK(PCLK),.PRESETn(PRESETn),.PWRITE(PWRITE),.PREADY(PREADY),.PSEL1(PSEL1),.PENABLE(PENABLE),.paddr(paddr),.pwdata(pwdata),.prdata(prdata));

endmodule
