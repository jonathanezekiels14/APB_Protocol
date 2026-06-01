module slave_apb(
	input PWRITE,PSEL1,PENABLE,PCLK,PRESETn,
	input [7:0] paddr,pwdata,
	output reg PREADY,
	output reg [7:0] prdata
);

	reg [7:0] memory [0:255];

	localparam IDLE = 0, SETUP = 1, ACCESS = 2;
	reg [1:0] curr_state, next_state;
	
	always @(posedge PCLK or negedge PRESETn) begin
		if (!PRESETn) 
			curr_state <= IDLE;
		else
			curr_state <= next_state;
	end
	
	always @(*) begin
		next_state = IDLE;
		case (curr_state)
			IDLE: next_state = PSEL1 ? SETUP : IDLE;
			SETUP: next_state = ACCESS;
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

	always @(*) begin
		case(curr_state)
			IDLE: PREADY = 0;
			SETUP: PREADY = 0;
			ACCESS: PREADY = 1;
			default: PREADY = 0;
		endcase
	end


	always @(posedge PCLK) begin
		if( curr_state == ACCESS) begin
			if (PWRITE)
				memory[paddr] <= pwdata;
			else
				prdata <= memory[paddr];
		end
	end

endmodule
