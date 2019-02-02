#=======================================================================
 
# Makefile
# --------
# Simple makefile for compiling and simulating the pirate cipher
# core using Icarus Verilog.
# 
#
#    This program is free software; you can redistribute it and/or 
#    modify it under the terms of the GNU General Public License as 
#    published by the Free Software Foundation; either version 2 of 
#    the License, or (at your option) any later version.
#  
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#  
#    You should have received a copy of the GNU General Public 
#    License along with this program; if not, write to the Free 
#    Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, 
#    MA 02111-1307, USA
#
#
# (c) 2007 Joachim Strömbergson
# 
#=======================================================================

# Build the core using the RTL source.
build-core :
	iverilog -v -o core_pirate_cipher ../rtl/pirate_cipher.v


# Build the simulation kernel using the RTL and TB source.
build-sim :
	iverilog -v -o sim_pirate_cipher ../testbench/tb_pirate_cipher.v ../rtl/pirate_cipher.v



# Run the simulation kernel
run-sim :
	./sim_pirate_cipher


# Clean up i.e. remove the simulation kernel.
clean :
	rm sim_pirate_cipher


# List the make commands supported
help:
#	$echo "Commands supported:"
#	echo "-------------------\n"
#	echo "  build-core: Build the core using the RTL source.\n"
#	echo "  build-sim:  Build the simulation kernel using the RTL and the TB source.\n"
#	echo "  run-sim:    Run the simultion kernel.\n"
#	echo "  clean:      Clean up compilation builds and simulation logs.\n"
#	echo "  help:       This list of commands.\n"


#=======================================================================
# EOF Makefile
#=======================================================================
