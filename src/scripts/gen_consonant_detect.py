#!/usr/bin/env python
# -*- coding: iso-8859-1 -*-
#=======================================================================
#
# gen_consonant_detect.py
# -----------------------
# Simple Python program that generates Verilog RTL code for detection
# of consonant characters.
#
#
# (c) 2007 Joachim Strömbergson
#
#=======================================================================

#-------------------------------------------------------------------
# Python module imports.
#-------------------------------------------------------------------
import sys


#-------------------------------------------------------------------
# Python contants.
#-------------------------------------------------------------------

# The consonants
consonants = "bBcCdDfFgGhHjJkKlKmMnNpPqQrRsStTvVwWxXzZ"

def main() :
    for letter in consonants :
        print "      if (data_in == \"%s\")" % letter
        print "      begin"
        print "        is_consonant = 1;"
        print "      end"
        print ""

if __name__ == '__main__':
    main()

#=======================================================================
# EOF gen_consonant_detect.py
#=======================================================================
