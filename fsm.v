


module FSM(		    input wire clk,start_cam
					input wire take_pic,frame_complete,
					input wire [7:0] buff_out_data,
					output reg load_buffer,start_uart,
					input wire req_next_byte,
					output reg [7:0] uart_in_data,//
					output reg uart_reset,
					output reg [15:0] buff_read_addr,
					
					output reg [1:0] state,
					input wire done_rom,
					output reg load_rom

		  	);



parameter BUTTON = 2'b00,
		  BUFFER = 2'b01,
			UART = 2'b10,
			ROM = 2'b11;

assign read_buff_complete = (buff_read_addr == 38401) ? 1'b1: 1'b0;



always @(posedge clk)
begin
	uart_reset <= 1'b0;

    if(start_cam)
    begin   
        state <= ROM;
        load_rom <= 1'b1;
    end

    else
	begin
	case(state)

		ROM:	begin
					load_rom <= 1'b0;
					if(done_rom)
					begin
						
						state <= BUTTON;
					end
				end

		BUTTON:	begin
						if(take_pic)
						begin
							uart_reset <= 1'b1;
							buff_read_addr <= 16'd1;
							state <= BUFFER;
						end
					end

		BUFFER:	begin
						if(frame_complete)
						begin
							load_buffer <= 1'b0;
							state <= UART;
						end
						else
							load_buffer <= 1'b1;
					end


		UART:		begin
						start_uart <= 1'b1;
						if(read_buff_complete)
						begin
							start_uart <= 1'b0;
							state <= BUTTON;	
						end
						else		
						begin
							uart_in_data <= buff_out_data;	
														
							if(req_next_byte)
								buff_read_addr <= buff_read_addr + 1'b1;
						end

					end

	endcase
	end
end

							


endmodule

