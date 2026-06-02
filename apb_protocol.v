module top_apb #(parameter WIDTH = 8) (
	input PCLK,PRESETn,transfer,READ_WRITE,
	input [WIDTH:0] apb_write_paddr,apb_read_paddr, // 9-bit address input
	input [WIDTH-1:0] apb_write_data,
	output [WIDTH-1:0] apb_read_data_out
);

	// Wires to connect the Master and Slaves together
	wire PWRITE,PENABLE;
	wire PSEL_master,PREADY_master;
	wire [WIDTH:0] paddr; // 9-bit internal address bus
	wire [WIDTH-1:0] pwdata,prdata_master;
	
	// Wires specific to each Slave
	wire PSEL1,PSEL2,PREADY1,PREADY2;
	wire [WIDTH-1:0] prdata1,prdata2;

	// Address Decoder: Use the 9th bit (bit 8) to choose the slave
	assign PSEL1 = PSEL_master & ~paddr[8]; // Select Slave 1 if bit 8 is 0
	assign PSEL2 = PSEL_master & paddr[8];  // Select Slave 2 if bit 8 is 1

	// Data Multiplexer: Send the chosen slave's data back to the master
	assign prdata_master = PSEL1 ? prdata1 : PSEL2 ? prdata2 : {WIDTH{1'b0}};
	
	// Ready Multiplexer: Send the chosen slave's ready signal back to the master
	assign PREADY_master = PSEL1 ? PREADY1 : PSEL2 ? PREADY2 : 1'b1;

	// Instantiate the Master
	master_apb #(.WIDTH(WIDTH)) m_inst(.PCLK(PCLK),.PRESETn(PRESETn),.transfer(transfer),.READ_WRITE(READ_WRITE),.apb_write_paddr(apb_write_paddr),.apb_write_data(apb_write_data),.apb_read_paddr(apb_read_paddr),.apb_read_data_out(apb_read_data_out),.PWRITE(PWRITE),.PREADY(PREADY_master),.PSEL1(PSEL_master),.PENABLE(PENABLE),.paddr(paddr),.pwdata(pwdata),.prdata(prdata_master));

	// Instantiate Slave 1 (Gets the lower 8 bits of the address)
	slave_apb #(.WIDTH(WIDTH)) s_inst_1(.PCLK(PCLK),.PRESETn(PRESETn),.PWRITE(PWRITE),.PREADY(PREADY1),.PSEL1(PSEL1),.PENABLE(PENABLE),.paddr(paddr[7:0]),.pwdata(pwdata),.prdata(prdata1));

	// Instantiate Slave 2 (Gets the lower 8 bits of the address)
	slave_apb #(.WIDTH(WIDTH)) s_inst_2(.PCLK(PCLK),.PRESETn(PRESETn),.PWRITE(PWRITE),.PREADY(PREADY2),.PSEL1(PSEL2),.PENABLE(PENABLE),.paddr(paddr[7:0]),.pwdata(pwdata),.prdata(prdata2));

endmodule
