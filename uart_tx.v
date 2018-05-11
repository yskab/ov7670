


 module uart_tx(	input wire clk,
					output reg out_tx,
					input wire [7:0]  in_data,
					input wire start_tx,
					input wire reset,
					output reg byte_sent
				);


 parameter IDLE = 2'b00,
		   START = 2'b01,
		   DATA = 2'b10,
		   STOP = 2'b11;

 reg [7:0] data;
 reg [3:0] n_bits;
 reg [1:0] curr_state;
 wire enable;
 reg uart_baud_on;

 BaudTickGen baud(.clk(clk),.tick(enable),.baud_gen_on(uart_baud_on));




 always @(posedge clk)
 begin
	
	if(reset)
	begin
		curr_state <= IDLE;
		
	end
	else
	begin
		case(curr_state)
	
			IDLE:	begin
						out_tx <= 1'b1;
						if(start_tx)
						begin		
							curr_state <= START;
							uart_baud_on <= 1'b1;
							data <= in_data;
							n_bits <= {(4){1'b0}};
						end
						else
							uart_baud_on <= 1'b0;
					end

		START:		begin
				
						out_tx <= 1'b0;
						if(enable)
							curr_state <= DATA;

					end

		DATA:	begin

					if(n_bits < 8)
					begin
						out_tx <= data[0];
						if(enable)
						begin
							n_bits <= n_bits + 1'b1;
							data <= data >> 1;
						end
					end
					else
					begin
						curr_state <= STOP;
						byte_sent <= 1'b1;
					end
				end
		
		STOP:	begin
					byte_sent <= 1'b0;
					out_tx <= 1'b1;
					if(enable)
						curr_state <= IDLE;
				end

	endcase
	end
 end
	
 endmodule
				
				

	
