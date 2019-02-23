//======================================================================
//
// robber_language.v
// -----------------
// RTL Verilog 2001 compliant code for a simple IP-core that implements
// the "Robber Language" as specified by Astrid Lindgren.
//
// The core accepts 8-bit character data as input and will emit 8-bit
// data.
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

module robber_language(
	               input wire          clk,
	               input wire          reset_l,

                       input wire [7 : 0]  data_in,
	               input wire          data_in_valid,

	               input wire          init,
	               input wire          encdec,
		       output wire         busy,

	               output wire [7 : 0] data_out,
	               output wire         data_out_valid
	              );


  //----------------------------------------------------------------
  // Constant and parameter definitions.
  //----------------------------------------------------------------
  // Output mux control.
  parameter  DOUT_DIN  = 0;
  parameter  DOUT_OH   = 1;
  parameter  DOUT_HOLD = 2;

  // Symbolic names for control FSM states.
  parameter FSM_IDLE = 0;
  parameter FSM_INIT = 1;
  parameter FSM_ENC0 = 2;
  parameter FSM_ENC1 = 3;
  parameter FSM_ENC2 = 4;
  parameter FSM_DEC0 = 5;
  parameter FSM_DEC1 = 6;
  parameter FSM_DEC2 = 7;


  //----------------------------------------------------------------
  // Register declarations.
  //----------------------------------------------------------------
  // consonant_hold_reg
  // Hold register for received consonants.
  reg [7 : 0] consonant_hold_reg;
  reg 	      consonant_hold_we;

  // data_out_reg
  // Data output register.
  reg [7 : 0] data_out_reg;
  reg [7 : 0] data_out_new;
  reg 	      data_out_we;

  // data_out_valid_reg
  // Data output register.
  reg data_out_valid_reg;
  reg data_out_valid_new;
  reg data_out_valid_we;

  // busy_reg;
  // Output register for the busy signal. We don't want
  // combinational loops from the data_in_valid to busy.
  reg busy_reg;
  reg busy_new;
  reg busy_we;

  // robber_language_state_reg
  // control FSM state register.
  reg [2 : 0] robber_language_state_reg;
  reg [2 : 0] robber_language_state_new;
  reg 	      robber_language_state_we;


  //----------------------------------------------------------------
  // Variable declarations - wires.
  //----------------------------------------------------------------
  // is_consonant
  // flag signal. If set the current data on the data_in port
  // is a consonant.
  reg is_consonant;

  // data_out_mux_ctrl
  // control signal for the data out mux.
  reg [1 : 0]  data_out_mux_ctrl;


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
	  consonant_hold_reg        <= 1'h0;
	  busy_reg 	            <= 1'h0;
	  data_out_reg              <= 1'h0;
	  data_out_valid_reg        <= 1'h0;
	  robber_language_state_reg <= FSM_IDLE;
	end
      else
	begin
	  if (consonant_hold_we)
	    consonant_hold_reg <= data_in;

	  if (busy_we)
	    busy_reg <= busy_new;

	  if (data_out_we)
	    data_out_reg <= data_out_new;

	  if (data_out_valid_we)
	    data_out_valid_reg <= data_out_valid_new;

	  if (robber_language_state_we)
	    robber_language_state_reg <= robber_language_state_new;
	end
    end


  //----------------------------------------------------------------
  // consonant_detect
  // This combinational block implements the logic needed to detect
  // consonants. Simply by eliminating all vowels.
  //----------------------------------------------------------------
  always @*
    begin : consonant_detect
      case (data_in)
        "a", "A", "o", "O", "u", "U", "e", "E", "i", "I", "y", "Y":
          is_consonant = 1'h0;

        default:
          is_consonant = 1'h1;
      endcase // case (data_in)
    end // consonant_detect


  //----------------------------------------------------------------
  // data_out_mux
  // This combinational block implements the mux that selects what
  // the data out register can be updated with. This can be either
  // the data in the hold register, an "o" or the current data in.
  //----------------------------------------------------------------
  always @*
    begin : data_out_mux
      data_out_new = data_in;

      case (data_out_mux_ctrl)
	DOUT_DIN  : data_out_new = data_in;
	DOUT_OH   : data_out_new = "o";
	DOUT_HOLD : data_out_new = consonant_hold_reg;

	default :
	  begin
	  end
      endcase // case(data_out_mux_ctrl)
    end // data_out_mux


  //----------------------------------------------------------------
  // robber_language_ctrl
  // This combinational block contains the control FSM for the
  // pirate cipher core.
  //----------------------------------------------------------------
  always @*
    begin : robber_language_ctrl
      // Default assignments
      data_out_we 	        = 1'h0;
      data_out_valid_new        = 1'h0;
      data_out_valid_we         = 1'h0;
      consonant_hold_we         = 1'h0;
      busy_new 		        = 1'h0;
      busy_we 		        = 1'h0;
      data_out_mux_ctrl         = DOUT_DIN;
      robber_language_state_new = FSM_IDLE;
      robber_language_state_we  = 1'h0;

      case (robber_language_state_reg)
	FSM_IDLE:
	  begin
	    if (init)
	      begin
		robber_language_state_new = FSM_INIT;
		robber_language_state_we  = 1'h1;
	      end
	  end


	FSM_INIT:
	  begin
	    busy_new 	       = 1'h0;
	    busy_we 	       = 1'h1;
	    data_out_valid_new = 1'h0;
	    data_out_valid_we  = 1'h1;

	    if (encdec)
	      begin
		robber_language_state_new = FSM_ENC0;
		robber_language_state_we  = 1'h1;
	      end
	    else
	      begin
		robber_language_state_new = FSM_DEC0;
		robber_language_state_we  = 1'h1;
	      end
	  end


	FSM_ENC0:
	  begin
	    if (init)
	      begin
		busy_new 		  = 1'h0;
		busy_we 		  = 1'h1;
		data_out_valid_new 	  = 1'h0;
		data_out_valid_we 	  = 1'h1;
		robber_language_state_new = FSM_INIT;
		robber_language_state_we  = 1'h1;
	      end
	    else
	      begin
		data_out_valid_new = 1'h0;
		data_out_valid_we  = 1'h1;

		if (data_in_valid)
		  begin
		    data_out_we        = 1'h1;
		    data_out_valid_new = 1'h1;
		    data_out_valid_we  = 1'h1;
		    data_out_mux_ctrl  = DOUT_DIN;

		    if (is_consonant)
		      begin
			busy_new 	          = 1'h1;
			busy_we 	          = 1'h1;
			consonant_hold_we         = 1'h1;
			robber_language_state_new = FSM_ENC1;
			robber_language_state_we  = 1'h1;
		      end
		  end
	      end
	  end


	FSM_ENC1:
	  begin
	    if (init)
	      begin
		busy_new 	        = 1'h0;
		busy_we 	        = 1'h1;
		data_out_valid_new      = 1'h0;
		data_out_valid_we       = 1'h1;
		robber_language_state_new = FSM_INIT;
		robber_language_state_we  = 1'h1;
	      end
	    else
	      begin
		data_out_mux_ctrl       = DOUT_OH;
		data_out_we 	        = 1'h1;
		robber_language_state_new = FSM_ENC2;
		robber_language_state_we  = 1'h1;
	      end
	  end


	FSM_ENC2 :
	  begin
	    if (init)
	      begin
		busy_new 	        = 1'h0;
		busy_we 	        = 1'h1;
		data_out_valid_new      = 1'h0;
		data_out_valid_we       = 1'h1;
		robber_language_state_new = FSM_INIT;
		robber_language_state_we  = 1'h1;
	      end
	    else
	      begin
		data_out_mux_ctrl         = DOUT_HOLD;
		data_out_we 	          = 1'h1;
		robber_language_state_new = FSM_ENC0;
		robber_language_state_we  = 1'h1;
	      end
	  end

	FSM_DEC0:
	  begin
	    if (init)
	      begin
		busy_new 		   = 1'h0;
		busy_we 		   = 1'h1;
		data_out_valid_new 	   = 1'h0;
		data_out_valid_we 	   = 1'h1;
		robber_language_state_new  = FSM_INIT;
		robber_language_state_we   = 1'h1;
	      end
	    else
	      begin
		data_out_valid_new = 1'h0;
		data_out_valid_we  = 1'h1;

		if (data_in_valid)
		  begin
		    data_out_we        = 1'h1;
		    data_out_valid_new = 1'h1;
		    data_out_valid_we  = 1'h1;
		    data_out_mux_ctrl  = DOUT_DIN;

		    if (is_consonant)
		      begin
			consonant_hold_we         = 1'h1;
			robber_language_state_new = FSM_DEC1;
			robber_language_state_we  = 1'h1;
		      end
		  end
	      end
	  end

	FSM_DEC1:
	  begin
	    if (init)
	      begin
		data_out_valid_new = 1'h0;
		data_out_valid_we  = 1'h1;

		robber_language_state_new = FSM_INIT;
		robber_language_state_we  = 1'h1;
	      end
	    else
	      begin
		data_out_valid_new = 1'h0;
		data_out_valid_we  = 1'h1;

		if (data_in_valid)
		  begin
		    if (data_in == "o")
		      begin
			robber_language_state_new = FSM_DEC2;
			robber_language_state_we  = 1'h1;
		      end
		    else
		      begin
			data_out_we               = 1'h1;
			data_out_valid_new        = 1'h1;
			data_out_valid_we         = 1'h1;
			data_out_mux_ctrl         = DOUT_DIN;
			robber_language_state_new = FSM_DEC0;
			robber_language_state_we  = 1'h1;
		      end
		  end
	      end
	  end

	// FSM_DEC2
	FSM_DEC2 :
	  begin
	    if (init)
	      begin
		data_out_valid_new        = 1'h0;
		data_out_valid_we         = 1'h1;
		robber_language_state_new = FSM_INIT;
		robber_language_state_we  = 1'h1;
	      end
	    else
	      begin
		data_out_valid_new = 1'h0;
		data_out_valid_we  = 1'h1;

		if (data_in_valid)
		  begin
		    if (data_in == consonant_hold_reg)
		      begin
			robber_language_state_new = FSM_DEC0;
			robber_language_state_we  = 1'h1;
		      end
		    else
		      begin
			data_out_we 	          = 1'h1;
			data_out_valid_new        = 1'h1;
			data_out_valid_we         = 1'h1;
			data_out_mux_ctrl         = DOUT_DIN;
			robber_language_state_new = FSM_DEC0;
			robber_language_state_we  = 1'h1;
		      end
		  end
	      end
	  end


	default :
	  begin
	  end
      endcase // case (robber_language_state_reg)
    end // block: robber_language_ctrl
endmodule // robber_language

//======================================================================
// EOF robber_language.v
//======================================================================
