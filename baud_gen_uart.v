
 module BaudTickGen(	
                		input wire clk,
                		output wire tick,
                		input wire baud_gen_on
                   );

 reg [32:0] acc = 33'd0;   


 always @(posedge clk)
 begin
   if(baud_gen_on)
        acc <= acc[31:0] + 824633;
    else
        acc <= 33'd0; 
 end
 assign tick = acc[32]; 

 endmodule
