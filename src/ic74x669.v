`timescale 1ns / 1ps


module ic74x669(
  input        clk,      
  input        clr_n,   
  input        load_n,   
  input        ent_n,    
  input        enp_n,    
  input        updown,  
  input  [3:0] d,        
  output       rco_n,    
  output reg [3:0] q
 );
 
 wire en = ~ent_n & ~enp_n;

  always @(posedge clk) begin
    if (~clr_n)
      q <= 4'b0000;       
    else if (~load_n)
      q <= d;              
    else if (en) begin
      if (updown)
        q <= q + 1'b1;   
      else
        q <= q - 1'b1;    
    end
  end

 
  assign rco_n = ~( ~ent_n & (
                    (updown & (q == 4'hF)) |
                    (~updown & (q == 4'h0))
                  ));
endmodule
