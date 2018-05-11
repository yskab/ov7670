

 module frame_capture #( parameter H_RES = 160,             
 				         parameter TOTAL_COL = (H_RES)*2,    
 				         parameter TOTAL_ROW = 120,         
				         parameter BUFF_BITS = 16         
				       )	

     (   
         input wire clk,
		 input wire HS,
		 input wire VS,
		 input wire pclk,
         input wire start_capture,             
		 output reg [(BUFF_BITS - 1):0] addr,   
		 output reg write_to_buff,              
		 output wire frame_captured              
	 );



 assign frame_captured = (addr == (TOTAL_COL*TOTAL_ROW))? 1'b1 : 1'b0;

 parameter idle = 1'b0,
 		   capture_data = 1'b1;

 reg cap_state = idle;

 always @(posedge pclk)
 begin
 if(start_capture)
 begin	
 	case(cap_state)
		idle:	begin
					if(VS)                                      
						cap_state <= capture_data;
				end

		capture_data:	begin
	                        if(!frame_captured)
	                    	begin		
		                        write_to_buff <= 1'b0;
		                        if(HS)					
		                            begin				
	                        			write_to_buff <= 1'b1;  
				                        addr <= addr + 1'b1;   
			                        end
		                    end
		                    else 
			                    cap_state <= idle;
	                    end
	endcase
 end
 else
    addr <= {(BUFF_BITS){1'b0}};
 end






endmodule
