module master_apb #(parameter WIDTH = 8) (
	input PCLK,PRESETn,transfer,READ_WRITE,PREADY,PSLVERR,
	input [WIDTH:0] apb_write_paddr, apb_read_paddr,
	input [WIDTH-1:0] apb_write_data,prdata,

	output reg PWRITE,PSEL1,PENABLE,apb_error,
	output reg [WIDTH-1:0] apb_read_data_out,pwdata,
	output reg [WIDTH:0] paddr // 9-bit address output
);
	// State machine states
	localparam IDLE = 0;
	localparam SETUP = 1;
	localparam ACCESS = 2;
	
	reg [1:0] curr_state,next_state;

	// Move to the next state on the clock edge
	always @(posedge PCLK or negedge PRESETn) begin
		if(!PRESETn)
			curr_state <= IDLE;
		else
			curr_state <= next_state;
	end

	// Decide what the next state should be
	always @ (*) begin
		next_state = curr_state;
		case (curr_state)
			IDLE: next_state = transfer ? SETUP : IDLE; // Wait for transfer signal
			SETUP: next_state = ACCESS;                 // Always go to ACCESS next
			ACCESS: next_state = PREADY ? (transfer ? SETUP : IDLE) : ACCESS; // Wait for slave to be ready
		endcase
	end
	
	// Set the output signals based on the current state
	always @(*) begin
		// Default values
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
				PSEL1 = 1;            // Assert Select
				PENABLE = 0;          // Enable stays low in setup
				PWRITE = READ_WRITE;
				paddr = READ_WRITE ? apb_write_paddr : apb_read_paddr;
				pwdata = apb_write_data;
			end
			ACCESS: begin
				PSEL1 = 1;            // Keep Select high
				PENABLE = 1;          // Assert Enable
				PWRITE = READ_WRITE;
				paddr = READ_WRITE ? apb_write_paddr : apb_read_paddr;
				pwdata = apb_write_data;
			end
		endcase
	end

	// Save the read data from the slave into an output register
	always @(posedge PCLK or negedge PRESETn) begin
		if (!PRESETn) begin
			apb_error <= 0;
			apb_read_data_out <= 0;
		end
		else begin
			apb_error <= PSLVERR;
			apb_read_data_out <= prdata;
		end
	end
endmodule
