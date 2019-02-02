//======================================================================
//
// pirate_cipher.v
// ---------------
// RTL Verilog 2001 compliant code for a simple IP-core that implements
// the "Pirate Cipher" as specified by Astrid Lindgren.
// 
// The core accepts 8-bit character data as input and will emit 8-bit
// data.
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
//  379 MHz in Stratix II
// 
//
//
// (c) 2007 Joachim Strömbergson
// 
//======================================================================

module pirate_cipher  (
                      input wire [7 : 0]  data_in,
	              input wire          data_in_valid,
	     
	              input wire          init,
	              input wire          encdec,
		      output wire         busy,
	     
	              output wire [7 : 0] data_out,
	              output wire         data_out_valid,

	              input wire          clk,
	              input wire          reset_l
	             );


  //----------------------------------------------------------------
  // Constant and parameter definitions.
  //----------------------------------------------------------------
  // Symbolic names for data out mux control.
  parameter 	    DOUT_DIN  = 0;
  parameter 	    DOUT_OH   = 1;
  parameter 	    DOUT_HOLD = 2;


  // Symbolic names for control FSM states.
  parameter 	    FSM_IDLE = 0;
  parameter 	    FSM_INIT = 1;
  parameter 	    FSM_ENC0 = 2;
  parameter 	    FSM_ENC1 = 3;
  parameter 	    FSM_ENC2 = 4;
  parameter 	    FSM_DEC0 = 5;
  parameter 	    FSM_DEC1 = 6;
  parameter 	    FSM_DEC2 = 7;
  

  //----------------------------------------------------------------
  // Register declarations.
  //----------------------------------------------------------------
  // consonant_hold_reg
  // Hold register for received consonants.
  reg [7 : 0] 		    consonant_hold_reg;
  reg 			    consonant_hold_we;

  // data_out_reg
  // Data output register.
  reg [7 : 0] 		    data_out_reg;
  reg [7 : 0] 		    data_out_new;
  reg 			    data_out_we;

  // data_out_valid_reg
  // Data output register.
  reg 			    data_out_valid_reg;
  reg 			    data_out_valid_new;
  reg 			    data_out_valid_we;

  // busy_reg;
  // Output register for the busy signal. We don't want
  // combinational loops from the data_in_valid to busy.
  reg 			    busy_reg;
  reg 			    busy_new;
  reg 			    busy_we;
  
  // pirate_cipher_state_reg
  // control FSM state register.
  reg [2 : 0] 		    pirate_cipher_state_reg;
  reg [2 : 0] 		    pirate_cipher_state_new;
  reg 			    pirate_cipher_state_we;

  
  //----------------------------------------------------------------
  // Variable declarations - wires.
  //----------------------------------------------------------------
  // is_consonant
  // flag signal. If set the current data on the data_in port
  // is a consonant.
  reg 			    is_consonant;

  // data_out_mux_ctrl
  // control signal for the data out mux.
  reg [1 : 0] 		    data_out_mux_ctrl;
      
  
  //----------------------------------------------------------------
  // Concurrent assignments
  // Connecting output ports to output registers.
  //----------------------------------------------------------------
  assign busy 		= busy_reg;
  assign data_out 	= data_out_reg;
  assign data_out_valid = data_out_valid_reg;
		  
  
  //----------------------------------------------------------------
  // reg_update
  // This block contains all the register updates.
  // All registers are positive edge triggered with synchronous
  // active low reset.
  //----------------------------------------------------------------
  always @ (posedge clk)
    begin
      if (!reset_l)
	begin
	  // Reset all registers to defined values.
	  consonant_hold_reg <= 0;

	  busy_reg 		    <= 0;
	  
	  data_out_reg 		    <= 0;
	  data_out_valid_reg 	    <= 0;

	  pirate_cipher_state_reg   <= FSM_IDLE;
	end
      else
	begin
	  // Normal register updates.

	  if (consonant_hold_we)
	    begin
	      consonant_hold_reg    <= data_in;
	    end

	  if (busy_we)
	    begin
	      busy_reg <= busy_new;
	    end
gg
	  if (data_out_we)
	    begin
	      data_out_reg <= data_out_new;
	    end

	  if (data_out_valid_we)
	    begin
	      data_out_valid_reg <= data_out_valid_new;
	    end
	  
	  if (pirate_cipher_state_we)
	    begin
	      pirate_cipher_state_reg <= pirate_cipher_state_new;
	    end
	end
    end
  
  
  //----------------------------------------------------------------
  // consonant_detect
  // This combinational block implements the logic needed to detect
  // consonants. Basically a whole bunch of 8-bit XOR gates and
  // a wire-OR net to pattern match against ASCII constants.
  //----------------------------------------------------------------
  always @*
    begin : consonant_detect
      // Default assignments
      is_consonant    = 0;

      if (data_in == "b")
      begin
        is_consonant = 1;
      end

      if (data_in == "B")
      begin
        is_consonant = 1;
      end

      if (data_in == "c")
      begin
        is_consonant = 1;
      end

      if (data_in == "C")
      begin
        is_consonant = 1;
      end

      if (data_in == "d")
      begin
        is_consonant = 1;
      end

      if (data_in == "D")
      begin
        is_consonant = 1;
      end

      if (data_in == "f")
      begin
        is_consonant = 1;
      end

      if (data_in == "F")
      begin
        is_consonant = 1;
      end

      if (data_in == "g")
      begin
        is_consonant = 1;
      end

      if (data_in == "G")
      begin
        is_consonant = 1;
      end

      if (data_in == "h")
      begin
        is_consonant = 1;
      end

      if (data_in == "H")
      begin
        is_consonant = 1;
      end

      if (data_in == "j")
      begin
        is_consonant = 1;
      end

      if (data_in == "J")
      begin
        is_consonant = 1;
      end

      if (data_in == "k")
      begin
        is_consonant = 1;
      end

      if (data_in == "K")
      begin
        is_consonant = 1;
      end

      if (data_in == "l")
      begin
        is_consonant = 1;
      end

      if (data_in == "K")
      begin
        is_consonant = 1;
      end

      if (data_in == "m")
      begin
        is_consonant = 1;
      end

      if (data_in == "M")
      begin
        is_consonant = 1;
      end

      if (data_in == "n")
      begin
        is_consonant = 1;
      end

      if (data_in == "N")
      begin
        is_consonant = 1;
      end

      if (data_in == "p")
      begin
        is_consonant = 1;
      end

      if (data_in == "P")
      begin
        is_consonant = 1;
      end

      if (data_in == "q")
      begin
        is_consonant = 1;
      end

      if (data_in == "Q")
      begin
        is_consonant = 1;
      end

      if (data_in == "r")
      begin
        is_consonant = 1;
      end

      if (data_in == "R")
      begin
        is_consonant = 1;
      end

      if (data_in == "s")
      begin
        is_consonant = 1;
      end

      if (data_in == "S")
      begin
        is_consonant = 1;
      end

      if (data_in == "t")
      begin
        is_consonant = 1;
      end

      if (data_in == "T")
      begin
        is_consonant = 1;
      end

      if (data_in == "v")
      begin
        is_consonant = 1;
      end

      if (data_in == "V")
      begin
        is_consonant = 1;
      end

      if (data_in == "w")
      begin
        is_consonant = 1;
      end

      if (data_in == "W")
      begin
        is_consonant = 1;
      end

      if (data_in == "x")
      begin
        is_consonant = 1;
      end

      if (data_in == "X")
      begin
        is_consonant = 1;
      end

      if (data_in == "z")
      begin
        is_consonant = 1;
      end

      if (data_in == "Z")
      begin
        is_consonant = 1;
      end

      
    end // consonant_detect

  
  //----------------------------------------------------------------
  // data_out_mux
  // This combinational block implements the mux that selects what
  // the data out register can be updated with. This can be either
  // the data in the hold register, an "o" or the current data in.
  //----------------------------------------------------------------
  always @*
    begin : data_out_mux
      case (data_out_mux_ctrl)
	// DOUT_DIN
	// Data in is passed right through to the data out register.
	DOUT_DIN :
	  begin
	    data_out_new = data_in;
	  end


	// DOUT_OH
	// The letter "o" is sent to the data out register.
	DOUT_OH :
	  begin
	    data_out_new = "o";
	  end


	// DOUT_HOLD
	// The data in the hold register is sent to the data out register.
	DOUT_HOLD :
	  begin
	    data_out_new = consonant_hold_reg;
	  end


	// default
	// By default we send data in to data out register.
	default :
	  begin
	    data_out_new = data_in;
	  end
      endcase // case(data_out_mux_ctrl)
    end // data_out_mux
  
  
  //----------------------------------------------------------------
  // pirate_cipher_ctrl
  // This combinational block contains the control FSM for the
  // pirate cipher core.
  //----------------------------------------------------------------
  always @*
    begin : pirate_cipher_ctrl
      // Default assignments

      data_out_we 		 = 0;

      data_out_valid_new 	 = 0;       
      data_out_valid_we 	 = 0;       

      consonant_hold_we 	 = 0;

      busy_new 			 = 0;
      busy_we 			 = 0;
      
      data_out_mux_ctrl 	 = DOUT_DIN;
      
      pirate_cipher_state_new 	 = FSM_IDLE;
      pirate_cipher_state_we 	 = 0;

      case (pirate_cipher_state_reg)

	// FSM_IDLE
	// We start in this state after reset and we stay here until
	// the application sets the initial signal. When init is
	// asserted we move to the init state.
	FSM_IDLE :
	  begin
	    if (init)
	      begin
		pirate_cipher_state_new    = FSM_INIT;
		pirate_cipher_state_we 	   = 1;
	      end
	  end

	// FSM_INIT
	// We drop any data_out valid signal and any busy signal. 
	// We then look at the encdec signal to determine how to 
	// hande received dataa. We then move to the 
	// appropriate state.
	FSM_INIT :
	  begin
	    busy_new 			   = 0;       
	    busy_we 			   = 1;       
	    
	    data_out_valid_new 		   = 0;       
	    data_out_valid_we 		   = 1;       

	    if (encdec)
	      begin
		// We shoud encipher.
		pirate_cipher_state_new = FSM_ENC0;
		pirate_cipher_state_we  = 1;
	      end
	    else
	      begin
		// We should decipher.
		pirate_cipher_state_new    = FSM_DEC0;
		pirate_cipher_state_we 	   = 1;
	      end
	  end
	
	
	// FSM_ENC0
	// First we check if we get a new init signal. If we do
	// we go directly to the FSM_INIT state. If not we
	// drop any data valid flag and wait for new data. When
	// data is avaiable we check how it should be handled and
	// then assert the data out valid flag. If the data received
	// is a consonant we also assert the busy flag and move to
	// the FSM_ENC1 state. If else we hang around here and wait
	// for more data.
	FSM_ENC0 :
	  begin
	    if (init)
	      begin
		busy_new 		   = 0;       
		busy_we 		   = 1;       
		
		data_out_valid_new 	   = 0;       
		data_out_valid_we 	   = 1;       

		pirate_cipher_state_new    = FSM_INIT;
		pirate_cipher_state_we 	   = 1;
	      end
	    else
	      begin
		// By default we don't have any valid data out.
		data_out_valid_new    = 0;       
		data_out_valid_we     = 1;       

		// Wait here for data.
		if (data_in_valid)
		  begin
		    // We have data. Assert the data valid flag
		    // and store the data in the data out reg.
		    // We then check if it is a consonant.
		    data_out_we 	  = 1;
		    data_out_valid_new 	  = 1;       
		    data_out_valid_we 	  = 1;       
		    data_out_mux_ctrl 	  = DOUT_DIN;

		    if (is_consonant)
		      begin
			// Yes, we got a consonant. Store the data
			// in the hold register and assert the busy
			// flag. We then move to FSM_ENC1.
			busy_new 		   = 1;       
			busy_we 		   = 1;       

			consonant_hold_we 	   = 1;
			pirate_cipher_state_new    = FSM_ENC1;
			pirate_cipher_state_we 	   = 1;
		      end
		  end
	      end
	  end


	// We start by checking if there is an init signal. If there is
	// we move to the FSM_INIT state, dropping all flags. If not
	// we should emit an "o" and then move to the FSM_ENC2 state.
	FSM_ENC1 :
	  begin
	    if (init)
	      begin
		busy_new 		   = 0;       
		busy_we 		   = 1;       
		
		data_out_valid_new 	   = 0;       
		data_out_valid_we 	   = 1;       
		
		pirate_cipher_state_new    = FSM_INIT;
		pirate_cipher_state_we 	   = 1;
	      end
	    else
	      begin
		data_out_mux_ctrl 	   = DOUT_OH;
		data_out_we 		   = 1;
		
		pirate_cipher_state_new    = FSM_ENC2;
		pirate_cipher_state_we 	   = 1;
	      end
	  end


	// We start by checking if there is an init signal. If there is
	// we move to the FSM_INIT state, dropping all flags. If not
	// we should emit an "o" and then move to the FSM_ENC2 state.
	FSM_ENC2 :
	  begin
	    if (init)
	      begin
		busy_new 		   = 0;       
		busy_we 		   = 1;       
		
		data_out_valid_new 	   = 0;       
		data_out_valid_we 	   = 1;       
		
		pirate_cipher_state_new    = FSM_INIT;
		pirate_cipher_state_we 	   = 1;
	      end
	    else
	      begin
		data_out_mux_ctrl 	   = DOUT_HOLD;
		data_out_we 		   = 1;
		
		pirate_cipher_state_new    = FSM_ENC0;
		pirate_cipher_state_we 	   = 1;
	      end
	  end


	// FSM_DEC0
	// 
	FSM_DEC0 :
	  begin
	    if (init)
	      begin
		busy_new 		   = 0;       
		busy_we 		   = 1;       
		
		data_out_valid_new 	   = 0;       
		data_out_valid_we 	   = 1;       
		
		pirate_cipher_state_new    = FSM_INIT;
		pirate_cipher_state_we 	   = 1;
	      end
	    else
	      begin
		// We stay here until we get an input. We
		// also drop the data out valid flag.
		data_out_valid_new 	   = 0;       
		data_out_valid_we 	   = 1;       

		if (data_in_valid)
		  begin
		    // We have data. Assert the data valid flag
		    // and store the data in the data out reg.
		    // We then check if it is a consonant.
		    data_out_we 	  = 1;
		    data_out_valid_new 	  = 1;       
		    data_out_valid_we 	  = 1;       
		    data_out_mux_ctrl 	  = DOUT_DIN;

		    if (is_consonant)
		      begin
			// Yes, we got a consonant. This means we should
			// try and consume to more bytes of data. We
			// move to FSM_DEC1.
			consonant_hold_we        = 1;
			pirate_cipher_state_new  = FSM_DEC1;
			pirate_cipher_state_we 	 = 1;
		      end
		  end
	      end
	  end
	
	// FSM_DEC1
	// Check for an init signal. If found we move to the
	// FSM_INIT state. If not found we wait for the next
	// data. If it is an "o" we consume 
	// the data and move to the FSM_DEC2 state. If not we 
	// move to the FSM_DEC0 state.
	FSM_DEC1 :
	  begin
	    if (init)
	      begin
		data_out_valid_new 	   = 0;       
		data_out_valid_we 	   = 1;       
		
		pirate_cipher_state_new    = FSM_INIT;
		pirate_cipher_state_we 	   = 1;
	      end
	    else
	      begin
		// We stay here until we get an input. We
		// also drop the data out valid flag.
		data_out_valid_new 	   = 0;       
		data_out_valid_we 	   = 1;       

		if (data_in_valid)
		  begin
		    // We check if the data is an "o". If it is
		    // we simply ignore the data and move to FSM_DEC2. 
		    // If not we have a problem. We emit the data and move 
		    // to FSM_DEC0.
		    if (data_in == "o")
		      begin
			pirate_cipher_state_new = FSM_DEC2;
			pirate_cipher_state_we 	= 1;
		      end
		    else
		      begin
			data_out_we 		   = 1;
			data_out_valid_new 	   = 1;       
			data_out_valid_we 	   = 1;       
			data_out_mux_ctrl 	   = DOUT_DIN;

			pirate_cipher_state_new    = FSM_DEC0;
			pirate_cipher_state_we 	   = 1;
		      end
		  end
	      end
	  end
	
	// FSM_DEC2
	// Wait for the next data. If it matches the data in the
	// hold register we consume the data. If not we move to the
	// FSM_DEC0 state.
	FSM_DEC2 :
	  begin
	    if (init)
	      begin
		data_out_valid_new 	   = 0;       
		data_out_valid_we 	   = 1;       
		
		pirate_cipher_state_new    = FSM_INIT;
		pirate_cipher_state_we 	   = 1;
	      end
	    else
	      begin
		// We stay here until we get an input. We
		// also drop the data out valid flag.
		data_out_valid_new 	   = 0;       
		data_out_valid_we 	   = 1;       

		if (data_in_valid)
		  begin
		    // We check if the data is what is stored in the
		    // hold register. If it is we ignore the data and
		    // move to FSM_DEC0. If not we have a problem. 
		    // We emit the data and move to FSM_DEC0.
		    if (data_in == consonant_hold_reg)
		      begin
			pirate_cipher_state_new = FSM_DEC0;
			pirate_cipher_state_we 	= 1;
		      end
		    else
		      begin
			data_out_we 		= 1;
			data_out_valid_new 	= 1;       
			data_out_valid_we 	= 1;       
			data_out_mux_ctrl 	= DOUT_DIN;
			
			pirate_cipher_state_new = FSM_DEC0;
			pirate_cipher_state_we 	= 1;

		      end
		  end
	      end
	  end
	
	
	// default
	// Empty default state to help parsers that need help to
	// fill up the state space.
	default :
	  begin
	    // Empty state since we define all control signals
	    // in the default assignment at the top of the process.
	  end
      endcase // case(arc4_state_reg)
    end // pirate_cipher_ctrl

endmodule // pirate_cipher

//======================================================================
// EOF pirate_cipher.v
//======================================================================
