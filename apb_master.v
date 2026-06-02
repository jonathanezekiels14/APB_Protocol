module master_apb #(parameter WIDTH = 8) (
	input PCLK,PRESETn,transfer,READ_WRITE,PREADY,
	input [WIDTH:0] apb_write_paddr, apb_read_paddr,
	input [WIDTH-1:0] apb_write_data,prdata,

	output reg PWRITE,PSEL1,PENABLE,
	output reg [WIDTH-1:0] apb_read_data_out,paddr,pwdata
);

	localparam IDLE = 0;
	localparam SETUP = 1;
	localparam ACCESS = 2;
	reg [1:0] curr_state,next_state;

	always @(posedge PCLK or negedge PRESETn) begin
		if(!PRESETn)
			curr_state <= IDLE;
		else
			curr_state <= next_state;
	end

	always @ (*) begin
		next_state = curr_state;
		case (curr_state)
			IDLE: next_state = transfer ? SETUP : IDLE;
			SETUP: next_state = ACCESS;
			ACCESS: next_state = PREADY ? (transfer ? SETUP : IDLE) : ACCESS;
		endcase
	end
	
	always @(*) begin
		PSEL1 = 0;
		PWRITE = 0;
		PENABLE = 0;
		paddr = 0;
		pwdata = 0;
		
		case (curr_state)
			IDLE: begin
				PSEL1 = 0;
				PENABLE = 0;
			end
			SETUP: begin
				PSEL1 = 1;
				PENABLE = 0;
				PWRITE = READ_WRITE;
				paddr = READ_WRITE ? apb_write_paddr : apb_read_paddr;
				pwdata = apb_write_data;
			end
			ACCESS: begin
				PSEL1 = 1;
				PENABLE = 1;
				PWRITE = READ_WRITE;
				paddr = READ_WRITE ? apb_write_paddr : apb_read_paddr;
				pwdata = apb_write_data;
			end
		endcase
	end

	always @(posedge PCLK or negedge PRESETn) begin
		if (!PRESETn) begin
			apb_read_data_out <= 0;
		end
		else
			apb_read_data_out <= prdata;
	end
endmodule
