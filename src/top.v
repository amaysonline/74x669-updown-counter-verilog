module top(

    input clk,

    input  [3:0] btn,
    input  [3:0] sw,

    output [3:0] led
);

wire rco_n;

// Clock divider
reg [25:0] div = 0;

always @(posedge clk)
    div <= div + 1;

wire slow_clk = div[25];

// Counter
ic74x669 uut (

    .clk    (slow_clk),

    .clr_n  (~btn[0]),
    .load_n (~btn[1]),

    .ent_n  (1'b0),
    .enp_n  (1'b0),

    .updown (btn[2]),

    .d      (sw[3:0]),

    .rco_n  (rco_n),

    .q      (led[3:0])
);

endmodule
