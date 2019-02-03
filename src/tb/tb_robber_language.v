//======================================================================
//
// tb_robber_language.v
// ------------------
// Testbench for the robber_language core.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2007-2019, Assured AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

module tb_robber_language;

  //---------------------------------------------------------------
  // Constant and parameter declarations
  //---------------------------------------------------------------
  // PROBES_ON
  // This parameter controls if the internal probes will be
  // active or not.
  parameter PROBES_ON = 1;

  // CLOCK
  // The number of clock toggles that represent a clock cycle.
  // Naturally this value is 2, but we want symbolic constants.
  parameter CLOCK = 2;

  // RESET_TIME
  // The number of clock cycles the reset is asserted.
  parameter RESET_TIME = 10;

  // DEBUG_MONITOR
  // Controls if the debug monitor should be active or not.
  parameter DEBUG_MONITOR = 0;

  // END_CYCLE
  // The cycle the simulation should end.
  parameter MAX_CYCLES = 1000000;

  // Testcase state names
  parameter IDLE            = 0;
  parameter LOAD_KEY        = 10;
  parameter LOAD_KEY_FINISH = 15;
  parameter INIT_CIPHER_1   = 20;
  parameter INIT_CIPHER_2   = 25;
  parameter FINISH          = 100;

  parameter TC1_STATIC_KEY  = 0;
  parameter TC1_KEY_BYTE    = 2;


  //----------------------------------------------------------------
  // Register declarations.
  //----------------------------------------------------------------
  // Clock and reset.
  reg 	       clk     = 0;
  reg 	       reset_l = 0;

  // Cycle counter and other test functionality regs..
  reg [31 : 0] cycle_counter;

  // Error counter, used to track the number of errors.
  integer      num_errors;
  integer      errors;

  integer      values;


  //----------------------------------------------------------------
  // Variable declarations - wires.
  //----------------------------------------------------------------
  // Interconnect for the DUT interface.
  reg [7 : 0]  tb_data_in;
  reg 	       tb_data_in_valid;

  reg 	       tb_init;
  reg 	       tb_encdec;
  wire 	       tb_busy;

  wire [7 : 0]  tb_data_out;
  wire 		tb_data_out_valid;

  reg 	       enable_monitor;

  // Assorted test case variables.
  reg [31 : 0] i;
  reg [31 : 0] new_i;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------


  //----------------------------------------------------------------
  // idut
  // Instantiation of the Device Under Test (DUT), the core.
  //----------------------------------------------------------------
  robber_language  dut (
	                .clk(clk),
	                .reset_l(reset_l),

                        .data_in(tb_data_in),
	                .data_in_valid(tb_data_in_valid),

	                .init(tb_init),
	                .encdec(tb_encdec),
		        .busy(tb_busy),

	                .data_out(tb_data_out),
	                .data_out_valid(tb_data_out_valid)
	               );


   //---------------------------------------------------------------
   // check_result
   // Task that checks if a given response equals the
   // expected response.
   //
   // ADD: Verbosity and output format control inputs.
   //---------------------------------------------------------------
   task check_response;
      input [32:0] expected_value;
      input [31:0] response_value;
      begin
	 // Check if the response is as expected, if it isn't we
	 // print a helpful error message.
	 if (expected_value != response_value)
	   begin
	      $display("TB-INFO: Error: Expected response %32b, got %32b");
	   end
      end
   endtask // check_response


   //---------------------------------------------------------------
   // Clock generator process
   // Will toggle the clk every timescale time period.
   //---------------------------------------------------------------
   always begin
      #(CLOCK / 2);
      clk = !clk;
   end


   //---------------------------------------------------------------
   // Reset generator
   //---------------------------------------------------------------
   initial
     begin
	// Wait RESET_TIME number of cycles before releasing
	// the reset.
	#(CLOCK * RESET_TIME);
	reset_l = 1;
	$display("TB-SIM: Reset released.");
   end


/*
   //---------------------------------------------------------------
   // Monitor process. if DEBUG_MONITOR is active the process
   // continiously detects and reports on changes to the
   // DUT stimuli and/or response.
   //---------------------------------------------------------------
   always @*
     begin
	if (1 == DEBUG_MONITOR)
	  begin
	     $display("TB-INFO (cycle = %4d): key_address = %d, key_data = %d, key_data_valid = %d",
		      cycle_counter, tb_key_address, tb_key_data, tb_key_data_valid);
	     $display("TB-INFO (cycle = %4d): init_cipher = %d, next_k = %d",
		      cycle_counter, tb_init_cipher,tb_next_k);
	     $display("TB-INFO (cycle = %4d): k_data = %d, k_valid = %d",
		      cycle_counter, tb_k_data, tb_k_valid);
	  end
     end
*/

   //---------------------------------------------------------------
   // Cycle counter process
   // Will count the cycles and halt a runaway simulation.
   //---------------------------------------------------------------
   always @(posedge clk, negedge reset_l)
     begin
	if (0 == reset_l)
	  begin
	     cycle_counter <= 0;
	  end
	else
	  begin
	     cycle_counter <= cycle_counter + 1;
	  end

	// Check if we have reached MAX_CYCLES, and if so print
	// an error message and finish the simulation.
	if (cycle_counter == MAX_CYCLES)
	  begin
	     $display("TB-INFO: MAX_CYCLES reached. Simulation seems to have gone astray...");
	     $finish;
	  end
     end


  //----------------------------------------------------------------
  // dut_state_mon
  // This block contains a synchronous state monitor for the
  // DUT.
  //----------------------------------------------------------------
  always @ (posedge clk)
    begin : dut_state_mon

      if (enable_monitor)
	begin
	  $display("TB-INFO: cycle_counter:      %8d", cycle_counter);
//	  $display("TB-INFO: ip   = %3d, new_ip     = %3d, ip_we = %3d", idut.i_ptr_reg, idut.new_i_ptr, idut.i_ptr_we);
// 	  $display("TB-INFO: id   = %3d, new_id     = %3d", idut.si_data_reg, idut.new_si_data);
// 	  $display("TB-INFO: jp   = %3d, jd         = %3d", idut.j_ptr_reg, idut.sj_data_reg);
// 	  $display("TB-INFO: init = %3d, arc4_state = %3d", idut.init, idut.arc4_state_reg);
// 	  $display("TB-INFO: dout = %3d, dvalid     = %3d", idut.arc4_out, idut.arc4_valid);
	  $display("");
	end
    end // dut_state_mon


  //----------------------------------------------------------------
  // reg_update
  // This block contains all the register updates in the arc4 core.
  // All registers are positive edge triggered with synchronous
  // active low reset.
  //----------------------------------------------------------------
  always @ (posedge clk)
    begin : reg_update
      if (!reset_l)
	begin

	end
      else
	begin

	end
    end // reg_update.


   //---------------------------------------------------------------
   // init_testbench
   // At time 0 this will initialize the testbench and the DUT.
   //---------------------------------------------------------------
   task init_testbench;
     begin
       // Initialize clock and reset_l to defined states.
       clk 		    = 0;
       reset_l 		    = 0;
       cycle_counter 	    = 0;
       num_errors 	    = 0;

       tb_data_in 	    = 0;
       tb_data_in_valid     = 0;
       tb_init 		    = 0;
       tb_encdec 	    = 0;
     end
   endtask // init_testbench


   //---------------------------------------------------------------
   // Main simulation functionality.
   // Calls the test tasks to perform the different test cases.
   //---------------------------------------------------------------
   initial
     begin
       // Initialize the test bench
       init_testbench;

       // Print a nice and informative start message about the DUT and
       // the types of test that are going to be performed.
       $display("\n");
       $display("     *** Start of arc4 core functional simulation ***");
       $display("\n");

       // Wait for the reset to be deasserted.
       wait (reset_l == 1);

       // Enable the monitor
       enable_monitor = 1;

       // Run through the test cases, adding the errors as we
       // go along.
       // 	tc1_load_key(errors);

       // 	num_errors = num_errors + errors;
       // 	tc2_init_cipher(errors);
       // 	num_errors = num_errors + errors;

       // Wait a few cycles.
       #10;

       // Set the init flag:
       $display("Initializing.");

       // Wait a while
       #1000;

       // Finish the simulation including presenting the number of
       // errors found during simulation
       $display("TB-SIM: Simulation finished.");
       $display("TB-SIM: Number of cycles consumed: %d", cycle_counter);

       if (num_errors == 0)
	 begin
	   $display("TB-SIM: no errors found during simulation.");
	 end
       else
	 begin
	   $display("TB-SIM: ERROR. %2d errors found during simulation.", num_errors);
	 end
       $finish;
     end

endmodule // tb_robber_language

//======================================================================
// EOF tb_robber_language.v
//======================================================================
