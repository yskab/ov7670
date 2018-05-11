
 module top  (   
                 input wire clk,                  //100mhz global system clock
                 input wire vs,hs,               //sync signals
                 input wire pclk,                //pixel clock output
	 		     input wire [7:0] D,              //Data Lines from module
                 input wire clk_12mhz,           //12mhz clock in
		 		 output wire xclk,               //12mhz clock input to module
		 		 output wire out_uart,            //Uart out to PC
                 output wire start_cam,           //switch to initialize camera with reg values
				 input wire switch_pic,          //switch input to capture image
                 output wire sda,scl             //i2c signals
         
             );


  
 assign xclk = clk_12mhz;	
	
 wire [15:0] w_addr,r_addr;
 wire [7:0] outbuff;
 wire [7:0] udata;
 wire [4:0] addr_rom;
 wire [15:0] data_rom;
 
 
 FSM fsm( .clk(clk),
          .take_pic(!switch_pic),
          .frame_complete(frame_cap),
	      .buff_out_data(outbuff),
          .load_buffer(load),
          .start_uart(u_s),
          .uart_reset(ur),
	      .req_next_byte(next),
          .uart_in_data(udata),
          .buff_read_addr(r_addr),
          .load_rom(load_config_rom),
		  .done_rom(done_config_rom),
          .start_cam(start_cam)
	    );

 
 i2c_core i2c( .clk(clk),
               .i2c_reset(load_config_rom),
    		   .val_addr(addr_rom),
               .i2c_in_data(data_rom),
               .sda(sda),
               .scl(scl),
			   .i2c_start_tx(done_config_rom)
             );

 
 ov7670_regs rom( .clk(clk),
                  .addr(addr_rom),
                  .b(data_rom)
                );




 
 uart_tx u_tx( .clk(clk),
              .in_data(udata),
              .start_tx(u_s),
			  .reset(ur),
              .out_tx(out_uart),
              .byte_sent(next)
            
             );

 
 frame_capture capture( .clk(clk),
                        .HS(hs),
                        .VS(vs),
                        .addr(w_addr),
			            .start_capture(load),
                        .pclk(pclk),
                        .write_to_buff(we),
                        .frame_captured(frame_cap)

                      );

 //Xilinx Core Generator Block Ram 
 r ram( .clka(clk),         // input clka
                .wea(we),           // input [0 : 0] wea
                .addra(w_addr),     // input [15 : 0] addra
                .dina(D),           // input [7 : 0] dina
                .clkb(clk),         // input clkb
                .addrb(r_addr),     // input [15 : 0] addrb
                .doutb(outbuff)     // output [7 : 0] doutb
             );



endmodule
