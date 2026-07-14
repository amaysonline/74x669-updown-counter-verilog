`timescale 1ns / 1ps
`timescale 1ns/1ps
module ic74x669_tb;
  reg        clk;
  reg        clr_n;
  reg        load_n;
  reg        ent_n;
  reg        enp_n;
  reg        updown;
  reg  [3:0] d;

  wire       rco_n;
  wire [3:0] q;

  // -------------------------------------------------
  // Instantiate DUT (Device Under Test)
  // -------------------------------------------------
  ic74x669 uut (
    .clk    (clk),
    .clr_n  (clr_n),
    .load_n (load_n),
    .ent_n  (ent_n),
    .enp_n  (enp_n),
    .updown (updown),
    .d      (d),
    .rco_n  (rco_n),
    .q      (q)
  );

  // -------------------------------------------------
  // Clock generation
  // 10ns period = 100 MHz
  // -------------------------------------------------
  initial
    clk = 0;

  always
    #5 clk = ~clk;

  // -------------------------------------------------
  // Task: wait for N clock cycles
  // -------------------------------------------------
  task tick;
    input integer n;
    integer i;
    begin
      for (i = 0; i < n; i = i + 1)
        @(posedge clk);

      #1; // allow outputs to settle
    end
  endtask

  // -------------------------------------------------
  // Task: check outputs
  // -------------------------------------------------
  task check;
    input [3:0] expected_q;
    input       expected_rco;
    input [79:0] test_name;

    begin
      if ((q === expected_q) && (rco_n === expected_rco))
        $display("PASS | %s | q=%0d rco_n=%b",
                  test_name, q, rco_n);

      else
        $display("FAIL | %s | got q=%0d rco_n=%b | expected q=%0d rco_n=%b",
                  test_name, q, rco_n,
                  expected_q, expected_rco);
    end
  endtask

  // -------------------------------------------------
  // Main Test Sequence
  // -------------------------------------------------
  initial begin

    // Initial values
    clr_n   = 1;
    load_n  = 1;
    ent_n   = 1;
    enp_n   = 1;
    updown  = 1;
    d       = 4'd0;

    #3;

    // =================================================
    // TEST 1 : Synchronous Clear
    // =================================================
    clr_n = 0;

    tick(2);

    clr_n = 1;

    check(4'd0, 1'b1, "SYNC_CLEAR");

    // =================================================
    // TEST 2 : Synchronous Load
    // Load decimal 10
    // =================================================
    d = 4'b1010;

    load_n = 0;

    tick(1);

    load_n = 1;

    check(4'd10, 1'b1, "LOAD_10");

    // =================================================
    // TEST 3 : Count UP
    // 10 -> 13
    // =================================================
    ent_n  = 0;
    enp_n  = 0;
    updown = 1;

    tick(3);

    check(4'd13, 1'b1, "COUNT_UP");

    // =================================================
    // TEST 4 : Reach 15 and check RCO
    // =================================================
    tick(2);

    check(4'd15, 1'b0, "RCO_UP");

    // =================================================
    // TEST 5 : Overflow 15 -> 0
    // =================================================
    tick(1);

    check(4'd0, 1'b1, "ROLLOVER");

    // =================================================
    // TEST 6 : Count DOWN
    // Load 5 then count down to 2
    // =================================================
    ent_n = 1;
    enp_n = 1;

    d = 4'd5;

    load_n = 0;

    tick(1);

    load_n = 1;

    ent_n  = 0;
    enp_n  = 0;
    updown = 0;

    tick(3);

    check(4'd2, 1'b1, "COUNT_DN");

    // =================================================
    // TEST 7 : Reach 0 while counting DOWN
    // =================================================
    tick(2);

    check(4'd0, 1'b0, "RCO_DN");

    // =================================================
    // TEST 8 : HOLD condition
    // Counter should stop
    // =================================================
    ent_n = 1;
    enp_n = 1;

    tick(5);

    check(4'd0, 1'b1, "HOLD");

    // =================================================
    // TEST 9 : LOAD priority over COUNT
    // =================================================
    d = 4'd7;

    load_n = 0;

    ent_n  = 0;
    enp_n  = 0;
    updown = 1;

    tick(1);

    load_n = 1;

    check(4'd7, 1'b1, "LOAD_PRI");

    // =================================================
    // End simulation
    // =================================================
    $display("\n--------------------------------");
    $display("Simulation Complete");
    $display("--------------------------------\n");

    #20;

    $finish;
  end

  // -------------------------------------------------
  // Monitor values every clock edge
  // -------------------------------------------------
  always @(posedge clk) begin
    $display("TIME=%0t | q=%04b (%0d) | rco_n=%b | updown=%b",
              $time, q, q, rco_n, updown);
  end
