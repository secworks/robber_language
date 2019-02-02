//======================================================================
//
// tb_pirate_cipher.v
// ------------------
// Testbench for the pirate cipher core.
//
//    This program is free software; you can redistribute it and/or 
//    modify it under the terms of the GNU General Public License as 
//    published by the Free Software Foundation; either version 2 of 
//    the License, or (at your option) any later version.
//  
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//  
//    You should have received a copy of the GNU General Public 
//    License along with this program; if not, write to the Free 
//    Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, 
//    MA 02111-1307, USA
//
//
// (c) 2007 Joachim Strömbergson
// 
//======================================================================

module tb_pirate_cipher ();

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
  pirate_cipher  idut (
                      .data_in(tb_data_in),
	              .data_in_valid(tb_data_in_valid),

	              .init(tb_init),
	              .encdec(tb_encdec),
		      .busy(tb_busy),

	              .data_out(tb_data_out),
	              .data_out_valid(tb_data_out_valid),

	              .clk(clk),
	              .reset_l(clk)
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

   
//    //---------------------------------------------------------------
//    // tc1_trigger_init
//    // Test case1: Load key.
//    // This test case will trigger an init for encipher.
//    // the DUT.
//    //---------------------------------------------------------------
//    task tc1_trigger_init
//       output [31:0] errors_found;
//       begin
// 	 // Clear the errors_found counter
// 	 errors_found = 0;

// 	 // Load a static one key into the key_mem.
// 	 for (i = 0 ; i < 32 ; i = i + 1)
// 	   begin
// 	      tb_key_address = i[4:0];
// 	      if (TC1_STATIC_KEY)
// 		begin
// 		   tb_key_data = TC1_KEY_BYTE;
// 		end
// 	      else
// 		begin
// //		   tb_key_data = i;
// 		   tb_key_data = 2;
// 		end
// 	      tb_key_data_valid = 1;
// 	      #(CLOCK);
// 	   end

// 	 // Turn off key_data_valid again.
// 	 tb_key_data_valid = 0;
	 
//  	 $display("TB-SIM: Key loaded ok.");
//      end
//    endtask // tc1_load_key

   
//    //---------------------------------------------------------------
//    // tc2_init_cipher;
//    // Test case2: Init cipher.
//    // This test case will trigger a cipher init operation in the
//    // the DUT.
//    //---------------------------------------------------------------
//    task tc2_init_cipher;
//       output [31:0] errors_found;
//       begin
// 	 $display("");
// 	 $display("TC2: Cipher init.");
// 	 // Clear the errors_found counter
// 	 errors_found = 0;
	 
// 	 // Wait a few cycles
// //	 #(CLOCK * 40);
	 
// 	 // Set the tb_init_cipher high for a cycle.
// 	 tb_init_cipher = 1;
// 	 $display("TB-ARCFOUR: init_cipher = %1d", tb_init_cipher);
// 	 #(2* CLOCK);
// 	 tb_init_cipher = 0;
// 	 $display("TB-ARCFOUR: init_cipher = %1d", tb_init_cipher);

// 	 while (tb_k_valid == 0)
// 	   begin
// 	      #(CLOCK);
// 	   end

// 	 $display("TB-INFO: Init seems to be completed.");
// 	 $display("TB-INFO: Dumping internal state");
// 	 $display("TB-INFO: ip = %3d, id = %3d", DUT.ip, DUT.id);
// 	 $display("TB-INFO: jp = %3d, jd = %3d", DUT.jp, DUT.jd);
// 	 $display("TB-INFO: kp = %3d, kd = %3d", DUT.kp, DUT.kd);
// 	 $display("");
	 
// 	 for (i = 0 ; i < 256 ; i = i + 1)
// 	   begin
// 	      $display("state_mem[%3d] = %3d", i, DUT.state_mem.mem_array[i]);
// 	   end

// 	 $display("Generating 1000 values.");
// 	 for (values = 0 ; values < 1000 ; values = values + 1)
// 	   begin
// 	      tb_next_k = 1;
// 	      #(CLOCK * 1);
	      
// 	      while (tb_k_valid == 0)
// 		begin
// 		   #(CLOCK);
// 		end
// 	      $display("TB-INFO: Round = %4d, K_data = %3d", values, tb_k_data);
// 	   end

// 	 // Turn off generation.
// 	 tb_next_k = 0;
	 
// 	 errors_found = 0;
//      end
//    endtask // tc2_init_cipher
   

  
   
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
  
endmodule // tb_arc4

//======================================================================
// EOF tb_pirate_cipher.v
//======================================================================
