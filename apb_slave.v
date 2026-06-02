module slave_apb #(parameter WIDTH=8) (
	input PWRITE,PSEL1,PENABLE,PCLK,PRESETn,
	input [WIDTH-1:0] paddr,pwdata,
	output reg PREADY,
	output reg [WIDTH-1:0] prdata
);

	// The actual memory array (256 slots, each 8 bits wide)
	reg [WIDTH-1:0] memory [0:255];
	
	// State machine states
	localparam IDLE = 0, SETUP = 1, ACCESS = 2;
	reg [1:0] curr_state, next_state;

	// Move to the next state on the clock edge
	always @(posedge PCLK or negedge PRESETn) begin
		if (!PRESETn) 
			curr_state <= IDLE;
		else
			curr_state <= next_state;
	end
	
	// Decide what the next state should be based on master signals
	always @(*) begin
		next_state = IDLE;
		case (curr_state)
			IDLE: next_state = PSEL1 ? SETUP : IDLE; // Master asserted select
			SETUP: next_state = ACCESS;              // Automatically move to access
			ACCESS: begin
				if( PSEL1 && !PENABLE)
					next_state = SETUP;
				else if(!PSEL1)
					next_state = IDLE;
				else
					next_state = IDLE;
			end
		endcase
	end

	// Instantly drive PREADY high when in the ACCESS state (Zero-wait-state)
	always @(*) begin
    		if (PSEL1 && PENABLE)
        		PREADY = 1;
    		else
        		PREADY = 0;
	end
	// Handle the actual writing and reading of the memory
	always @(posedge PCLK) begin
		if( curr_state == ACCESS) begin
			if (PWRITE)
				memory[paddr] <= pwdata; // Save data to memory
			else
				prdata <= memory[paddr]; // Send data back to master
		end
	end

endmodule
